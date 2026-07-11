{ ... }:
{
  services.prometheus.exporters.ping = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9427;
    settings = {
      targets = [
        "1.1.1.1"
        "8.8.8.8"
        "9.9.9.9"
        "151.101.1.1" # Fastly
        "www.google.com"
        "redirector.googlevideo.com"
        "cloudflare.com"
        "facebook.com"
        "scontent.f1.fbcnd.net"
        "speedtest.frankfurt.linode.com"
        "mx03.t-online.de"
        "06151.sip.arcor.de"
        "aws.com"
      ];
      dns.refresh = "1m";
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
    service.pipelines."metrics".receivers = [ "prometheus" ];
  };
}
