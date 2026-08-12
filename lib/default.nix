{ lib, ... }:
let
  poolOffset = gwId: 1 + (gwId * 2);
in
{
  paddedHexOctet =
    number: if number > 15 then lib.toHexString number else "0${lib.toHexString number}";

  internalMac =
    {
      vlan,
      typeId,
      nodeId,
      lastTwoOctets ? "00:01",
    }:
    assert vlan > 16;
    assert vlan < 265;
    assert typeId > 0;
    assert typeId < 10;
    assert nodeId > 0;
    assert nodeId < 10;

    "da:ff:${lib.toHexString vlan}:${toString typeId}${toString nodeId}:${lastTwoOctets}";

  externalMac =
    {
      vlan,
      lastTwoOctets ? "00:01",
    }:
    assert vlan > 265;
    assert vlan < 4096;

    "da:00:0${lib.toHexString (builtins.div vlan 256)}:${
      lib.toHexString (vlan - (256 * (builtins.div vlan 256)))
    }:${lastTwoOctets}";

  gwAddr4 = gwId: "194.180.249.${toString (poolOffset gwId)}";
  clientPoolAddr = gwId: "194.180.249.${toString ((poolOffset gwId) + 1)}";
  gwAddr6 = gwId: "2a13:fcc0:ebbe:1:401:1000:110:${toString (poolOffset gwId)}/112";
}
