{ inputs, ... }:
{
  imports = [
    ../../modules/meshviewer.nix
  ];

  config = {
    services.meshviewer = {
      enable = true;
      domain = "map.as62028.de";
    };

    services.nginx.virtualHosts = {
      "assets.as62028.de" = {
        forceSSL = true;
        enableACME = true;

        locations."/device-pictures/" = {
          alias = "${inputs.device-pictures}/pictures-svg/";

          extraConfig = ''
            add_header 'Cache-Control' 'public, max-age=604800' always;
            add_header 'Access-Control-Allow-Origin' 'https://map.as62028.de' always;
            add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'User-Agent,If-Modified-Since,Cache-Control,Content-Type,Range' always;
            add_header 'Vary' 'Origin' always;

            if ($request_method = 'OPTIONS') {
                add_header 'Cache-Control' 'public, max-age=604800' always;
                add_header 'Access-Control-Max-Age' 86400;
                add_header 'Content-Type' 'text/plain; charset=utf-8';
                add_header 'Content-Length' 0;
                return 204;
            }
          '';
        };
      };
    };
  };
}
