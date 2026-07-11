{
  lib,
  pkgs,
  ...
}:
{
  # "Hardware" options
  services.qemuGuest.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
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
  ];

  # Default system config
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    git
    iproute2
    tcpdump
  ];

  system.disableInstallerTools = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking.nftables.enable = lib.mkDefault true;
  networking.useNetworkd = lib.mkDefault true;
  systemd.network.enable = lib.mkDefault true;

  # Debug Networkd
  # systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=debug";

  networking.firewall = {
    enable = lib.mkDefault true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    openFirewall = true;
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = "$y$j9T$gibKJ7frmuLc.0LBSmC3P1$pAvYHEBBD7u2giIfCy6wg/nc8Wl6zPyQuCuYpYsXsE0";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfwrD05VmFMorcHkXOnJqsEyougYiYAeg82zH8rw52+ noxnox for ffda"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3LjfcgNu9tvj6eMtYWiNwRJR4cGALF0590FswEkrlL liv@ffda"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDM6d1E1gczThXTfwGLuzbo9t3xUdpp53wi9Ya5IyxUlB0rNO9Nc2mKvI99Pp/4POan6vAj+dyEA9ve5WtYfOKYrwHHKnUsuSxDMORYhnGjuzrjM5hdJvVgtfmGV9ilC419Jy3+nxY2jZ992hCd/IP8i5epIoZIDDJ6QaSAVKIt3YZWpKxzalty5ugBlknkvaX5q7n32qIVx6cxpNAPjXVJ/rk1tzKldXkNCL36HjHZhPCqwzOVpLbjrGfEonFuU1sSR+8UfzlD7JeOSrwUck6MGEGFvCJVG/NqfNTe3tlMfc4bV69U9b4bsLeCVDXNAaxqByZoNrs/7jAmRdBeJBnylhvKdTb/lF3Nhs/Vor4H/ih+XL1suzu0z4lC1MiAuZrgBL+vQmLGpbjaKD1Px7awQuTrQ8Y6Faed76L0a22bzx/+2yN32VJ5if7cjg72gCzffHwZkjU8tnFuNAGGMTz6EQCljFMwJQTjYaxKz+bp559jO2Av5WlWNeasB2qZP8m/IRDTUt7jpcS9EZUWt66dTP6Xt+m2rXlyzREsekGiYp+4Ew41LNmAme+jhHUb9NlvtuxNxD555IzscSjwxVraNhfiaQbh6mGz3HM6fPYe7R7C8An2xo+FW5W2mq9n2OnmUDjx9pGIn24c2ji8oT9m9lqclXI1tbP9Nw5b1aKp8Q== blocktrron_freifunk"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILo6qga0Xl+/Epn9NgNNZMWmXGVAa7A34WaG5YLOprqe dbauer@dbauer-t470"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDT5g1/AyHrZh9cJ2R2dXRKKrc3YV0DfT4B5QExCH0st skorpy"
  ];
}
