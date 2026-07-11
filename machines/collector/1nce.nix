{
  config,
  pkgs,
  ...
}:
let
  once-exporter = pkgs.callPackage ../../pkgs/1nce-exporter { };
in
{
  age.secrets.once_username = {
    file = ../../secrets/once_username.age;
    mode = "666";
  };
  age.secrets.once_pass = {
    file = ../../secrets/once_pass.age;
    mode = "666";
  };

  systemd.services."once-exporter" = {
    description = "1nce sim exporter";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig.DynamicUser = true;

    environment = {
      OTLP_ENDPOINT = "https://vm.monitoring.htz.nbg.infra.as62028.de/opentelemetry/v1/metrics";
      OTLP_USERNAME = "ffda-metrics";
    };
    script = ''
      export ONCE_USERNAME=$(cat ${config.age.secrets.once_username.path})
      export ONCE_PASSWORD=$(cat ${config.age.secrets.once_pass.path})

      export OTLP_PASSWORD=$(cat ${config.age.secrets.monitoring_ingress.path})
      exec ${once-exporter}/bin/1nce-prometheus-exporter
    '';

  };
}
