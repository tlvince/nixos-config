{config, ...}: {
  services.samba = {
    enable = true;
    openFirewall = true;
    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        "workgroup" = "FILO";
        "server string" = config.networking.hostName;

        "ea support" = "yes";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "logging" = "systemd";
        "map to guest" = "Never";
        "min protocol" = "SMB3_02";
        "restrict anonymous" = "2";
        "security" = "user";

        # Disable Printing
        "disable spoolss" = "yes";
        "load printers" = "no";
        "printcap name" = "/dev/null";
        "show add printer wizard" = "no";
        "printable" = "no";
        "printing" = "bsd";

        # TimeMachine
        # https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
      };

      photos = {
        "browseable" = "yes";
        "comment" = "Photos";
        "path" = "/mnt/shares/time-machine";
        "valid users" = "zan tlv";
        "writeable" = "yes";
      };

      shared = {
        "browseable" = "yes";
        "comment" = "Shared";
        "create mask" = "0660";
        "directory mask" = "0755";
        "force group" = config.users.groups.nas.name;
        "path" = "/mnt/shares/shared";
        "valid users" = "zan tlv";
        "writeable" = "yes";
      };

      timemachine = {
        "browseable" = "yes";
        "comment" = "Time Machine";
        "fruit:time machine" = "yes";
        "path" = "/mnt/shares/time-machine";
        "valid users" = "zan";
        "writeable" = "yes";
      };

      zdrive = {
        "browseable" = "yes";
        "comment" = "ZDrive";
        "path" = "/mnt/shares/zan";
        "valid users" = "zan";
        "writeable" = "yes";
      };
    };
  };
}
