{
  config,
  pkgs,
  secretsPath,
  ...
}: let
  scripts = import ../scripts.nix {
    inherit config pkgs;
  };

  dmesgd = pkgs.writeShellScriptBin "dmesgd" ''
    ${pkgs.systemd}/bin/journalctl --dmesg --follow --lines=0 --output=cat --priority=warning | \
    while read MESSAGE; do
      TITLE="${config.networking.hostName} kernel alert" MESSAGE="$MESSAGE" "${scripts.notify}/bin/notify"
    done
  '';
in {
  age.secrets.notify.file = "${secretsPath}/notify.age";

  systemd.services.dmesgd = {
    description = "Monitor kernel diagnostic messages";
    wantedBy = ["multi-user.target"];
    after = ["systemd-journald.socket"];
    serviceConfig = {
      ExecStart = "${dmesgd}/bin/dmesgd";
      LoadCredential = "notify:${config.age.secrets.notify.path}";
      Restart = "on-failure";
      RestartSec = 10;
      SupplementaryGroups = ["systemd-journal"];

      # TODO: Use NixOS hardened systemd helper
      # labels: systemd
      CapabilityBoundingSet = [""];
      DynamicUser = true;
      KeyringMode = "private";
      LockPersonality = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = "AF_INET";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      UMask = 077;
    };
  };
}
