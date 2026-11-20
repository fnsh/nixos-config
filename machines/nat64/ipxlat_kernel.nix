{ pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.linux_latest.override {
      # Somehow the kernelPatches aren't applied in the kernel config builder
      ignoreConfigErrors = true;
    }
  );

  boot.kernelPatches = [
    {
      name = "ipxlat";
      patch = ./ipxlat.patch;
      structuredExtraConfig = with lib.kernel; {
        CONFIG_NET_IPXLAT = module;
        CONFIG_NET_IPXLAT_LWT = module;
      };
    }
  ];
}
