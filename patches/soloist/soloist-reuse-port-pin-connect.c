// soloist-shim.c — IPv4 only. Combines three patches in one LD_PRELOAD .so.
//
//  1) Share UDP 5353 (mDNS) with avahi-daemon / systemd-resolved: force
//     SO_REUSEADDR (+SO_REUSEPORT) on soloist's 5353 bind() so the kernel
//     delivers multicast copies to both sockets (spotify/soloist#1).
//  2) Pin soloist's ephemeral Connect TCP listener to a fixed port:
//     rewrite explicit bind(0.0.0.0:0, SOCK_STREAM) to
//     $SOLOIST_CONNECT_PORT only — no fallback, so a silent port move can
//     never defeat the single-port firewall pin (spotify/soloist#4). If
//     taken, bind fails EADDRINUSE and soloist fails loudly instead.
//  3) Refuse the crashpad child via kernel-enforced seccomp deny-exec:
//     installed in a constructor (runs after the Nix wrapper re-exec,
//     before main/threads). The handler spawn is the only future exec in
//     this process, so a process-wide deny is precise. Bypass-proof:
//     enforced in the kernel regardless of PLT vs raw-syscall calling
//     convention. Everything else passes through untouched.
#define _GNU_SOURCE
#include <arpa/inet.h>
#include <dlfcn.h>
#include <errno.h>
#include <linux/audit.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <netinet/in.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/socket.h>
#include <sys/syscall.h>
#include <unistd.h>

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

__attribute__((constructor))
static void no_exec(void) {
  if (getenv("SOLOIST_ALLOW_EXEC")) return; // escape hatch
  // Unit-wide LD_PRELOAD loads this .so into helpers too (sh, cat,
  // pkill, sleep...). Only arm the filter in the daemon itself.
  char exe[256];
  ssize_t n = readlink("/proc/self/exe", exe, sizeof(exe) - 1);
  if (n <= 0) return;
  exe[n] = '\0';
  if (!strstr(exe, "soloist")) return; // helper → no filter
  struct sock_filter f[] = {
    BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, nr)),
    BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_execve, 0, 1),
    BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ERRNO | EPERM),
    BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_execveat, 0, 1),
    BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ERRNO | EPERM),
    BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
  };
  struct sock_fprog p = { .len = sizeof(f) / sizeof(f[0]), .filter = f };
  (void)prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &p); // best effort
}
