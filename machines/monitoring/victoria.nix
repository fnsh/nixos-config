{ config, pkgs, ... }:
let
  # yanic pushes an owner label, which usually contains private information that we don't want to store.
  ingestRelabelConfig = pkgs.writeText "vm-ingest-relabel.yml" ''
    - if: '{site=~".+"}'
      action: labeldrop
      regex: owner
  '';
in
{
  config = {
    # Metrics
    services.victoriametrics = {
      enable = true;
      basicAuthPasswordFile = config.age.secrets.monitoring_ingress.path;
      basicAuthUsername = "ffda-metrics";

      retentionPeriod = "100y";

      extraOptions = [
        "-dedup.minScrapeInterval=1m"
        "-selfScrapeInterval=60s"
        "-inmemoryDataFlushInterval=60s"
        "-relabelConfig=${ingestRelabelConfig}"
      ];
    };
    systemd.mounts = [
      {
        description = "Bind mount VictoriaMetrics state directory";
        after = [ "mnt-metrics.mount" ];
        requires = [ "mnt-metrics.mount" ];
        what = "/mnt/metrics/victoriametrics";
        where = "/var/lib/private/victoriametrics";
        type = "none";
        options = "bind";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    systemd.services.victoriametrics = {
      after = [ "var-lib-private-victoriametrics.mount" ];
      requires = [ "var-lib-private-victoriametrics.mount" ];
    };

    services.nginx.virtualHosts."vm.monitoring.htz.nbg.infra.as62028.de" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://localhost:8428";
        recommendedProxySettings = true;
      };
    };

    # Logs
    services.victorialogs = {
      enable = true;
      basicAuthPasswordFile = config.age.secrets.monitoring_ingress.path;
      basicAuthUsername = "ffda-metrics";

      extraOptions = [ "-retentionPeriod=8w" ];
    };

    services.nginx.virtualHosts."vl.monitoring.htz.nbg.infra.as62028.de" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://localhost:9428";
        recommendedProxySettings = true;
      };
    };
  };
}
