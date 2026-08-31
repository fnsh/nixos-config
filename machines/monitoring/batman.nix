{ lib, config, ... }:
let
  domains = builtins.attrValues config.fnsh.sites.fffm.domains;

  mkBatDevice =
    domain:
    lib.nameValuePair "20-${domain.batInterface}" {
      netdevConfig = {
        Name = domain.batInterface;
        Kind = "batadv";
      };
      batmanAdvancedConfig = {
        GatewayMode = "off";
        HopPenalty = 60;
        RoutingAlgorithm = "batman-iv";
        OriginatorIntervalSec = "5s";
      };
    };
in
{
  systemd.network.networks."25-batadv-ffda" = {
    matchConfig.Name = "bat-fffm*";
    networkConfig = {
      LinkLocalAddressing = "ipv6";
      IPv6AcceptRA = false;
      DHCP = false;
    };
  };

  systemd.network.netdevs = lib.listToAttrs (map mkBatDevice domains);
}
