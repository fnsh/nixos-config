{ pkgs, ... }:
{
  imports = [
    ./fastd.nix
    ./fastd-keys.nix
    ./batman-adv.nix
    ./dns.nix
    ./dhcp.nix
    ./options.nix
    ./mesh-vxlan.nix
    ./meshviewer.nix
    ./domains.nix
    ./network.nix
    ./radvd.nix
    ./yanic.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      batctl
      fastd
    ];

    services.meshGateway.peersDir = "/var/lib/fastd-keys/fastd-keys-master";

    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = 1;
    boot.kernel.sysctl."net.ipv4.conf.default.forwarding" = 1;
  };
}
