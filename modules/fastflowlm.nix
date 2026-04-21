{
  pkgsAmdgpu,
  ...
}:
{
  systemd.services.flm = {
    description = "FastFlowLM Server";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgsAmdgpu.fastflowlm}/bin/flm serve --host 127.0.0.1 --port 52625 --quiet";
      # for /dev/accel/* (npu) access
      # https://github.com/systemd/systemd/blob/b3d8fc43e9cb531d958c17ef2cd93b374bc14e8a/rules.d/50-udev-default.rules.in#L63
      SupplementaryGroups = [ "render" ];
      User = "flm";

      Environment = [
        "FLM_MODEL_PATH=/var/lib/flm"
        "XILINX_XRT=${pkgsAmdgpu.xrt-lib-with-xdna}"
      ];

      KillSignal = "SIGINT";
      LimitMEMLOCK = "infinity";
      Restart = "on-failure";
      RestartSec = 5;
      StateDirectory = "flm";
      SyslogIdentifier = "flm";

      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectSystem = "full";
      ProtectHome = true;
      RestrictRealtime = true;
      RestrictNamespaces = true;
      LockPersonality = true;
    };
  };

  users.users.flm = {
    group = "flm";
    home = "/var/lib/flm";
    isSystemUser = true;
  };

  users.groups.flm = { };
}
