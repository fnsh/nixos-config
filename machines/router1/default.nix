{ lib, pkgs, ... }:
let
  mkMac =
    vlan:
    if vlan > 256 then
      "da:00:0${lib.toHexString (builtins.div vlan 256)}:${
        lib.toHexString (vlan - (256 * (builtins.div vlan 256)))
      }:00:01"
    else
      "da:ff:${lib.toHexString vlan}:11:00:01";

  mkLinkConfig =
    { Name, MACAddress }:
    {
      matchConfig.MACAddress = MACAddress;
      linkConfig = {
        Name = Name;
        GenericSegmentationOffload = false;
        LargeReceiveOffload = false;
        GenericReceiveOffload = false;
        TCPSegmentationOffload = false;
      };
    };

  public_ip_nets = [
    # Own
    "2a13:fcc0::/29"
    "194.180.249.0/24"
    # Configo
    "217.71.220.139/32"
    "2a00:1fe8:1::39/128"
    # Inter.Link
    "81.27.69.85/32"
    "2a11:4140:9002::31/128"
  ];
in
{
  networking.hostName = "router01";

  environment.systemPackages = with pkgs; [
    wireguard-tools
    mtr
  ];

  systemd.network = {
    config.networkConfig = {
      ManageForeignRoutes = false;
    };
    links = {
      "10-mgmt" = mkLinkConfig {
        Name = "mgmt";
        MACAddress = mkMac 210;
      };

      "20-frontend" = mkLinkConfig {
        Name = "frontend";
        MACAddress = mkMac 110;
      };

      "30-configo-port" = mkLinkConfig {
        Name = "configo-port";
        MACAddress = mkMac 21;
      };

      "300-neanderfunk" = mkLinkConfig {
        Name = "neanderfunk";
        MACAddress = mkMac 300;
      };
    };

    networks = {
      "10-mgmt" = {
        matchConfig.MACAddress = mkMac 210;

        networkConfig = {
          Address = [
            "fd20:fcc0:ebbe:1:401:1000:210:11/112"
            "172.20.210.11/24"
          ];
          Gateway = [
            "fd20:fcc0:ebbe:1:401:1000:210:1"
            "172.20.210.1"
          ];
          DNS = "8.8.8.8";
        };
      };

      "20-frontend" = {
        matchConfig.MACAddress = mkMac 110;

        networkConfig = {
          Address = [
            "194.180.249.1/27"
            "2a13:fcc0:ebbe:1:401:1000:110:1/112"
          ];
          VRF = "vrf-as62028";
        };
      };

      "30-configo-port" = {
        matchConfig.MACAddress = mkMac 21;

        networkConfig = {
          LinkLocalAddressing = false;
          VLAN = [
            "configo-peer"
            "interlink-peer"
          ];
        };
      };

      "31-configo-peer" = {
        matchConfig.MACAddress = mkMac 26;

        networkConfig = {
          Address = [
            "217.71.220.139/31"
            "2a00:1fe8:1::39/127"
          ];
          VRF = "vrf-as62028";
        };
      };

      "32-interlink-peer" = {
        matchConfig.MACAddress = mkMac 27;

        networkConfig = {
          Address = [
            "81.27.69.85/31"
            "2a11:4140:9002::31/127"
          ];
          VRF = "vrf-as62028";
        };
      };

      "300-neanderfunk" = {
        matchConfig.MACAddress = mkMac 300;

        networkConfig = {
          Address = [
            "194.180.249.41/29"
            "2a13:fcc0:3000:300::1/64"
          ];
          VRF = "vrf-as62028";
        };
      };
    };

    netdevs = {
      "31-configo-peer" = {
        netdevConfig = {
          Name = "configo-peer";
          Kind = "vlan";
          MACAddress = mkMac 26;
        };
        vlanConfig = {
          Id = 26;
        };
      };
      "32-interlink-peer" = {
        netdevConfig = {
          Name = "interlink-peer";
          Kind = "vlan";
          MACAddress = mkMac 27;
        };
        vlanConfig = {
          Id = 475;
        };
      };
      "51-vrf-as62028" = {
        netdevConfig = {
          Name = "vrf-as62028";
          Kind = "vrf";
        };
        vrfConfig = {
          Table = 100;
        };
      };
    };
  };

  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = builtins.readFile ./firewall.nft;
  };

  services.bird = {
    enable = true;
    config = builtins.readFile ./bird.conf;
  };

  services.prometheus.exporters.bird = {
    enable = true;
    port = 9324;
    listenAddress = "127.0.0.1";
  };

  services.opentelemetry-collector.settings = {
    receivers.prometheus.config.scrape_configs = [
      {
        job_name = "bird";
        scrape_interval = "60s";
        static_configs = [ { targets = [ "127.0.0.1:9324" ]; } ];
      }
    ];

    service.pipelines."metrics".receivers = [ "prometheus" ];
  };

  boot.kernel.sysctl = {
    # Enable routing/forwarding
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;

    # Disable reverse path filtering
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;

    # Enable RP-Filtering for frontend interface to prevent IP spoofing
    "net.ipv4.conf.frontend.rp_filter" = 1;
    "net.ipv6.conf.frontend.rp_filter" = 1;

    # Receive / Sending buffer
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # Conntrack table size
    "net.netfilter.nf_conntrack_max" = 262144;
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
