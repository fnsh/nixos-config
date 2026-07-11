{ config, lib, ... }:
let
  cfg = config.services.meshGateway;
  numDomains = 19;

  hexOctet = id: if id > 15 then lib.toHexString id else "0${lib.toHexString id}";
  mkSubnet6 = net: {
    subnetCidr = "${net}::/64";
    gatewayAddress = "${net}::${toString cfg.gwId}/64";
  };

  mkDomain = id: {
    inherit id;
    fastdPort = 10000 + (id * 10);

    vxlan.interface = "vxlan-dom${toString id}";
    vxlan.port = 2000 + id;

    batInterface = "bat-dom${toString id}";
    subnet4 =
      let
        net = "10.${toString (id * 10)}";
        dhcpNet = "${net}.${toString cfg.gwId}";
      in
      {
        subnetCidr = "${net}.0.0/20";
        gatewayAddress = "${net}.0.${toString cfg.gwId}";
        dhcpStart = "${dhcpNet}.0";
        dhcpEnd = "${dhcpNet}.255";
      };

    subnet6.public = mkSubnet6 "2a13:fcc0:2ed8:10${hexOctet id}";
    subnet6.ula = mkSubnet6 "fd01:67c:2ed8:10${hexOctet id}";

    mac = "da:ff:00:00:0${toString cfg.gwId}:${hexOctet id}";
  };
  domains = map mkDomain (lib.range 1 numDomains);
in
{
  config.services.meshGateway = { inherit domains; };
}
