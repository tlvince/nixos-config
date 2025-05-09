{
  config,
  secretsPath,
  ...
}: {
  age.secrets.rclone-postgresql.file = "${secretsPath}/rclone-postgresql.age";
  age.secrets.restic-postgresql.file = "${secretsPath}/restic-postgresql.age";

  services.postgresql = {
    enable = true;
    dataDir = "/mnt/ichbiah/home/postgresql/${config.services.postgresql.package.psqlSchema}";
  };

  services.postgresqlBackup = {
    enable = true;
    compression = "none";
    location = "/mnt/ichbiah/home/postgresql-backup";
    startAt = "*-*-* 04:00:00";
  };

  services.restic.backups.postgresql = {
    initialize = true;
    passwordFile = config.age.secrets.restic-postgresql.path;
    paths = [
      "${config.services.postgresqlBackup.location}/all.sql"
    ];
    rcloneConfigFile = config.age.secrets.rclone-postgresql.path;
    repository = "rclone:cm3588_drive:postgresql";
    timerConfig = {
      OnCalendar = "04:30";
      RandomizedDelaySec = "10m";
    };
  };
}
