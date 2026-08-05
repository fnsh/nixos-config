{
  buildGoModule,
  fetchgit,
  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "yanic";
  version = "1.9-unstable_28.07.2026";

  src = fetchgit {
    url = "https://codeberg.org/FreifunkBremen/yanic.git";
    rev = "89bd94c031fef0491b1b47e6503cb22cdc774144";
    outputHash = "sha256-HSx55d0ysu9UQcoo+3DAFG3gya3wK/ZmzJIVPtoo/PE=";
  };

  patches = [
    ./implement_tcp.patch
  ];

  vendorHash = "sha256-TcmkPBHxpmTgXNW8gPkzMpjPGCQu/HrZqAu9jDpPEjo=";

  meta = {
    description = "Yet another node info collector - for respondd to be used with meshviewer to Grafana";
    homepage = "https://codeberg.org/FreifunkBremen/yanic";
    license = lib.licenses.agpl3Plus;
  };
})
