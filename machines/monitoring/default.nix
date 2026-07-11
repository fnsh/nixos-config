{ ... }:
{
  imports = [
    ./disko.nix
    ./victoria.nix
    ./victoria-backup.nix
    ./grafana.nix
    ./collector.nix
    ./ping.nix
  ];

  networking.hostName = "htz-monitoring";
  system.stateVersion = "25.11";

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  systemd.network.networks = {
    "10-net" = {
      matchConfig.PermanentMACAddress = "92:00:07:d9:b8:fa";

      networkConfig = {
        DHCP = "ipv4";
        LinkLocalAddressing = "ipv6";
        Address = "2a01:4f8:1c19:cfee::1/64";
        DNS = [
          "2a01:4ff:ff00::add:2"
          "2a01:4ff:ff00::add:1"
        ];
      };
      routes = [
        {
          Destination = "::/0";
          Gateway = "fe80::1";
          GatewayOnLink = true;
        }
      ];
    };
  };

  # Web services
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@as62028.de";

  services.nginx = {
    enable = true;
    enableReload = true;
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
