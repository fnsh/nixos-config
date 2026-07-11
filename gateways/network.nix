{ config, lib, ... }:
let
  meshCfg = config.services.meshGateway;

  poolOffset = 1 + (meshCfg.gwId * 2);
  gwAddr4 = "194.180.249.${toString poolOffset}/24";
  gwAddr6 = "2a13:fcc0:ebbe:1:401:1000:110:${toString poolOffset}/112";

  clientPoolAddr = "194.180.249.${toString (poolOffset + 1)}";

  mkMac = vlan: "da:ff:${lib.toHexString vlan}:2${toString meshCfg.gwId}:00:01";

  nftBatInterfaces = lib.concatMapStringsSep "," (
    domain: "\"${domain.batInterface}\""
  ) meshCfg.domains;

  mkDomainNetwork =
    domain:
    lib.nameValuePair "20-batadv-dom${toString domain.id}" {
      matchConfig.Name = domain.batInterface;
      networkConfig = {
        IPv6AcceptRA = false;
        DHCP = false;
      };
      address = [
        "${domain.subnet4.gatewayAddress}/20"
        domain.subnet6.public.gatewayAddress
        domain.subnet6.ula.gatewayAddress
      ];
    };
in
{
  config = {
    systemd.network = {
      links = {
        "10-mgmt" = {
          matchConfig.MACAddress = mkMac 210;
          linkConfig.Name = "mgmt";
          linkConfig.MTUBytes = 9000;
        };

        "10-frontend" = {
          matchConfig.MACAddress = mkMac 110;
          linkConfig.Name = "frontend";
          linkConfig.MTUBytes = 9000;
        };

        "10-mesh" = {
          matchConfig.MACAddress = mkMac 130;
          linkConfig.Name = "mesh";
          linkConfig.MTUBytes = 9000;
        };
      };

      netdevs."25-anycast-dev" = {
        netdevConfig = {
          Kind = "dummy";
          Name = "anycast";
        };
      };

      networks = (lib.listToAttrs (map mkDomainNetwork meshCfg.domains)) // {
        "25-anycast" = {
          matchConfig.Name = "anycast";
          address = [
            "194.180.249.32/29"
            "2a13:fcc0:2ed9:ffff::32/64"
          ];
        };

        "10-mgmt" = {
          matchConfig.MACAddress = mkMac 210;
          networkConfig = {
            Address =
              let
                hostPart = 20 + meshCfg.gwId;
              in
              [
                "fd20:fcc0:ebbe:1:401:1000:210:${toString hostPart}/112"
                "172.20.210.${toString hostPart}/24"
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

        "10-frontend" = {
          matchConfig.MACAddress = mkMac 110;
          networkConfig = {
            Address = [
              gwAddr4
              gwAddr6
              "${clientPoolAddr}/24"
            ];
            Gateway = [
              "194.180.249.1"
              "2a13:fcc0:ebbe:1:401:1000:110:1"
            ];
          };
          routes = [
            {
              # Nat64 gateway
              Gateway = "2a13:fcc0:ebbe:1:401:1000:110:19";
              Destination = "64:ff9b:1:da:ff::/96";
            }
          ];
        };
        "10-mesh" = {
          matchConfig.MACAddress = mkMac 130;
          networkConfig = {
            LinkLocalAddressing = "ipv6";
            IPv6AcceptRA = false;
            DHCP = false;
            VXLAN = map (domain: domain.vxlan.interface) meshCfg.domains;
          };
        };
      };
    };

    networking.firewall.checkReversePath = false;
    networking.firewall.filterForward = false;

    networking.nftables.tables."gw-forward" = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority filter; policy drop;

          meta nfproto ipv4 tcp flags syn tcp option maxseg size set 1240
          meta nfproto ipv6 tcp flags syn tcp option maxseg size set 1220

          ct state vmap { invalid : jump forward-allow, established : accept, related : accept, new : jump forward-allow, untracked : jump forward-allow }
        }

        chain forward-allow {
          icmpv6 type != { router-renumbering, 139 } accept comment "Accept all ICMPv6 messages except renumbering and node information queries (type 139).  See RFC 4890, section 4.3."

          iifname { ${nftBatInterfaces} } oifname "frontend" accept
          iifname "frontend" oifname { ${nftBatInterfaces} } accept
          iifname { ${nftBatInterfaces} } oifname { ${nftBatInterfaces} } accept
        }
      '';
    };

    networking.nftables.tables."nat" = {
      family = "inet";
      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;
        }

        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          ip saddr 10.0.0.0/8 snat to ${clientPoolAddr}
        }
      '';
    };
  };
}
