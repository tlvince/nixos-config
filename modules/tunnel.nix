{
  pkgs,
  secrets,
  ...
}: let
  # TODO: Replace hardcoded credentials path with CREDENTIALS_DIRECTORY
  # labels: module:tunnel, systemd
  sshConfig = pkgs.writeText "ssh-config" ''
    Host kunkun
      ExitOnForwardFailure yes
      HostName ${secrets.kunkun}
      IdentityFile /run/credentials/tunnel@kunkun.service/ssh_host_key
      RemoteForward 8080 home-assistant.filo.uk:443
      ServerAliveInterval 60
      SessionType none
      StrictHostKeyChecking accept-new
      User cm3588
  '';
in {
  systemd.services."tunnel@kunkun" = {
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      LoadCredential = ["ssh_host_key:/etc/ssh/ssh_host_ed25519_key"];
      ExecStart = "${pkgs.openssh}/bin/ssh -F ${sshConfig} %i";
      Restart = "on-failure";
      SyslogIdentifier = "tunnel";
      User = "tunnel";
      Group = "tunnel";

      # Reduce journal noise
      CPUAccounting = false;
      IOAccounting = false;
      IPAccounting = false;
      MemoryAccounting = false;
      TasksAccounting = false;
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/tunnel 0750 tunnel tunnel"
    "d /var/lib/tunnel/.ssh 0700 tunnel tunnel"
  ];
  users.users.tunnel = {
    createHome = true;
    group = "tunnel";
    home = "/var/lib/tunnel";
    isSystemUser = true;
  };
  users.groups.tunnel = {};
}
