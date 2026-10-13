{ ... }:
{
  networking.hostName = "swooter2";

  system.stateVersion = "26.05";

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9fb9b282-6d93-4250-94f5-9477a4bf94b5";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FF34-797F";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
}
