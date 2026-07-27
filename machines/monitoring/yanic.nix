{ ... }:
{
  imports = [
    ../../modules/yanic.nix
  ];

  networking.firewall.interfaces."enp1s0".allowedUDPPorts = [ 10001 ];

  systemd.mounts = [
    {
      description = "Bind mount yanic state directory";
      after = [ "mnt-metrics.mount" ];
      requires = [ "mnt-metrics.mount" ];
      what = "/mnt/metrics/yanic";
      where = "/var/lib/private/yanic";
      type = "none";
      options = "bind";
      wantedBy = [ "multi-user.target" ];
    }
  ];

  systemd.services.yanic = {
    after = [ "var-lib-private-yanic.mount" ];
    requires = [ "var-lib-private-yanic.mount" ];
  };

  services.yanic = {
    enable = true;
    meshviewerExport = true;

    settings = {
      database = {
        delete_after = "3650d";
        delete_interval = "3650d";
      };
      database.connection.influxdb = [
        {
          enable = true;
          address = "https://vm.monitoring.htz.nbg.infra.as62028.de/";
          database = "victoria";
          username = "ffda-metrics";
          password = "@MONITORING_PASSWORD@";
        }
      ];
      respondd = {
        enable = true;
        collect_interval = "1m"; # Doesn't do anything, but is required for yanic to start
      };

      # "respondd.sites.default".domains = map (domain: "dom${toString domain.id}") meshCfg.domains;
      respondd.interfaces = [
        {
          ifname = "enp1s0";
          port = 10001;
          send_no_request = true;
          ip_address = "::";
        }
      ];

      nodes = {
        offline_after = "10m";
        prune_after = "7d";
        save_interval = "5s";
        state_path = "/var/lib/yanic/state.json";
      };
    };
  };
}
