{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =  { self, nixpkgs, nix-darwin, home-manager }: {
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

        installer="darwin-rebuild"
        
        if ! command -v "$installer" &> /dev/null; then
          nix build ".#darwinConfigurations.$(hostname).system"
          installer="result/sw/bin/$installer"
        fi
        
        "$installer" switch --flake ".#"
      '';
    };
    darwinConfigurations.jakarta = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({ pkgs, ... }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.sheelpatel = { pkgs, ... }: {
              imports = [
                ./modules/podman.nix
              ];
              home = {
                username = "sheelpatel";
                homeDirectory = "/Users/sheelpatel";
                stateVersion = "23.05";
              };
              nairobi.podman.enable = true;
              programs = {
                gh = {
                  enable = true;
                  settings.git.protocol = "ssh";
                };
                git = {
                  enable = true;
                  userEmail = "hello@sheel.me";
                  userName = "Sheel Patel";
                };
                zsh.enable = true;
              };
            };
          };
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
          programs.zsh.enable = true;
          services.nix-daemon.enable = true;
          users.users.sheelpatel = {
            home = "/Users/sheelpatel";
          };
        })
        home-manager.darwinModules.home-manager
      ];
    };
    darwinConfigurations.aachen = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({ pkgs, ... }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.sheelpatel = { pkgs, ... }: {
              imports = [
                ./modules/podman.nix
              ];
              home = {
                username = "administrator";
                homeDirectory = "/Users/administrator";
                stateVersion = "23.05";
              };
              programs = {
                gh = {
                  enable = true;
                  settings.git.protocol = "ssh";
                };
                git = {
                  enable = true;
                  userEmail = "hello@sheel.me";
                  userName = "Sheel Patel";
                };
                zsh.enable = true;
              };
            };
          };
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
          programs.zsh.enable = true;
          services.nix-daemon.enable = true;
          users.users.administrator = {
            home = "/Users/administrator";
          };
        })
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
