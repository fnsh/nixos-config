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

    services.nginx.enable = true;
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
