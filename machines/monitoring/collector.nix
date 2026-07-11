{ ... }:
{
  # Otel collector to receive JSON metrics. Pushes to victoriametrics
  services.opentelemetry-collector = {
    settings = {
      extensions."basicauth/server".htpasswd.inline =
        "ffda-metrics:$2y$05$/Ov8d9A2Gt3k.r8nSerKWuAVXaA.nEF0xQXBAMtoqEoFuw/baUq7e";

      receivers.otlp.protocols.http = {
        endpoint = "localhost:4318";
        auth.authenticator = "basicauth/server";
      };

      service.extensions = [ "basicauth/server" ];
      service.pipelines."metrics/forward" = {
        receivers = [ "otlp" ];
        exporters = [ "otlp_http/victoriametrics" ];
      };
    };
  };

  services.nginx.virtualHosts."collector.monitoring.htz.nbg.infra.as62028.de" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://localhost:4318";
      recommendedProxySettings = true;
    };
  };
}
