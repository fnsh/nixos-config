{
  config,
  lib,
  pkgs,
  ...
}:
let
  meshCfg = config.services.meshGateway;

  yanicConf = ''
    [database]
    delete_after = "3650d"
    delete_interval = "3650d"

    [[database.connection.influxdb]]
    enable = true
    address = "https://vm.monitoring.htz.nbg.infra.as62028.de/"
    database = "victoria"
    username = "ffda-metrics"
    password = "@MONITORING_PASSWORD@"

    [nodes]
    offline_after = "10m"
    prune_after = "7d"
    save_interval = "5s"
    state_path = "/var/lib/yanic/state.json"

    [[nodes.output.meshviewer-ffrgb]]
    enable = true
    # path = "/var/www/html/meshviewer/data/meshviewer.json"
    path = "/var/lib/yanic/meshviewer.json"

    [nodes.output.meshviewer-ffrgb.filter]
    no_owner = true

    [respondd]
    collect_interval = "1m"
    enable = true
    synchronize = "1m"


    ${lib.concatMapStringsSep "\n" (domain: ''
      [[respondd.interfaces]]
      ifname = "${domain.batInterface}"
      multicast_address = "ff05::2:1001"
      port = 10001
    '') meshCfg.domains}

    [respondd.sites.default]
    domains = [
    ${lib.concatMapStrings (domain: ''
      "dom${toString domain.id}",
    '') meshCfg.domains}
    ]

    [webserver]
    bind = "127.0.0.1:8080"
    enable = false
  '';

  yanicConfTemplate = pkgs.writeText "yanic-conf.toml" yanicConf;
in
{
  config = {
    systemd.mounts = [
      {
        what = "tmpfs";
        where = "/var/lib/yanic";
        options = "mode=777";
        type = "tmpfs";
      }
    ];
    networking.firewall.interfaces = lib.listToAttrs (
      map (
        domain:
        lib.nameValuePair domain.batInterface {
          allowedUDPPorts = [ 10001 ];
        }
      ) meshCfg.domains
    );
    systemd.services.yanic = {
      wants = [
        "network-online.target"
        "var-lib-yanic.mount"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        # Render the config at runtime, substituting the InfluxDB password from
        # the agenix secret so it never lands in the world-readable nix store.
        ExecStartPre = pkgs.writeShellScript "yanic-render-config" ''
          install -m 600 ${yanicConfTemplate} "$RUNTIME_DIRECTORY/yanic.toml"
          ${lib.getExe pkgs.replace-secret} \
            '@MONITORING_PASSWORD@' \
            '${config.age.secrets.monitoring_ingress.path}' \
            "$RUNTIME_DIRECTORY/yanic.toml"
        '';

        ExecStart = toString [
          (lib.getExe pkgs.yanic)
          "serve"
          "--config"
          "/run/yanic/yanic.toml"
        ];

        RuntimeDirectory = "yanic";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";
        BindPaths = "/var/lib/yanic";
      };
    };
  };
}
