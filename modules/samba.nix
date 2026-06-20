{ config, ... }:
{
  services.avahi = {
    extraServiceFiles = {
      timemachine = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
            <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=TimeCapsule8,119</txt-record>
          </service>
          <service>
            <type>_adisk._tcp</type>
            <txt-record>dk0=adVN=timemachine,adVF=0x82</txt-record>
            <txt-record>sys=waMa=0,adVF=0x100</txt-record>
          </service>
        </service-group>
      '';
    };
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        "workgroup" = "FILO";
        "server string" = config.networking.hostName;

        "access based share enum" = "yes";
        "disable netbios" = "yes";
        "ea support" = "yes";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "map to guest" = "Never";
        "min protocol" = "SMB3_11";
        "restrict anonymous" = "2";
        "security" = "user";
        "server role" = "standalone";
        "server smb encrypt" = "required";

        # Disable file logging, log only important auth failures
        "log file" = "/dev/null";
        "log level" = "0 auth:2 passdb:2";
        "logging" = "systemd";
        "max log size" = "0";

        # Never map anything to the excutable bit
        "map archive" = "no";
        "map system" = "no";
        "map hidden" = "no";

        # Disable printing
        "disable spoolss" = "yes";
        "load printers" = "no";
        "printcap name" = "/dev/null";
        "show add printer wizard" = "no";
        "printable" = "no";
        "printing" = "bsd";

        # TimeMachine
        # https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:nfs_aces" = "no";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
      };

      photos = {
        "browseable" = "yes";
        "comment" = "Photos";
        "path" = "/mnt/ichbiah/home/photos";
        "valid users" = "zan tlv";
        "writeable" = "yes";
      };

      shared = {
        "browseable" = "yes";
        "comment" = "Shared";
        "create mask" = "0660";
        "directory mask" = "0755";
        "force group" = config.users.groups.nas.name;
        "path" = "/mnt/ichbiah/home/shared";
        "valid users" = "zan tlv";
        "writeable" = "yes";
      };

      tdrive = {
        "browseable" = "yes";
        "comment" = "TDrive";
        "path" = "/mnt/ichbiah/home/tlv";
        "valid users" = "tlv";
        "writeable" = "yes";
      };

      timemachine = {
        "browseable" = "yes";
        "comment" = "Time Machine";
        "fruit:time machine" = "yes";
        "path" = "/mnt/ichbiah/home/time-machine";
        "valid users" = "zan";
        "writeable" = "yes";
      };

      zdrive = {
        "browseable" = "yes";
        "comment" = "ZDrive";
        "path" = "/mnt/ichbiah/home/zan";
        "valid users" = "zan";
        "writeable" = "yes";
      };
    };
  };
}
