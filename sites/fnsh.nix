{ lib, ... }:
let
  firstDomain = 1;
  lastDomain = 20;

  hexOctet = id: if id > 15 then lib.toHexString id else "0${lib.toHexString id}";

  mkDomain =
    id:
    lib.nameValuePair "dom${toString id}" {
      inherit id;
      fastdPort = 10000 + (id * 10);

      vxlan.interface = "vxlan-dom${toString id}";
      vxlan.port = 2000 + id;

      batInterface = "bat-dom${toString id}";
      subnet4 = "10.${toString (id * 10)}";

      subnet6.public = "2a13:fcc0:2ed8:10${hexOctet id}";
      subnet6.ula = "fd01:67c:2ed8:10${hexOctet id}";

      nextnode = {
        v6 = "fd01:67c:2ed8:10${hexOctet id}::1:1";
        v4 = "10.${toString (id * 10)}.0.254";
      };
    };

in
lib.mkMerge [
  {
    fnsh.sites.fnsh = {
      name = "Freie Netze Suedhessen";
      domains = lib.listToAttrs (map mkDomain (lib.range firstDomain lastDomain));
    };
  }
  {
    # Overrides for testing domain
    fnsh.sites.fnsh.domains.dom20 = {
      subnet4 = lib.mkForce null;
      nextnode.v6 = lib.mkForce "2a13:fcc0:2ed8:1014::1:1";
    };
  }
]
