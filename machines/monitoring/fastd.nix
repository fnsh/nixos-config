{
  pkgs,
  lib,
  config,
  ...
}:
let
  domains = builtins.attrValues config.fnsh.sites.fffm.domains;

  fastdConf =
    domain:
    pkgs.writeText "fastd-dom${toString domain.id}.conf" ''
      interface "fastd-ffda-${toString domain.id}";
      include "${config.age.secrets.fastd_key_monitoring.path}";

      method "null@l2tp";
      method "null";

      offload l2tp yes;
      persist interface no;

      mode multitap;
      mtu 1312;

      peer "ffda-gw11-dom${toString domain.id}" {
        interface "fastd-fffm-${toString domain.id}";
        key "6e913a6dd25262eb8b9f466a3c43dc6ef277ecc6d018b6dbcf5c9246efbd4541";
        remote [2a0f:3786:21:d::1] port ${toString domain.fastdPort};
        remote 45.157.9.68 port ${toString domain.fastdPort};
      }
    '';

  mkFastdNetwork =
    domain:
    lib.nameValuePair "30-fastd-fffm-${toString domain.id}" {
      matchConfig.Name = "fastd-fffm-${toString domain.id}";
      networkConfig = {
        BatmanAdvanced = domain.batInterface;
      };

    };
in
{
  age.secrets.fastd_key_monitoring = {
    file = ../../secrets/fastd_key_monitoring.age;
    mode = "666";
  };

  systemd.services = lib.listToAttrs (
    map (
      domain:
      lib.nameValuePair "fastd-${toString domain.id}" {
        description = "fastd connection to ffda dom${toString domain.id}";
        after = [
          "network.target"
          "network-online.target"
        ];
        wants = [
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.fastd} --config ${fastdConf domain}";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          Restart = "on-failure";
          RestartSec = "5s";
          # Capabilities needed to create TUN/TAP interfaces.
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "cap_net_bind_service"
          ];
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "cap_net_bind_service"
          ];
          DynamicUser = true;
        };
      }
    ) domains
  );

  systemd.network.networks = lib.listToAttrs (map mkFastdNetwork domains);
}
