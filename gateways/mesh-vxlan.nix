{ config, lib, ... }:
let
  meshCfg = config.services.meshGateway;

  mkMeshNetDev = domain: {
    netdevConfig = {
      Name = domain.vxlan.interface;
      Kind = "vxlan";
    };

    vxlanConfig = {
      VNI = domain.vxlan.port;
      Local = "ipv6_link_local";
      DestinationPort = domain.vxlan.port;
      Group = "ff02::20:${toString domain.id}";
      PortRange = domain.vxlan.port;
      MacLearning = true;
      # UDPChecksum = false;
      # UDP6ZeroChecksumTx = false;
      # UDP6ZeroChecksumRx = false;
    };
  };

  mkMeshNetwork = domain: {
    matchConfig.Name = domain.vxlan.interface;
    linkConfig.ActivationPolicy = "up";
    networkConfig = {
      BatmanAdvanced = domain.batInterface;
      LinkLocalAddressing = "ipv6";
      DHCP = false;
      IPv6AcceptRA = false;
    };
  };
in
{
  networking.firewall.interfaces.mesh.allowedUDPPorts = map (
    domain: domain.vxlan.port
  ) meshCfg.domains;

  systemd.network.netdevs = builtins.listToAttrs (
    map (dom: lib.nameValuePair "40-vxlan-dom${toString dom.id}" (mkMeshNetDev dom)) meshCfg.domains
  );

  systemd.network.networks = builtins.listToAttrs (
    map (dom: lib.nameValuePair "40-vxlan-dom${toString dom.id}" (mkMeshNetwork dom)) meshCfg.domains
  );
}
