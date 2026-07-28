{ config, lib, ... }:
let
  meshCfg = config.services.meshGateway;
in
{
  imports = [
    ../modules/yanic.nix
  ];

  services.yanic = {
    enable = true;
    meshviewerExport = true;
    settings = {
      database = {
        delete_after = "3650d";
        delete_interval = "3650d";
      };

      database.connection = {
        influxdb = [
          {
            enable = true;
            address = "https://vm.monitoring.htz.nbg.infra.as62028.de/";
            database = "victoria";
            username = "ffda-metrics";
            password = "@MONITORING_PASSWORD@";
          }
        ];
        respondd = [
          {
            enable = true;
            type = "tcp";
            address = "monitoring.htz.nbg.infra.as62028.de:11001";
          }
        ];
      };

      nodes.save_interval = "5y"; # Save cannot be disabled, set the time very high

      respondd = {
        collect_interval = "1m";
        enable = true;
        synchronize = "1m";
      };

      respondd.sites.default.domains = map (domain: "dom${toString domain.id}") meshCfg.domains;

      respondd.interfaces = map (domain: {
        ifname = domain.batInterface;
        multicast_address = "ff05::2:1001";
        port = 10001;
      }) meshCfg.domains;
    };
  };

  networking.firewall.interfaces = lib.listToAttrs (
    map (
      domain:
      lib.nameValuePair domain.batInterface {
        allowedUDPPorts = [ 10001 ];
      }
    ) meshCfg.domains
  );
}
