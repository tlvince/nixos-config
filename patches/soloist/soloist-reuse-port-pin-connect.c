//  1) Share UDP 5353 (mDNS) with avahi-daemon / systemd-resolved: force
//     SO_REUSEADDR (+SO_REUSEPORT) on soloist's 5353 bind() so the kernel
//     delivers multicast copies to both sockets (spotify/soloist#1).
//  2) Pin soloist's ephemeral Connect TCP listener to a fixed port:
//     rewrite explicit bind(0.0.0.0:0, SOCK_STREAM) to
//     $SOLOIST_CONNECT_PORT only — no fallback, so a silent port move can
//     never defeat the single-port firewall pin (spotify/soloist#4). If
//     taken, bind fails EADDRINUSE and soloist fails loudly instead.
// Everything else passes through untouched.
#define _GNU_SOURCE
#include <arpa/inet.h>
#include <dlfcn.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>

static void force_reuse(int fd) {
  int one = 1;
  setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
#ifdef SO_REUSEPORT
  setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &one, sizeof(one));
#endif
}

static int pin_port(void) {
  const char *e = getenv("SOLOIST_CONNECT_PORT");
  return e ? atoi(e) : 0; // 0 = disabled, current ephemeral behavior
}

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
  static int (*real_bind)(int, const struct sockaddr *, socklen_t) = 0;
  if (!real_bind)
    real_bind = (void *)dlsym(RTLD_NEXT, "bind");

  if (addr && addr->sa_family == AF_INET &&
      addrlen >= sizeof(struct sockaddr_in)) {
    const struct sockaddr_in *a4 = (const struct sockaddr_in *)addr;
    uint16_t port = ntohs(a4->sin_port);

    // Patch 1: mDNS sharing.
    if (port == 5353)
      force_reuse(sockfd);

    // Patch 2: Connect control-port pinning.
    // Only explicit wildcard port-0 TCP binds; skips loopback so a
    // `--ws 127.0.0.1:<port|0>` listener is never rewritten. Outbound
    // connects don't call bind() explicitly, so they're unaffected.
    int pin = pin_port();
    if (pin > 0 && port == 0 &&
        a4->sin_addr.s_addr == htonl(INADDR_ANY) &&
        a4->sin_addr.s_addr != htonl(INADDR_LOOPBACK)) {
      int type = 0;
      socklen_t tl = sizeof(type);
      getsockopt(sockfd, SOL_SOCKET, SO_TYPE, &type, &tl);
      if (type == SOCK_STREAM) {
        struct sockaddr_in tmp;
        memcpy(&tmp, a4, sizeof(tmp));
        tmp.sin_port = htons((uint16_t)pin);
        return real_bind(sockfd, (struct sockaddr *)&tmp, addrlen);
      }
    }
  }

  return real_bind(sockfd, addr, addrlen);
}
