{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =  { self, nixpkgs, nix-darwin }: {
    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.writeShellApplication {
      name = "nairobi-installer";
      runtimeInputs = [];
      text = ''
        echo "Hello, world!"
      '';
    };
    apps.aarch64-darwin.default = {
      type = "app";
      program = "${self.packages.aarch64-darwin.default}/bin/nairobi-installer";
    };
    darwinConfigurations.jakarta = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({ pkgs, ... }: {
          networking = {
            computerName = "jakarta";
            hostName = "jakarta";
          };
          nix = {
            package = pkgs.nixFlakes;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
          };
          services.nix-daemon.enable = true;
        })
      ];
    };
  };
}