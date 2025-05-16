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
    ${pkgs.systemd}/bin/journalctl --dmesg --follow --lines=0 --output=cat --priority=4 | \
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
      DynamicUser = true;
      ExecStart = "${dmesgd}/bin/dmesgd";
      LoadCredential = "notify:${config.age.secrets.notify.path}";
      Restart = "on-failure";
      RestartSec = 10;
      SupplementaryGroups = ["systemd-journal"];
    };
  };
}
