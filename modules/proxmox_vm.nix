{ ... }:
{
  imports = [
    ./impermanence.nix
  ];

  networking.firewall.interfaces."mgmt".allowedTCPPorts = [ 22 ];

  # No logging to disk
  services.journald.storage = "volatile";

  # Disable ssh access logs
  services.logrotate.enable = false;
  systemd.tmpfiles.rules = [
    "L /var/log/wtmp - - - - /dev/null"
    "L /var/log/btmp - - - - /dev/null"
    "L /var/log/lastlog - - - - /dev/null"
  ];

  services.impermanence = {
    enable = true;
    persist = [
      "/nix"
      "/etc/ssh"
    ];
  };
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=25%"
      "mode=755"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/mnt/persist".neededForBoot = true;
  disko.devices = {
    disk = {
      main = {
        # ID is the same for all VMs
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "noatime"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/persist";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
