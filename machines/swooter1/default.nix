{ ... }:
{
  networking.hostName = "swooter1";

  system.stateVersion = "26.05";

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/be97695d-43ca-48b5-a29b-b7a62d0f6127";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1C9A-5057";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
}
