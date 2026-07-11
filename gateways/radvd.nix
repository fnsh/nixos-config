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

      prefix ${domain.subnet6.public.subnetCidr} {
        AdvOnLink on;
        AdvAutonomous on;
        AdvValidLifetime 3600;
        AdvPreferredLifetime 1800;
      };
    };
  '';
in
{
  services.radvd = {
    enable = true;
    config = lib.concatStringsSep "\n" (map mkRadvdSubnet meshCfg.domains);
  };
}
