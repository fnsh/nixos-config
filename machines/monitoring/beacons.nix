{ config, inputs, ... }:
{
  config = {
    services.nginx.virtualHosts."beacons.as62028.de" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:42135";
        recommendedProxySettings = true;
      };
    };
  };
}
