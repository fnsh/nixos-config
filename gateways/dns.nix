{ ... }:
{
  imports = [ ../modules/unbound_metrics.nix ];

  config = {
    services.meshGateway.allowedTCPPorts = [ 53 ];
    services.meshGateway.allowedUDPPorts = [ 53 ];

    services.unbound = {
      enable = true;
      enableRootTrustAnchor = true;
      settings = {
        server = {
          interface = [
            "194.180.249.32"
            "2a13:fcc0:2ed9:ffff::32"
          ];
          # IPs allowed to query
          access-control = [
            "10.0.0.0/8 allow"
            "2a13:fcc0:2ed8::/48 allow"
          ];
        };
      };
    };
  };
}
