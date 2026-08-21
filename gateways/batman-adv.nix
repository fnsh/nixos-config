{
  config,
  lib,
  pkgs,
  ...
}:
let
  meshCfg = config.services.meshGateway;
  domains = builtins.attrValues config.fnsh.sites.fnsh.domains;

  mkDomainBatInterface =
    domain:
    lib.nameValuePair "20-batadv-dom${toString domain.id}" {
      netdevConfig = {
        Name = domain.batInterface;
        Kind = "batadv";
        MACAddress = "da:ff:00:00:0${toString meshCfg.gwId}:${lib.fnsh.paddedHexOctet domain.id}";
      };
      batmanAdvancedConfig = {
        GatewayMode = "server";
        HopPenalty = 5;
        RoutingAlgorithm = "batman-iv";
        OriginatorIntervalSec = "5s";
      };
    };

  mkNodePeerNetwork =
    domain:
    lib.nameValuePair "45-l2tp-peers-dom${toString domain.id}" {
      matchConfig.Name = "fastd-dom${toString domain.id}-*";
      networkConfig = {
        BatmanAdvanced = domain.batInterface;
        Address = [
          # Required for Server Side Rate Limiting
          "fe80::f421:d:1/64"
        ];
        LinkLocalAddressing = false;
        IPv6AcceptRA = false;
        DHCP = false;
      };
    };
in
{
  config = {
    boot.kernelModules = [ "batman_adv" ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.batman_adv
    ];

    environment.systemPackages = [ pkgs.batctl ];

    systemd.network = {
      networks = lib.listToAttrs (map mkNodePeerNetwork domains);
      netdevs = lib.listToAttrs (map mkDomainBatInterface domains);
    };

    services.batman-route-sync = {
      enable = true;
      meshInterfaces = map (dom: dom.batInterface) domains;
      vpnPrefixes = [
        "fastd"
      ];
      targetRouteTable = 1337;
    };

    networking.localCommands = lib.concatMapStringsSep "\n" (
      dom: "${lib.getExe pkgs.batctl} meshif ${dom.batInterface} mff 1"
    ) domains;
  };
}
