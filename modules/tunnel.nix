{
  config,
  keys,
  pkgs,
  secrets,
  secretsPath,
  ...
}:
let
  knownHosts = pkgs.writeText "tunnel-known_hosts" ''
    kunkun ${keys.kunkun}
  '';

  sshConfig = pkgs.writeText "ssh-config" ''
    Host kunkun
      BatchMode yes
      ConnectTimeout 15
      ExitOnForwardFailure yes
      GlobalKnownHostsFile /dev/null
      HostKeyAlias kunkun
      HostName ${secrets.kunkun}
      IdentitiesOnly yes
      RemoteForward 8080 home-assistant.filo.uk:443
      ServerAliveInterval 60
      SessionType none
      StrictHostKeyChecking yes
      UpdateHostKeys no
      User cm3588
      UserKnownHostsFile ${knownHosts}
  '';
in
{
  age.secrets."tunnel-cm3588" = {
    file = "${secretsPath}/tunnel-cm3588.age";
    mode = "0400";
  };

  systemd.services."tunnel@kunkun" = {
    after = [ "systemd-networkd-wait-online.service" ];
    requires = [ "systemd-networkd-wait-online.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      LoadCredential = [ "tunnel_key:${config.age.secrets."tunnel-cm3588".path}" ];
      ExecStart = "${pkgs.openssh}/bin/ssh -F ${sshConfig} -i %d/tunnel_key %i";
      Restart = "on-failure";
      RestartMaxDelaySec = 160;
      RestartSec = 10;
      RestartSteps = 4;
      StateDirectory = "tunnel";
      StateDirectoryMode = "0700";
      SyslogIdentifier = "tunnel";
      UMask = "0077";
      User = "tunnel";
      Group = "tunnel";

      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK" # glibc resolver
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];

      # Reduce journal noise
      IOAccounting = false;
      IPAccounting = false;
      MemoryAccounting = false;
      TasksAccounting = false;
    };
    unitConfig = {
      StartLimitIntervalSec = 0; # retry forever
    };
  };
  users.users.tunnel = {
    group = "tunnel";
    home = "/var/lib/tunnel";
    isSystemUser = true;
  };
  users.groups.tunnel = { };
}
