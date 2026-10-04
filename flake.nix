{
  description = "Freifunk Darmstadt gateway config";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-martin.url = "github:nixos/nixpkgs?rev=d80fa9121f722c2ab574cae026fd4827108cda50";
    fastd-server-side-ratelimit = {
      url = "github:fnsh/fastd-server-side-ratelimit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    meshviewer = {
      url = "github:freifunk/meshviewer";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    device-pictures = {
      url = "github:freifunk/device-pictures";
      flake = false;
    };
    systems.url = "github:nix-systems/default";
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.stable.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.nix-github-actions.follows = "nix-github-actions";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    avis = {
      url = "github:fnsh/avis";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    batman-route-sync = {
      url = "github:fnsh/batman-route-sync";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://colmena.cachix.org"
      "https://fnsh.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "fnsh.cachix.org-1:q4w7VKU3C2TUR9nmPvw8NZWki38JeY7W4njYPo+Xzpw="
    ];
  };
  outputs =
    {
      self,
      nixpkgs,
      colmena,
      disko,
      fastd-server-side-ratelimit,
      batman-route-sync,
      avis,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib.extend (
        self: super: {
          fnsh = import ./lib { lib = self; };
        }
      );
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
          batman-route-sync.nixosModules.default
          ./modules/proxmox_vm.nix
          ./gateways
        ];
      };

    in
    {
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;

      colmena = (
        {
          meta = {
            nixpkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
            };
            specialArgs = { inherit inputs lib; };
          };

          defaults = {
            deployment.targetUser = "root";
            imports = [
              disko.nixosModules.disko
              agenix.nixosModules.default
              ./modules/common
              ./modules/collector.nix
              ./sites
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
              avis.nixosModules.default
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

      nixosConfigurations = (inputs.colmena.lib.makeHive self.outputs.colmena).nodes;

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
          pkgs.cachix
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
