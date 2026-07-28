{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.yanic;
  yanicPkg = pkgs.callPackage ../pkgs/yanic { };

  tomlFormat = pkgs.formats.toml { };

  yanicConfTemplate = tomlFormat.generate "yanic-conf.toml" cfg.settings;
in
{
  options.services.yanic = {
    enable = lib.mkEnableOption "yanic node info collector";
    meshviewerExport = lib.mkEnableOption "exporting meshviewer compatible data to a tmpfs at /srv/yanic/";

    settings = lib.mkOption {
      type = lib.types.attrsOf tomlFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    services.yanic.settings.nodes.output.meshviewer-ffrgb = lib.optional cfg.meshviewerExport {
      enable = true;
      path = "/srv/yanic/meshviewer.json";
      filter.no_owner = true;
    };
    systemd.mounts = lib.mkIf cfg.meshviewerExport [
      {
        what = "tmpfs";
        where = "/srv/yanic";
        options = "mode=777";
        type = "tmpfs";
      }
    ];
    systemd.services.yanic = {
      wants = [
        "network-online.target"
      ]
      ++ (lib.optional cfg.meshviewerExport "srv-yanic.mount");

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
          (lib.getExe yanicPkg)
          "serve"
          "--config"
          "/run/yanic/yanic.toml"
        ];

        RuntimeDirectory = "yanic";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "yanic";
        BindPaths = lib.mkIf cfg.meshviewerExport "/srv/yanic";
      };
    };
  };
}
