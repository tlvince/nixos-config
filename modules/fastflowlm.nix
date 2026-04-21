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
