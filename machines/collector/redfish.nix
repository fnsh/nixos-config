{
  config,
  pkgs,
  lib,
  ...
}:
let
  fishymetrics = pkgs.callPackage ../../pkgs/fishymetrics { };
in
{
  age.secrets.bmc_pass = {
    file = ../../secrets/bmc_pass.age;
    mode = "666";
  };

  systemd.services.fishymetrics = {
    description = "fishymetrics exporter";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ProtectSystem = "strict";
      LoadCredential = "bmc_pass:${config.age.secrets.bmc_pass.path}";
      ExecStart = toString [
        (lib.getExe fishymetrics)
        "--insecure-skip-verify"
      ];
    };

    environment = {
      EXPORTER_PORT = "10023";
      BMC_CREDENTIALS_SCRIPT = pkgs.writeShellScript "fishymetrics-creds" ''
        bmc_pass=$(systemd-creds cat bmc_pass)

        echo '{"user": "metrics", "pass": "'$bmc_pass'"}'
      '';
    };
  };

  services.opentelemetry-collector.settings = {
    receivers.prometheus.config.scrape_configs = [
      {
        job_name = "redfish";
        scrape_interval = "60s";
        metrics_path = "/scrape";
        static_configs = [
          {
            targets = [
              "bmc.n1c1.vlan200.cfg.ix.fra.infra.as62028.de"
              "bmc.n2c1.vlan200.cfg.ix.fra.infra.as62028.de"
              "bmc.n1c2.vlan200.cfg.ix.fra.infra.as62028.de"
              "bmc.n2c2.vlan200.cfg.ix.fra.infra.as62028.de"
            ];
          }
        ];

        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:10023";
          }
        ];

      }
    ];

    service.pipelines."metrics/bmc" = {
      receivers = [ "prometheus" ];
      exporters = [ "otlp_http/victoriametrics" ];
    };
  };
}
