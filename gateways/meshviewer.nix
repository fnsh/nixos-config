{ config, ... }:
{
  imports = [
    ../modules/meshviewer.nix
  ];

  config = {
    services.meshviewer = {
      enable = true;
      domain = "gw${toString config.services.meshGateway.gwId}.as62028.de";
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "acme@as62028.de";

    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
