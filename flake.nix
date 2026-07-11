{
  description = "Freifunk Darmstadt gateway config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    fastd-server-side-ratelimit.url = "github:fnsh/fastd-server-side-ratelimit";
    meshviewer = {
      url = "github:freifunk/meshviewer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      # optionally choose not to download darwin deps (saves some resources on Linux)
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "";
    };
  };

  outputs =
    {
      nixpkgs,
      colmena,
      disko,
      fastd-server-side-ratelimit,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};

      mkGateway = id: {
        deployment = {
          targetHost = "gw${toString id}.as62028.de";
          tags = [ "gw" ];
        };

        imports = [
          {
            networking.hostName = "gw${toString id}";
            services.meshGateway.gwId = id;
            system.stateVersion = "25.11";
          }
          fastd-server-side-ratelimit.nixosModules.default
          ./modules/proxmox_vm.nix
          ./gateways
        ];
      };

    in
    {
      colmenaHive = colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs { inherit system; };
            specialArgs = { inherit inputs; };
          };

          defaults = {
            deployment.targetUser = "root";
            imports = [
              disko.nixosModules.disko
              agenix.nixosModules.default
              ./machines/common.nix
              ./modules/collector.nix
            ];
          };

          "router1" = {
            deployment.targetHost = "router1.vlan210.cfg.ix.fra.infra.as62028.de";
            imports = [
              ./machines/router1
              ./modules/proxmox_vm.nix
            ];
          };

          "nat64" = {
            deployment.targetHost = "nat64.vlan210.cfg.ix.fra.infra.as62028.de";
            deployment.targetUser = "root";
            imports = [
              ./machines/nat64
              ./modules/proxmox_vm.nix
            ];
          };

          "monitoring" = {
            deployment.targetHost = "monitoring.htz.nbg.infra.as62028.de";
            imports = [
              ./machines/monitoring
            ];
          };

          "collector" = {
            deployment.targetHost = "collector.vlan210.cfg.ix.fra.infra.as62028.de";
            imports = [
              ./machines/collector
              ./modules/proxmox_vm.nix
            ];
          };
        }
        // (lib.listToAttrs (
          map (gwId: lib.nameValuePair "gw${toString gwId}" (mkGateway gwId)) (lib.range 1 8)
        ))
      );

      packages.${system}.installer =
        (lib.nixosSystem {
          inherit pkgs;
          modules = [
            ./machines/common.nix
            (
              { modulesPath, ... }:
              {

                imports = [
                  (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                ];

                system.disableInstallerTools = lib.mkForce false;
                systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
                networking.networkmanager.enable = lib.mkForce false;
                systemd.network.enable = true;
                systemd.network.networks."10-mgmt" = {
                  # Third octet of mac address encodes vlan id
                  # 0xd2 == 210
                  matchConfig.Name = "enxdaffd2*";
                  networkConfig = {
                    Address = [
                      "172.20.210.242/24"
                    ];
                    Gateway = "172.20.210.1";
                    DNS = "9.9.9.9";
                  };
                };
              }
            )
          ];
        }).config.system.build.isoImage;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          colmena.packages.${system}.colmena
          agenix.packages.${system}.default
          pkgs.nixos-anywhere
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
