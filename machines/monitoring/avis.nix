{ config, inputs, ... }:
{
  config = {

    services.avis.presenter = {
      enable = true;
      collectors = {
        router1 = {
          url = "http://194.180.249.36:58353";
          prettyName = "Router";
        };
      };
      asn = 62028;
    };

    services.nginx.virtualHosts."lg.as62028.de" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:58354";
        recommendedProxySettings = true;
      };
    };
  };
}