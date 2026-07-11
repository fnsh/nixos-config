{ ... }:
{
  imports = [ ../../modules/unbound_metrics.nix ];

  networking.firewall.interfaces.frontend.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.frontend.allowedUDPPorts = [ 53 ];

  services.unbound = {
    enable = true;
    enableRootTrustAnchor = true;
    settings = {
      module-config = "\"dns64 validator iterator\"";
      dns64-prefix = "64:ff9b:1:da:ff::/96";

      server = {

        interface = [
          "194.180.249.19"
          "2a13:fcc0:ebbe:1:401:1000:110:19"
        ];
        # IPs allowed to query
        access-control = [
          "10.0.0.0/8 allow"
          "2a13:fcc0:2ed8::/48 allow"
        ];
      };
    };
  };

}
