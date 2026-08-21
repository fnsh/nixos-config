{ pkgs, ... }:
{
  imports = [
    ./fastd.nix
    ./fastd-keys.nix
    ./batman-adv.nix
    ./bird.nix
    ./dns.nix
    ./dhcp.nix
    ./options.nix
    ./mesh-vxlan.nix
    ./meshviewer.nix
    ./network.nix
    ./radvd.nix
    ./yanic.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      batctl
      fastd
    ];

    services.nginx.enable = true;
    services.meshGateway.peersDir = "/var/lib/fastd-keys/fastd-keys-master";

    services.impermanence.persist = [
      "/var/lib/acme"
    ];

    boot.kernel.sysctl = {
      "net.ipv6.conf.default.accept_ra" = 0;
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.conf.default.forwarding" = 1;
    };
  };
}
