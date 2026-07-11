{ ... }:
{
  imports = [
    ./redfish.nix
    ./mikrotik.nix
    ./1nce.nix
  ];

  networking.hostName = "monitoring-proxy";

  system.stateVersion = "25.11";
  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "sd_mod"
    "sr_mod"
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
    "virtiofs"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    "virtio_gpu"
  ];

  systemd.network =
    let
      mgmtMac = "da:ff:d2:31:00:01";
      ipmiMac = "da:ff:c8:31:00:01";
    in
    {
      links = {
        "10-mgmt" = {
          matchConfig.MACAddress = mgmtMac;
          linkConfig.Name = "mgmt";
        };
        "15-ipmi" = {
          matchConfig.MACAddress = ipmiMac;
          linkConfig.Name = "ipmi";
        };
      };

      networks = {
        "10-mgmt" = {
          matchConfig.MACAddress = mgmtMac;
          networkConfig = {
            Address = [
              "fd20:fcc0:ebbe:1:401:1000:210:31/112"
              "172.20.210.31/24"
            ];
            Gateway = [
              "fd20:fcc0:ebbe:1:401:1000:210:1"
              "172.20.210.1"
            ];
          };
        };

        "15-ipmi" = {
          matchConfig.MACAddress = ipmiMac;
          networkConfig = {
            Address = [
              "fd20:fcc0:ebbe:1:401:1000:200:31/112"
              "172.20.200.31/24"
            ];
          };
        };
      };
    };

}
