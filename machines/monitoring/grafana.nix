{ config, ... }:
{
  config = {
    age.secrets.grafana_smtp_pass = {
      file = ../../secrets/grafana_smtp_pass.age;
      owner = "grafana";
      group = "grafana";
    };

    services.grafana.enable = true;
    services.grafana.settings.security.secret_key = "SW2YcwTIb9zpOOhoPsMm"; # Default nixos key for <26.05

    services.grafana.settings = {
      server = {
        root_url = "https://stats.as62028.de";
        domain = "stats.as62028.de";
      };
      "auth.anonymous" = {
        enabled = true;
        org_name = "Public";
        org_role = "Viewer";
        hide_version = true;
      };
      smtp = {
        enabled = true;
        host = "mail.your-server.de:587";
        user = "grafana@as62028.de";
        password = "$__file{${config.age.secrets.grafana_smtp_pass.path}}";
        from_address = "grafana@as62028.de";
        from_name = "Grafana";
        startTLS_policy = "MandatoryStartTLS";
      };
    };

    services.nginx.virtualHosts."stats.as62028.de" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://localhost:3000";
        recommendedProxySettings = true;
        # Enable cors for meshviewer
        extraConfig = ''
          add_header 'Access-Control-Allow-Origin' '*' always;
          add_header 'Access-Control-Allow-Methods' 'POST, OPTIONS' always;
          add_header 'Access-Control-Allow-Headers' '*' always;
                
          if ($request_method = 'OPTIONS') {
              add_header 'Access-Control-Allow-Origin' '*' always;
              add_header 'Access-Control-Allow-Methods' 'POST, OPTIONS' always;
              add_header 'Access-Control-Allow-Headers' '*' always;
              add_header 'Access-Control-Max-Age' 86400;
              add_header 'Content-Type' 'text/plain; charset=utf-8';
              add_header 'Content-Length' 0;
              return 204;
          }
        '';
      };
    };
  };
}
