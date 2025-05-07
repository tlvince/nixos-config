{
  config,
  pkgs,
  secretsPath,
  ...
}: let
  scripts = import ../scripts.nix {
    inherit config pkgs;
  };

  smartdNotify = pkgs.writeScriptBin "smartd-notify.sh" ''
    TITLE="SMART error: $SMARTD_FAILTYPE" MESSAGE="$SMARTD_MESSAGE" "${scripts.notify}/bin/notify"
  '';

  smartdConf = pkgs.writeText "smartd.conf" ''
    DEVICESCAN -a -n standby,q -s S/../../7/05 -m <nomailer> -M exec ${smartdNotify}
  '';
in {
  age.secrets.notify.file = "${secretsPath}/notify.age";

  systemd.services.smartd = {
    description = "S.M.A.R.T. Daemon";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.smartmontools}/sbin/smartd --no-fork --configfile=${smartdConf}";
    };
  };
}
