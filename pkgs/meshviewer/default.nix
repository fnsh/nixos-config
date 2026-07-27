{
  meshviewer,
  ...
}:
meshviewer.overrideAttrs {
  patches = [
    ./remove_pwa.patch
    ./router-fix.patch
  ];
}
