{ pkgs, ... }:
{
  imports = [
    ./fastd.nix
    ./batman-adv.nix
    ./dns.nix
    ./dhcp.nix
    ./options.nix
    ./mesh-vxlan.nix
    ./meshviewer.nix
    ../modules/git-mirror.nix
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

    services.meshGateway.peersDir = "/var/lib/git-mirrors/fastd-keys";

    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = 1;
    boot.kernel.sysctl."net.ipv4.conf.default.forwarding" = 1;
  };
}
