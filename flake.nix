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
        mkdir -p "$work"
        cd "$work"

        # if $work is empty clone nairobi otherwise pull
        
        if [ -z "$(ls -A .)" ]; then
          gh auth login
          gh repo clone nairobi .
        else
          git pull
        fi

        # if we need to, build the initial system so we can use its installer

        host="$(hostname)"
        installer="darwin-rebuild"
        
        if ! command -v "$installer" &> /dev/null; then
          nix build ".#darwinConfigurations.$host.system"
          installer="result/sw/bin/$installer"
        fi
        
        "$installer" switch --flake ".#$host"
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