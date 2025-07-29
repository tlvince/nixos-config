{pkgs, ...}: {
  systemd.services.cros-ec-logger = {
    description = "Log ChromeOS EC messages";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/cat /sys/kernel/debug/cros_ec/console_log";
      StandardOutput = "file:/var/log/cros_ec.log";
    };
  };
}
