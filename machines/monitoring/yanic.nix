{ lib, config, ... }:
{
  imports = [
    ../../modules/yanic.nix
  ];

  networking.firewall.extraInputRules =
    let
      gwAddrs = lib.concatMapStringsSep "," lib.fnsh.gwAddr6 (lib.range 1 8);
    in
    ''
      iifname "enp1s0" ip6 saddr { ${gwAddrs} } tcp dport 11001 accept
    '';

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
        tcp_listen = [ "[::]:11001" ];
      };
      nodes = {
        offline_after = "10m";
        prune_after = "7d";
        save_interval = "5s";
        state_path = "/var/lib/yanic/state.json";
      };
    };
  };
}
