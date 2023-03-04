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
        work="$HOME/.config/nairobi"
        mkdir -p $work
        if [ -z "$(ls -A "$work")" ]; then
          gh auth login
          gh repo clone nairobi "$work"
        fi
        nix build "$work#darwinConfigurations.jakarta.system"
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