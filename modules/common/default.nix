{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./ssh.nix
    ./shell.nix
    ./nginx.nix
  ];

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
    htop
    btop
    tmux
    nushell
    helix
    vim
    jq
  ];

  system.disableInstallerTools = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
      "https://fnsh.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "fnsh.cachix.org-1:q4w7VKU3C2TUR9nmPvw8NZWki38JeY7W4njYPo+Xzpw="
    ];
  };
  nix.gc = {
    automatic = true;
    persistent = false;
    dates = "weekly";
    randomizedDelaySec = "2h";
    options = "--delete-older-than 30d";
  };

  boot.tmp.useTmpfs = true;

  networking.nftables.enable = lib.mkDefault true;
  networking.useNetworkd = lib.mkDefault true;
  systemd.network.enable = lib.mkDefault true;

  # Debug Networkd
  # systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=debug";

  networking.firewall = {
    enable = lib.mkDefault true;
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = "$y$j9T$gibKJ7frmuLc.0LBSmC3P1$pAvYHEBBD7u2giIfCy6wg/nc8Wl6zPyQuCuYpYsXsE0";
}
