{ ... }:
{
  imports = [
    ../../modules/martin.nix
  ];
  config = {
    services.martin = {
      enable = true;
      settings = {
        listen_addresses = "[::1]:3030";
        passthrough.sources.osm = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

        cors = {
          max_age = 3600;
          origin = [
            "https://map.as62028.de"
            "https://gw1.as62028.de"
            "https://gw2.as62028.de"
            "https://gw3.as62028.de"
            "https://gw4.as62028.de"
            "https://gw5.as62028.de"
            "https://gw6.as62028.de"
            "https://gw7.as62028.de"
            "https://gw8.as62028.de"
          ];
        };
      };
    };

    services.nginx.virtualHosts."tiles.map.as62028.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://[::1]:3030";
        recommendedProxySettings = true;
      };
    };
  };
}
