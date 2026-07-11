{
  inputs,
  config,
  pkgs,
  ...
}:
{
  config =
    let
      meshviewerPkg = inputs.meshviewer.packages.${pkgs.system}.default.overrideAttrs {
        patches = [
          ../pkgs/meshviewer/remove_pwa.patch
          ../pkgs/meshviewer/router-fix.patch
        ];
      };
      meshCfg = config.services.meshGateway;

      meshviewerConfig = {
        dataPath = [
          "/data/"
        ];
        deprecation_enabled = true;
        deprecation_text = "Warnung: Dieser Knoten ist veraltet, und wird nicht mehr unterstützt. Es gibt auch keine Sicherheitsupdates mehr!<br><br>Mehr Infos im <a href=\"https://darmstadt.freifunk.net/news/2018/05/16/eol-devices.html\" target=\"_blank\" rel=\"noopener noreferrer\">Blogbeitrag</a>.<br><br>Wenn du der Eigentümer des Gerätes bist bitten wir dich das Gerät zu ersetzen um weiterhin am Netz teilnehmen zu können.";
        devicePictures = "https://meshviewer.darmstadt.freifunk.net/pictures-svg/{MODEL_NORMALIZED}.svg";
        devicePicturesLicense = "CC-BY-NC-SA 4.0";
        devicePicturesSource = "<a href='https://github.com/freifunk/device-pictures'>https://github.com/freifunk/device-pictures</a>";
        domainNames = [
          {
            domain = "dom0";
            name = "Domain 0";
          }
          {
            domain = "ffda_da_540_kelley";
            name = "Darmstadt: Kelley-Barracks";
          }
          {
            domain = "ffda_da_530_ggw3";
            name = "Darmstadt: Groß-Gerauer Weg 3";
          }
          {
            domain = "ffda_da_530_hh36";
            name = "Darmstadt: Holzhofallee 36";
          }
          {
            domain = "ffda_default";
            name = "Default";
          }
          {
            domain = "ffda_da_110";
            name = "Darmstadt: Stadtzentrum";
          }
          {
            domain = "ffda_da_120";
            name = "Darmstadt: Mollerstadt";
          }
          {
            domain = "ffda_da_130";
            name = "Darmstadt: Hochschulviertel";
          }
          {
            domain = "ffda_da_210";
            name = "Darmstadt: Johannesviertel";
          }
          {
            domain = "ffda_da_220_230";
            name = "Darmstadt: Martinsviertel";
          }
          {
            domain = "ffda_da_270";
            name = "Darmstadt: Bürgerparkviertel";
          }
          {
            domain = "ffda_da_310";
            name = "Darmstadt: Am Oberfeld";
          }
          {
            domain = "ffda_da_320";
            name = "Darmstadt: Mathildenhöhe";
          }
          {
            domain = "ffda_da_240";
            name = "Darmstadt: Waldkolonie";
          }
          {
            domain = "ffda_da_250";
            name = "Darmstadt: Mornewegviertel";
          }
          {
            domain = "ffda_da_260";
            name = "Darmstadt: Pallaswiesenviertel";
          }
          {
            domain = "ffda_da_530";
            name = "Darmstadt: Verlegerviertel";
          }
          {
            domain = "ffda_da_540";
            name = "Darmstadt: Am Kavalleriesand";
          }
          {
            domain = "ffda_da_140";
            name = "Darmstadt: Kapellplatzviertel";
          }
          {
            domain = "ffda_da_150";
            name = "Darmstadt: St. Ludwig mit Eichbergviertel";
          }
          {
            domain = "ffda_da_330";
            name = "Darmstadt: Woogsviertel";
          }
          {
            domain = "ffda_da_340";
            name = "Darmstadt: An den Lichtwiesen";
          }
          {
            domain = "ffda_da_410";
            name = "Darmstadt: Paulusviertel";
          }
          {
            domain = "ffda_da_420";
            name = "Darmstadt: Alt-Bessungen";
          }
          {
            domain = "ffda_da_430";
            name = "Darmstadt: An der Ludwigshöhe";
          }
          {
            domain = "ffda_da_440";
            name = "Darmstadt: Lincoln-Siedlung";
          }
          {
            domain = "ffda_da_510";
            name = "Darmstadt: Am Südbahnhof";
          }
          {
            domain = "ffda_da_520";
            name = "Darmstadt: Heimstättensiedlung";
          }
          {
            domain = "ffda_64390";
            name = "Erzhausen";
          }
          {
            domain = "ffda_da_610_620_630";
            name = "Darmstadt-Arheilgen";
          }
          {
            domain = "ffda_da_810_820";
            name = "Darmstadt-Wixhausen";
          }
          {
            domain = "ffda_da_910_920";
            name = "Darmstadt-Kranichstein";
          }
          {
            domain = "ffda_64521";
            name = "Groß-Gerau";
          }
          {
            domain = "ffda_64546";
            name = "Mörfelden-Walldorf";
          }
          {
            domain = "ffda_64569";
            name = "Nauheim";
          }
          {
            domain = "ffda_64572";
            name = "Büttelborn";
          }
          {
            domain = "ffda_65468";
            name = "Trebur";
          }
          {
            domain = "ffda_64560";
            name = "Riedstadt";
          }
          {
            domain = "ffda_64579";
            name = "Gernsheim";
          }
          {
            domain = "ffda_64584";
            name = "Biebesheim am Rhein";
          }
          {
            domain = "ffda_64589";
            name = "Stockstadt am Rhein";
          }
          {
            domain = "ffda_64832";
            name = "Babenhausen (Hessen)";
          }
          {
            domain = "ffda_64331";
            name = "Weiterstadt";
          }
          {
            domain = "ffda_64347";
            name = "Griesheim";
          }
          {
            domain = "ffda_64409";
            name = "Messel";
          }
          {
            domain = "ffda_64807";
            name = "Dieburg";
          }
          {
            domain = "ffda_64839";
            name = "Münster (Hessen)";
          }
          {
            domain = "ffda_64859";
            name = "Eppertshausen";
          }
          {
            domain = "ffda_64354";
            name = "Reinheim";
          }
          {
            domain = "ffda_64380";
            name = "Roßdorf (bei Darmstadt)";
          }
          {
            domain = "ffda_64401";
            name = "Groß-Bieberau";
          }
          {
            domain = "ffda_64846";
            name = "Groß-Zimmern";
          }
          {
            domain = "ffda_64823";
            name = "Groß-Umstadt";
          }
          {
            domain = "ffda_64850";
            name = "Schaafheim";
          }
          {
            domain = "ffda_64853";
            name = "Otzberg";
          }
          {
            domain = "ffda_64297";
            name = "Darmstadt-Eberstadt";
          }
          {
            domain = "ffda_64319";
            name = "Pfungstadt";
          }
          {
            domain = "ffda_64342";
            name = "Seeheim-Jugenheim";
          }
          {
            domain = "ffda_64404";
            name = "Bickenbach";
          }
          {
            domain = "ffda_64665";
            name = "Alsbach-Hähnlein";
          }
          {
            domain = "ffda_64673";
            name = "Zwingenberg";
          }
          {
            domain = "ffda_64367";
            name = "Mühltal";
          }
          {
            domain = "ffda_64372";
            name = "Ober-Ramstadt";
          }
          {
            domain = "ffda_64397";
            name = "Modautal";
          }
          {
            domain = "ffda_64405";
            name = "Fischbachtal";
          }
          {
            domain = "ffda_63225";
            name = "Langen";
          }
          {
            domain = "ffda_63303";
            name = "Dreieich";
          }
          {
            domain = "ffda_63329";
            name = "Egelsbach";
          }
          {
            domain = "ffda_63110";
            name = "Rodgau";
          }
          {
            domain = "ffda_63128";
            name = "Dietzenbach";
          }
          {
            domain = "ffda_63322";
            name = "Rödermark";
          }
          {
            domain = "ffda_63500";
            name = "Seligenstadt";
          }
          {
            domain = "ffda_63533";
            name = "Mainhausen";
          }
          {
            domain = "ffda_64385";
            name = "Reichelsheim (Odenwald)";
          }
          {
            domain = "ffda_64395";
            name = "Brensbach";
          }
          {
            domain = "ffda_64407";
            name = "Fränkisch-Crumbach";
          }
          {
            domain = "ffda_64711";
            name = "Erbach";
          }
          {
            domain = "ffda_64720";
            name = "Michelstadt";
          }
          {
            domain = "ffda_64732";
            name = "Bad König";
          }
          {
            domain = "ffda_64739";
            name = "Höchst im Odenwald";
          }
          {
            domain = "ffda_64747";
            name = "Breuberg";
          }
          {
            domain = "ffda_64750";
            name = "Lützelbach";
          }
          {
            domain = "ffda_64753";
            name = "Brombachtal";
          }
          {
            domain = "ffda_64756";
            name = "Mossautal";
          }
        ];
        fixedCenter = [
          [
            50.0254
            8.38806
          ]
          [
            49.6987
            9.07059
          ]
        ];
        globalInfos = [ ];
        mapLayers = [
          {
            config = {
              attribution = "Map data (c) <a href\"https://openstreetmap.org\">OpenStreetMap</a> contributor";
              maxZoom = 19;
              type = "osm";
            };
            name = "OpenStreetMap";
            url = "https://tiles.darmstadt.freifunk.net/osm/{z}/{x}/{y}.png";
          }
        ];
        maxAge = 21;
        grafana = {
          url = "https://stats.as62028.de/";
          orgId = "2";
        };
        nodeCharts = [
          {
            name = "Clients";
            datasourceUid = "efq17o52mrhmoc";
            datasourceType = "victoriametrics-metrics-datasource";
            query = "union( alias(sum by () (node_clients.wifi24{nodeid=~\"^$node$\"}), \"WiFi 2.4 GHz\"), alias(sum by () (node_clients.wifi5{nodeid=~\"^$node$\"}), \"WiFi 5 GHz\"), alias(sum by () (node_clients.total{nodeid=~\"^$node$\"} - node_clients.wifi5{nodeid=~\"^$node$\"} - node_clients.wifi24{nodeid=~\"^$node$\"}), \"Wired\") ) ";
            from = "now-7d";
            to = "now-1m";
            maxDataPoints = 300;
            series = [
              {
                name = "WiFi 2.4 GHz";
                color = "#73bf69";
              }
              {
                name = "WiFi 5 GHz";
                color = "#f2cc0c";
              }
              {
                name = "Wired";
                color = "#5794f2";
              }
            ];
          }
          {
            name = "Traffic";
            datasourceUid = "efq17o52mrhmoc";
            datasourceType = "victoriametrics-metrics-datasource";
            query = "union(alias(sum by () (rate(node_traffic.rx.bytes{nodeid=~\"^$node$\"})) * 8, \"RX\"), alias(sum by () (rate(node_traffic.tx.bytes{nodeid=~\"^$node$\"})) * 8, \"TX\"))";
            unitSuffix = "bit/s";
            from = "now-7d";
            to = "now-1m";
            maxDataPoints = 300;
            series = [
              {
                name = "RX";
                color = "#73BF69";
              }
              {
                name = "TX";
                color = "#F2495C";
                negate = true;
              }
            ];
          }
        ];
        linkCharts = [
          {
            name = "TQ";
            datasourceUid = "efq17o52mrhmoc";
            datasourceType = "victoriametrics-metrics-datasource";
            query = "union(alias(avg by () (avg_over_time(link_tq{source.id=~\"^$source$\",target.id=~\"^$target$\"})), \"Source → Target\"), alias(avg by () (avg_over_time(link_tq{source.id=~\"^$target$\",target.id=~\"^$source$\"})), \"Target → Source\"))";
            series = [
              {
                name = "Source → Target";
                color = "#73BF69";
              }
              {
                name = "Target → Source";
                color = "#F2495C";
              }
            ];
          }
        ];
        globalCharts = [
          {
            name = "Clients";
            datasourceUid = "efq17o52mrhmoc";
            datasourceType = "victoriametrics-metrics-datasource";
            query = "alias(sum(node_clients.total), \"Clients\")";
            format = ".0f";
            series = [
              {
                name = "Clients";
                color = "#73BF69";
              }
            ];
          }
          {
            name = "Nodes";
            datasourceUid = "efq17o52mrhmoc";
            datasourceType = "victoriametrics-metrics-datasource";
            query = "alias(count(count by (nodeid) (node_time.up)), \"Nodes\")";
            format = ".0f";
            series = [
              {
                name = "Nodes";
                color = "#73BF69";
              }
            ];
          }
        ];
        nodeZoom = 19;
        siteName = "Freifunk Darmstadt";
      };
    in
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      security.acme.acceptTerms = true;
      security.acme.defaults.email = "acme@as62028.de";

      services.nginx = {
        enable = true;
        enableReload = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts = {
          "gw${toString meshCfg.gwId}.as62028.de" = {
            forceSSL = true;
            enableACME = true;

            locations."/" = {
              root = meshviewerPkg;
            };

            locations."= /data/meshviewer.json" = {
              alias = "/var/lib/yanic/meshviewer.json";
            };
            locations."= /config.json" = {
              alias = pkgs.writeText "config.json" (builtins.toJSON meshviewerConfig);
            };
          };
        };
      };
    };
}
