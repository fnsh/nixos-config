{ ... }:
{
  imports = [
    ../../modules/meshviewer.nix
  ];

  config = {
    services.meshviewer = {
      enable = true;
      domain = "map.as62028.de";
    };
  };
}
