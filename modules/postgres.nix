{config, ...}: {
  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
    compressionLevel = 3;
    startAt = "*-*-* 04:00:00";
  };
}
