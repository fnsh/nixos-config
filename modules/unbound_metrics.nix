{ ... }:
{
  services.unbound.settings = {
    remote-control.control-enable = true;
    extended-statistics = "yes";
  };

  services.prometheus.exporters.unbound = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9167;
  };

  services.opentelemetry-collector.settings = {
    receivers.prometheus.config.scrape_configs = [
      {
        job_name = "unbound";
        scrape_interval = "60s";
        metrics_path = "/metrics";
        static_configs = [ { targets = [ "127.0.0.1:9167" ]; } ];
      }
    ];

    service.pipelines."metrics".receivers = [ "prometheus" ];
  };
}
