{
  buildGoModule,
  fetchFromCodeberg,
  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "yanic";
  version = "1.9-unstable_28.07.2026";

  src = fetchFromCodeberg {
    owner = "FreifunkBremen";
    repo = "yanic";
    rev = "89bd94c031fef0491b1b47e6503cb22cdc774144";
    hash = "sha256-HSx55d0ysu9UQcoo+3DAFG3gya3wK/ZmzJIVPtoo/PE=";
  };

  patches = [
    ./implement_tcp.patch
  ];

  vendorHash = "sha256-b/y4XXZFjLJwQH+xEWUnu2dsGMJ5pik+/ejCMPtKyGo=";

  meta = {
    description = "Yet another node info collector - for respondd to be used with meshviewer to Grafana";
    homepage = "https://codeberg.org/FreifunkBremen/yanic";
    license = lib.licenses.agpl3Plus;
  };
})
