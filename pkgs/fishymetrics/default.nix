{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "fishymetrics";
  version = "0.19.2";

  src = fetchFromGitHub {
    owner = "comcast";
    repo = "fishymetrics";
    rev = "d93d40189cb5ee197f988a8caee6cf95f3a8810e";
    hash = "sha256-oUQxrzUxZNQXqzITLXLtWa4Lsyog0rd3c9Z9Z2okF5c=";
  };

  patches = [
    ./0001-powermetrics-use-CurConsumedWatts-instead-of-average.patch
  ];
  vendorHash = null;

  checkFlags = [ "-skip=Test_Vault_Auth" ]; # Skip test that requires docker

  meta = {
    mainProgram = "fishymetrics";
    description = "Redfish API Prometheus Exporter for monitoring large scale server deployments";
    homepage = "https://github.com/comcast/fishymetrics";
    license = lib.licenses.asl20;
  };
})
