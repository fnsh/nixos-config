{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.martin;
  yamlFormat = pkgs.formats.yaml { };
in
{
  options.services.martin = {
    enable = lib.mkEnableOption "martin";
    settings = lib.mkOption {
      description = "Settings for martin. Docs: https://maplibre.org/martin/config-file/";
      type = yamlFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.martin = {
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = toString [
          (lib.getExe (inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.martin))
          "--config"
          (yamlFormat.generate "martin-config.yaml" cfg.settings)
        ];

        RuntimeDirectory = "martin";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
