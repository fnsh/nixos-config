{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "fishymetrics";
  version = "0.18.2-unstable_13.06.2026";

  src = fetchFromGitHub {
    owner = "comcast";
    repo = "fishymetrics";
    rev = "a7e56f4b154a950aebbc500f0f9749d4fb6eddc0";
    hash = "sha256-9Xf7majj+V1blJAf6Ef01VznuFg+IaqR59jVEP6nb2Q=";
  };

  patches = [
    ./0001-powermetrics-use-CurConsumedWatts-instead-of-average.patch
  ];
  vendorHash = null;

  checkFlags = [ "-skip=Test_Vault_Auth" ]; # Skip test that requires docker

  meta = {
    description = "Redfish API Prometheus Exporter for monitoring large scale server deployments";
    homepage = "https://github.com/comcast/fishymetrics";
    license = lib.licenses.asl20;
  };
})
