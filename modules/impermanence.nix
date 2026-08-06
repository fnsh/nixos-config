{ config, lib, ... }:
{
  options.services.impermanence = {
    enable = lib.mkEnableOption "impermanence";
    persist = lib.mkOption {
      default = [ ];
      description = "which files to keep";
      type = lib.types.listOf (lib.types.path);
    };
  };

  config =
    let
      cfg = config.services.impermanence;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.fileSystems."/mnt/persist" != null;
          message = "For impermanence to work you need to have a filesystem mounted to `/mnt/persist`.";
        }
      ];

      fileSystems = lib.listToAttrs (
        map (
          path:
          lib.nameValuePair path {
            device = "/mnt/persist/${path}";
            depends = [ "/mnt/persist" ];
            fsType = "bind";
            options = [ "bind" ];
            neededForBoot = true;
          }
        ) cfg.persist
      );
    };
}
