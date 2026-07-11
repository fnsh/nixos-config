{ pkgs, ... }:
let
  nat64prefix = "64:ff9b:1:da:ff::";
  nat64prefixlen = "/96";
  siitDevice = "siit0";
  v4ClatAddr = "192.0.2.1";
  v4MappedClatAddr = "c000:201";

  ipxlat-src = pkgs.fetchgit {
    branchName = "main";
    url = "https://codeberg.org/IPv6-Monostack/ipxlat-net-next.git";
    outputHash = "sha256-erYa3MsasHrbrYkKFLp6AxXveAVjasmEBPR4BESA2kA=";
  };

  ipxlat-ctl-ynl = pkgs.writeShellApplication {
    name = "ipxlat-ctl-ynl";

    runtimeInputs = [
      (pkgs.python3.withPackages (p: [
        p.yamlcore
        p.jsonschema
      ]))
      pkgs.jq
      pkgs.gawk
    ];

    runtimeEnv.KERNEL_DIR = ipxlat-src;

    # https://codeberg.org/IPv6-Monostack/ipxlat/src/branch/main/ipxlat-ctl-ynl
    text = builtins.readFile ./ipxlat-ctl-ynl;
  };
in
{
  networking.localCommands = ''
    # Re-init ipxlat on restart
    [ -e /sys/module/ipxlat ] && ${pkgs.kmod}/bin/rmmod ipxlat
    ${pkgs.kmod}/bin/modprobe ipxlat

    ip link add ${siitDevice} type ipxlat
    ${ipxlat-ctl-ynl}/bin/ipxlat-ctl-ynl ${siitDevice} xlat-prefix6 ${nat64prefix}${nat64prefixlen}
  '';

  systemd.network.links."15-ipxlat" = {
    matchConfig.Name = siitDevice;
    linkConfig.MTUBytes = 9000;
  };
  systemd.network.networks."15-ipxlat" = {
    matchConfig.Name = siitDevice;
    networkConfig.LinkLocalAddressing = false;

    routes = [
      { Destination = "${nat64prefix}${nat64prefixlen}"; }
      { Destination = v4ClatAddr; }
    ];
  };

  networking.firewall.checkReversePath = "loose";

  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = 1;
  boot.kernel.sysctl."net.ipv4.conf.default.forwarding" = 1;

  networking.firewall.filterForward = true;
  networking.firewall.extraForwardRules = ''
    # Forward only between frontend an translator
    iifname {"frontend", "siit0"} oifname {"frontend", "siit0"} accept
  '';

  networking.nftables.tables = {
    "nat64" = {
      family = "ip6";
      content = ''
        chain postrouting {
                type nat hook postrouting priority filter; policy accept;
                oifname "${siitDevice}" snat to ${nat64prefix}${v4MappedClatAddr}
        }
      '';
    };

    "nat46" = {
      family = "ip";
      content = ''
        chain postrouting {
                type nat hook postrouting priority filter; policy accept
                iifname "${siitDevice}" masquerade;
        }
      '';
    };
  };
}
