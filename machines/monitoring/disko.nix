{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_118621041";
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
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      # Separate block volume for storing metrics
      metrics = {
        device = "/dev/disk/by-id/scsi-0HC_Volume_105952364";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/metrics";
          # https://docs.victoriametrics.com/victoriametrics/bestpractices/#filesystem
          extraArgs = [ "-O 64bit,huge_file,extent -T huge" ];
        };
      };
    };
  };
}
