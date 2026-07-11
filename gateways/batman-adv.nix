{
  config,
  lib,
  pkgs,
  ...
}:
let
  meshCfg = config.services.meshGateway;

  mkDomainBatInterface =
    domain:
    lib.nameValuePair "20-batadv-dom${toString domain.id}" {
      netdevConfig = {
        Name = domain.batInterface;
        Kind = "batadv";
        MACAddress = domain.mac;
      };
      batmanAdvancedConfig = {
        GatewayMode = "server";
        HopPenalty = 60;
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
        # LinkLocalAddressing = false;
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
      networks = lib.listToAttrs (map mkNodePeerNetwork meshCfg.domains);
      netdevs = lib.listToAttrs (map mkDomainBatInterface meshCfg.domains);
    };

    systemd.services."bat-enable-mff" = {
      script = lib.concatMapStringsSep "\n" (
        dom: "${lib.getExe pkgs.batctl} meshif ${dom.batInterface} mff 1"
      ) meshCfg.domains;

      after = [ "network-online.target" ]; # Wait for networkd to configure bat interfaces
      wantedBy = [ "multi-user.target" ];
    };
  };
}
