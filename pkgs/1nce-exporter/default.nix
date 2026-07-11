{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "1nce-exporter";
  version = "0-dev";

  src = fetchFromGitHub {
    owner = "aroneiermann";
    repo = "1nce-exporter";
    rev = "4e4195106aef028b096f7888c1314ce5cec8e846";
    hash = "sha256-0+ttJzeR7WcjJDOCpTeNFOxvGr/5JfrVWm21CJXa0l8=";
  };

  vendorHash = "sha256-yu80MPtlDScUYLE5aciZq7X4yIIbXXbmMoT8sHlmI74=";

  meta = {
    description = "1nce sim metrics exporter";
    homepage = "https://github.com/aroneiermann/1nce-exporter/tree/master";
    # license = lib.licenses.mit;
  };
})
