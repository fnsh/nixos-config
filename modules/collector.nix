{ config, pkgs, ... }:
{
  age.secrets.monitoring_ingress = {
    file = ../secrets/monitoring_ingress.age;
    mode = "666";
  };

  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;

    settings = {
      extensions."basicauth/client".client_auth = {
        username = "ffda-metrics";
        password_file = config.age.secrets.monitoring_ingress.path;
      };

      receivers.host_metrics = {
        collection_interval = "60s";
        scrapers = {
          cpu = { };
          disk = { };
          load = { };
          filesystem = { };
          memory = { };
          network = {
            metrics."system.network.conntrack.max".enabled = true;
            metrics."system.network.conntrack.count".enabled = true;
          };
          paging = { };
          # process = { }; Seems to be broken
          processes = { };
          system = { };
        };
      };

      # Tag metrics with hostname
      processors.attributes.actions = [
        {
          key = "host";
          value = config.networking.hostName;
          action = "insert";
        }
      ];

      exporters."otlp_http/victoriametrics" = {
        auth.authenticator = "basicauth/client";
        compression = "gzip";
        encoding = "proto";
        metrics_endpoint = "https://vm.monitoring.htz.nbg.infra.as62028.de/opentelemetry/v1/metrics";
      };

      service = {
        extensions = [ "basicauth/client" ];
        pipelines.metrics = {
          receivers = [ "host_metrics" ];
          processors = [ "attributes" ];
          exporters = [ "otlp_http/victoriametrics" ];
        };
      };
    };
  };
}
