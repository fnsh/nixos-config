{
  config,
  lib,
  ...
}:
let
  cfg = config.services.meshGateway;

  ipOptions = {
    subnetCidr = lib.mkOption {
      type = lib.types.singleLineStr;
    };
    gatewayAddress = lib.mkOption {
      type = lib.types.singleLineStr;
    };
  };

  domainOptions = {
    options = {
      id = lib.mkOption {
        type = lib.types.number;
      };
      fastdPort = lib.mkOption {
        type = lib.types.port;
        description = "Port for receiving fastd connections from nodes";
      };
      batInterface = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "Batman interface name";
      };
      vxlan.interface = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "VXLAN interface name";
      };
      vxlan.port = lib.mkOption {
        type = lib.types.port;
        description = "VXLAN port number";
      };

      subnet4 = ipOptions // {
        dhcpStart = lib.mkOption {
          type = lib.types.singleLineStr;
        };
        dhcpEnd = lib.mkOption {
          type = lib.types.singleLineStr;
        };
      };

      subnet6.public = ipOptions;
      subnet6.ula = ipOptions;

      mac = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "Mac Address for batman interface";
      };
    };
  };
in
{
  options.services.meshGateway = {
    domains = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule domainOptions);
      description = "List of domains to configure";
    };

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

    peersDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Directory of fastd peer files";
    };
  };

  config = {
    networking.firewall.interfaces = builtins.listToAttrs (
      map (
        dom:
        lib.nameValuePair (dom.batInterface) {
          inherit (cfg) allowedTCPPorts allowedUDPPorts;
        }
      ) cfg.domains
    );
  };
}
