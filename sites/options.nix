{ lib, ... }:
let
  domainOptions = {
    options = {
      name = lib.mkOption {
        type = lib.types.singleLineStr;
      };
      aliases = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              code = lib.mkOption {
                type = lib.types.singleLineStr;
              };
              human_name = lib.mkOption {
                type = lib.types.singleLineStr;
              };
            };
          }
        );
      };
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

      subnet4 = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        description = "main ipv4 subnet";
      };

      subnet6.public = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "main ipv6 subnet";
      };
      subnet6.ula = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        description = "legacy ula ipv6 subnet";
      };

      nextnode.v6 = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "ipv6 anycast address for next node";
      };
      nextnode.v4 = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "ipv4 anycast address for next node";
      };
    };
  };

in
{
  options.fnsh.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.singleLineStr;
            description = "name of the site";
          };
          domains = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule domainOptions);
          };
        };
      }
    );
  };
}
