{
  config,
  lib,
  ...
}:
let
  cfg = config.services.meshGateway;
  domains = builtins.attrValues config.fnsh.sites.fnsh.domains;
in
{
  options.services.meshGateway = {
    allowedTCPPorts = lib.mkOption {
      type = lib.types.listOf (lib.types.port);
      description = "List of TCP ports allowed from domain networks";
    };
    allowedUDPPorts = lib.mkOption {
      type = lib.types.listOf (lib.types.port);
      description = "List of UDP ports allowed from domain networks";
    };

    gwId = lib.mkOption {
      type = lib.types.int;
      description = "Gateway ID. Determines IPs and hostname";
    };
  };

  config = {
    networking.firewall.interfaces = builtins.listToAttrs (
      map (
        dom:
        lib.nameValuePair (dom.batInterface) {
          inherit (cfg) allowedTCPPorts allowedUDPPorts;
        }
      ) domains
    );
  };
}
