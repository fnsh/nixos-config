{ ... }:
{
  imports = [
    ./icmp_metrics.nix
    ./ipxlat_kernel.nix
    ./dns64.nix
    ./nat64.nix
  ];

  system.stateVersion = "26.05";

  networking.hostName = "nat64";

  systemd.network.links = {
    "10-mgmt" = {
      matchConfig.MACAddress = "da:ff:d2:16:00:64";
      linkConfig.Name = "mgmt";
      linkConfig.MTUBytes = 9000;
    };

    "10-frontend" = {
      matchConfig.MACAddress = "da:ff:6e:16:00:64";
      linkConfig.Name = "frontend";
      linkConfig.MTUBytes = 9000;
    };
  };

  systemd.network.networks = {
    "10-mgmt" = {
      matchConfig.MACAddress = "da:ff:d2:16:00:64";

      networkConfig = {
        Address = [
          "fd20:fcc0:ebbe:1:401:1000:210:19/112"
          "172.20.210.19/24"
        ];
      };

      routes = [
        {
          Gateway = "172.20.210.1";
          Destination = "172.20.0.0/16";
        }
        {
          Gateway = "fd20:fcc0:ebbe:1:401:1000:210:1";
          Destination = "fd20:fcc0:ebbe:1:401:1000::/96";
        }
      ];
    };

    "20-frontend" = {
      matchConfig.MACAddress = "da:ff:6e:16:00:64";

      networkConfig = {
        Address = [
          "194.180.249.19/27"
          "2a13:fcc0:ebbe:1:401:1000:110:19/112"
        ];

        Gateway = [
          "2a13:fcc0:ebbe:1:401:1000:110:1"
          "194.180.249.1"
        ];
      };
    };
  };
}
