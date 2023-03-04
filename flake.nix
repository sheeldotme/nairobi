{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =  { self, nixpkgs, nix-darwin }: {
    packages.aarch64-darwin.default = let 
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in pkgs.writeShellApplication {
      name = "nairobi-installer";
      runtimeInputs = [
        pkgs.git
        pkgs.gh
      ];
      text = ''
        gh auth login
        mkdir -p "$HOME/.config"
        gh repo clone nairobi "$HOME/.config/nairobi"
      '';
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