{ config, lib, ... }:
let
  meshCfg = config.services.meshGateway;

  mkRadvdSubnet = domain: ''
    interface ${domain.batInterface} {
      AdvSendAdvert on;
      AdvLinkMTU 1280;
      MaxRtrAdvInterval 30;
      AdvDefaultPreference high;
      AdvDefaultLifetime 1800;

      RDNSS ${domain.nextnode.v6} {
        AdvRDNSSLifetime 3600;
        FlushRDNSS off;
      };

      DNSSL ffda.io {
        FlushDNSSL off;
      };

      ${
        if domain.id == 20 then
          ''
            nat64prefix 64:ff9b:1:da:ff::/96 {
              AdvValidLifetime 3600;
            };
          ''
        else
          ""
      }

      ${lib.concatMapStringsSep "\n" (net: ''
        prefix ${net.subnetCidr} {
          AdvOnLink on;
          AdvAutonomous on;
          AdvValidLifetime 3600;
          AdvPreferredLifetime 1800;
          DeprecatePrefix off;
        };
      '') (lib.attrValues domain.subnet6)}
    };
  '';
in
{
  services.radvd = {
    enable = true;
    config = lib.concatStringsSep "\n" (map mkRadvdSubnet meshCfg.domains);
  };
}
