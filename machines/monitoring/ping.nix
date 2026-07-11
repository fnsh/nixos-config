{ ... }:

{
  services.prometheus.exporters.ping = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9427;
    settings = {
      targets = [
        "gw1.as62028.de"
        "gw2.as62028.de"
        "gw3.as62028.de"
        "gw4.as62028.de"
        "gw5.as62028.de"
        "gw6.as62028.de"
        "gw7.as62028.de"
        "gw8.as62028.de"
        "router.cfg.ix.fra.infra.as62028.de"
      ];
      dns.refresh = "5m";
      ping = {
        interval = "10s";
        timeout = "4s";
        "history-size" = 10;
      };
    };
  };

  services.opentelemetry-collector.settings = {
    receivers.prometheus.config.scrape_configs = [
      {
        job_name = "ping";
        scrape_interval = "60s";
        static_configs = [ { targets = [ "127.0.0.1:9427" ]; } ];
      }
    ];
    service.pipelines.metrics.receivers = [ "prometheus" ];
  };
}
