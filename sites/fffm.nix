{ lib, ... }:
let
  firstDomain = 18;
  lastDomain = 19;

  mkDomain =
    id:
    lib.nameValuePair "dom${toString id}" {
      inherit id;
      fastdPort = 10000 + (id * 10);

      batInterface = "bat-fffm-${toString id}";
    };

in
  {
    fnsh.sites.fffm = {
      name = "Freie Netze Suedhessen (FFFM exit)";
      domains = lib.listToAttrs (map mkDomain (lib.range firstDomain lastDomain));
    };
  }

