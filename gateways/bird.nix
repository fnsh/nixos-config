{ config, lib, ... }:
let
  meshCfg = config.services.meshGateway;
  poolOffset = 1 + (meshCfg.gwId * 2);
  gwAddr4 = "194.180.249.${toString poolOffset}";
in
{
  services.bird = {
    enable = true;
    config = ''
      router id ${gwAddr4};

      protocol device {
        scan time 10;
      }

      protocol kernel kernelv6 {
        ipv6 {
          import where net.len = 128;
          export none;
        };
        learn all;
        kernel table 1337;
        scan time 10;
      }

      protocol static clientnetv6 {
        ipv6;
        route 2a13:fcc0:2ed8::/48 blackhole;
      }

      protocol ospf v3 core_ospf {
        ecmp yes;

        ipv6 {
          import none;
          export all;
        };

        area 0.0.0.0 {
          interface "frontend" {
            type broadcast;

            cost       10;
            hello      10;
            wait       40;
            dead count 4;

            priority 0;
          };
        };
      }
    '';
  };
}
