{ pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.linux_7_1.override {
      # Somehow the kernelPatches aren't applied in the kernel config builder
      ignoreConfigErrors = true;
    }
  );

  boot.kernelPatches = [
    {
      name = "ipxlat";
      patch = ./ipxlat.patch;
      structuredExtraConfig = with lib.kernel; {
        CONFIG_IPXLAT = module;

        # NAT64
        NETFILTER_XT_NAT = module;
        NETFILTER_XT_TARGET_MASQUERADE = module;
        NF_CONNTRACK = module;
        NETFILTER_ADVANCED = yes;
        NF_CONNTRACK_EVENTS = yes;
        NF_TABLES = module;
        NF_TABLES_IPV4 = yes;
        NF_TABLES_IPV6 = yes;
        NFT_MASQ = module;
        NFT_CT = module;
        NFT_NAT = module;
        NF_TABLES_NETDEV = yes;
        NFT_FWD_NETDEV = module;

        VETH = module;

        # Debugging
        # DEBUG = yes;
        # GDB_SCRIPTS = yes;
        # FRAME_POINTER = yes;

        # dropwatch
        NET_DROP_MONITOR = yes;

        # For Scapy tests
        # TUN = yes;
        # PACKET = yes;
      };
    }
  ];

}
