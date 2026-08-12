{ config, lib, ... }:
let
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

      prefix ${domain.subnet6.public}::/64 {
        AdvOnLink on;
        AdvAutonomous on;
        AdvValidLifetime 3600;
        AdvPreferredLifetime 1800;
        DeprecatePrefix off;
      };
    };
  '';
in
{
  services.radvd = {
    enable = true;
    config = lib.concatStringsSep "\n" (
      map mkRadvdSubnet (builtins.attrValues config.fnsh.sites.fnsh.domains)
    );
  };
}
