{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}: let
  scripts = import ../scripts.nix {
    inherit config pkgs;
  };

  smartdNotify = pkgs.writeShellScriptBin "smartd-notify" ''
    TITLE="SMART error: $SMARTD_FAILTYPE" MESSAGE="$SMARTD_MESSAGE" "${scripts.notify}/bin/notify"
  '';

  smartdConf = let
    opts = ''-a -n standby,q -s S/../../7/05 -m <nomailer> -M exec "${smartdNotify}/bin/smartd-notify"'';
  in
    pkgs.writeText "smartd.conf" (
      if config.tlvince.smartd.devices == []
      then ''DEVICESCAN ${opts}''
      else lib.concatMapStringsSep "\n" (device: "${device} ${opts}") config.tlvince.smartd.devices
    );
in {
  options = {
    tlvince.smartd.devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "An optional list of devices for smartd to monitor, otherwise all.";
      example = ["/dev/nvme0" "/dev/nvme1"];
    };
  };

  config = {
    age.secrets.notify.file = "${secretsPath}/notify.age";

    systemd.services.smartd = {
      description = "S.M.A.R.T. Daemon";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.smartmontools}/sbin/smartd --no-fork --configfile=${smartdConf}";
        LoadCredential = "notify:${config.age.secrets.notify.path}";
        Type = "notify";
      };
    };
  };
}
