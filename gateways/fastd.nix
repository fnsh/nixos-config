{
  config,
  lib,
  pkgs,
  ...
}:
let
  meshCfg = config.services.meshGateway;

  mkFastdConf =
    domain:
    pkgs.writeText "fastd-dom${toString domain.id}.conf" ''
      interface "fastd-dom${toString domain.id}-%k";
      bind any:${toString domain.fastdPort};

      method "null@l2tp";
      method "null";
      method "salsa2012+umac";

      offload l2tp yes;
      persist interface no;

      mode multitap;
      mtu 1312;
      include "${config.age.secrets."fastd_key_gw${toString meshCfg.gwId}".path}";

      include peers from "${meshCfg.peersDir}";
    '';

  mkFastdService =
    domain:
    lib.nameValuePair "fastd-dom${toString domain.id}" {
      description = "fastd interface for domain ${toString domain.id}";
      after = [
        "network.target"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.fastd} --config ${mkFastdConf domain}";
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
        BindPaths = "/etc/fastd";
      };
    };

  fastdServices = map (domain: "fastd-dom${toString domain.id}.service") meshCfg.domains;
in
{
  config = {
    age.secrets."fastd_key_gw${toString meshCfg.gwId}" = {
      file = ../secrets/fastd_key_gw${toString meshCfg.gwId}.age;
      mode = "666";
    };

    environment.systemPackages = [ pkgs.fastd ];

    systemd.services = lib.listToAttrs (map mkFastdService meshCfg.domains);
    networking.firewall.interfaces.frontend.allowedUDPPorts = map (dom: dom.fastdPort) meshCfg.domains;

    services.meshGateway.allowedUDPPorts = [ 42453 ]; # fastd-server-side-ratelimit
    services.fastd-server-side-ratelimit = {
      enable = true;
      interfacePrefix = "fastd-dom";

      targetLimits = [
        {
          # default fallback (matches any target/subtarget not otherwise matched)
          target = "";
          initialDownstreamRate = 85000;
          initialUpstreamRate = 35000;
        }
        {
          target = "ath79";
          initialDownstreamRate = 40000;
          initialUpstreamRate = 10000;
        }
        {
          target = "ipq40xx";
          initialDownstreamRate = 70000;
          initialUpstreamRate = 20000;
        }
        {
          target = "lantiq";
          initialDownstreamRate = 7000;
          initialUpstreamRate = 2000;
        }
        {
          target = "ramips";
          initialDownstreamRate = 7000;
          initialUpstreamRate = 2000;
        }
        {
          target = "ramips";
          subtarget = "mt7621";
          initialDownstreamRate = 70000;
          initialUpstreamRate = 30000;
        }
      ];
    };

    # Fastd key repo
    services.gitMirror.instances.fastd-keys = {
      url = "https://git.darmstadt.ccc.de/ffda/fastd-keys.git";
      directory = "/var/lib/git-mirrors/fastd-keys";
      reloadUnits = fastdServices;
    };
  };
}
