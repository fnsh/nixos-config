{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  meshviewerPkg = pkgs.callPackage ../pkgs/meshviewer {
    meshviewer = inputs.meshviewer.packages.${pkgs.system}.default;
  };

  meshviewerConfig = {
    dataPath = [
      "/data/"
    ];
    deprecation_enabled = true;
    deprecation_text = "Warnung: Dieser Knoten ist veraltet, und wird nicht mehr unterstützt. <br>Mehr Infos: <a href=\"https://openwrt.org/supported_devices/432_warning\" target=\"_blank\" rel=\"noopener noreferrer\">https://openwrt.org/supported_devices/432_warning</a>.";
    devicePictures = "https://assets.as62028.de/device-pictures/{MODEL_NORMALIZED}.svg";
    devicePicturesLicense = "CC-BY-NC-SA 4.0";
    devicePicturesSource = "<a href='https://github.com/freifunk/device-pictures'>https://github.com/freifunk/device-pictures</a>";
    domainNames = lib.lists.flatten (
      map (
        { aliases, ... }:
        map (alias: {
          domain = alias.code;
          name = alias.human_name;
        }) aliases
      ) (builtins.attrValues config.fnsh.sites.fnsh.domains)
    );
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
          attribution = "Map data &copy <a href=\"https://openstreetmap.org/copyright\">OpenStreetMap</a> contributors";
          maxZoom = 19;
          type = "osm";
        };
        name = "OpenStreetMap";
        url = "https://tiles.map.as62028.de/osm/{z}/{x}/{y}";
      }
      {
        name = "BaseMap.de Vektor Light";
        url = "https://sgx.geodatenzentrum.de/gdz_basemapde_vektor/styles/bm_web_col.json";
        type = "vector";
        config = {
          minZoom = 6;
          maxZoom = 18;
          attribution = "CC BY 4.0: &copy GeoBasis-DE / <a href=\"https://www.bkg.bund.de/\">BKG</a> (2026) <a href=\"https://creativecommons.org/licenses/by/4.0/\">CC BY 4.0</a>";
        };
      }
      {
        name = "BaseMap.de Vektor Dark";
        url = "https://sgx.geodatenzentrum.de/gdz_basemapde_vektor/styles/bm_web_drk.json";
        type = "vector";
        config = {
          minZoom = 6;
          maxZoom = 18;
          attribution = "CC BY 4.0: &copy GeoBasis-DE / <a href=\"https://www.bkg.bund.de/\">BKG</a> (2026) <a href=\"https://creativecommons.org/licenses/by/4.0/\">CC BY 4.0</a>";
        };
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
    nodeInfos = [
      {
        "name" = "Stats";
        "title" = "Statistiken in Grafana öffnen";
        "href" =
          "https://stats.as62028.de/d/000000028/knoten?orgId=2&from=now-7d&to=now-1m&var-node={NODE_ID}";
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
    siteName = "Freie Netze Südhessen";
    linkList = [
      {
        "href" = "https://docs.as62028.de/general/90-imprint/";
        "title" = "Impressum";
      }
    ];
  };

  cfg = config.services.meshviewer;
in
{
  options.services.meshviewer = {
    enable = lib.mkEnableOption "meshviewer";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "where to host meshviewer";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        forceSSL = true;
        enableACME = true;

        locations."/".root = meshviewerPkg;

        locations."/assets/" = {
          alias = "${meshviewerPkg}/assets/";
          extraConfig = ''
            add_header 'Cache-Control' 'public, max-age=604800, immutable' always;
          '';
        };

        locations."= /data/meshviewer.json" = {
          alias = "/srv/yanic/meshviewer.json";
          extraConfig = ''
            add_header 'Cache-Control' 'no-store' always;
          '';
        };

        locations."= /config.json" = {
          alias = pkgs.writeText "config.json" (builtins.toJSON meshviewerConfig);
          extraConfig = ''
            add_header 'Cache-Control' 'max-age=86400, stale-while-revalidate=1123200' always;
          '';
        };
      };
    };
  };
}
