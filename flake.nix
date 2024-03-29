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
      darwin = nix-darwin.packages.aarch64-darwin;
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

        # move any files the installer will complain about

        sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin 
        
        "${darwin.darwin-rebuild}/bin/darwin-rebuild" switch --flake ".#"
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
            users.administrator = { pkgs, config,  ... }: {
              imports = [
                ./modules/podman.nix
              ];
              home = {
                username = "administrator";
                homeDirectory = "/Users/administrator";
                stateVersion = "23.05";
              };
              programs = {
                bat.enable = true;
                direnv = {
                  enable = true;
                  enableZshIntegration = true;
                  nix-direnv.enable = true;
                };
                eza.enable = true;
                fzf = {
                  enable = true;
                  enableZshIntegration = true;
                };
                gh = {
                  enable = true;
                  settings.git.protocol = "ssh";
                };
                gh-dash.enable = true;
                git = {
                  enable = true;
                  userEmail = "hello@sheel.me";
                  userName = "Sheel Patel";
                  delta.enable = true;
                };
                helix.enable = true;
                hyfetch.enable = true;
                jq.enable = true;
                k9s.enable = true;
                man.enable = true;
                mr.enable = true;
                navi = {
                  enable = true;
                  enableZshIntegration = true;
                };
                noti.enable = true;
                nushell.enable = true;
                ripgrep.enable = true;
                rtx = {
                  enable = true;
                  enableZshIntegration = true;
                };
                script-directory = {
                  enable = true;
                  settings = {
                    SD_ROOT = "${config.home.homeDirectory}/.bin";
                    SD_EDITOR = "hx";
                    SD_CAT = "bat";
                  };
                };
                starship = {
                  enable = true;
                  enableZshIntegration = true;
                };
                topgrade.enable = true;
                zellij = {
                  enable = true;
                  enableZshIntegration = true;
                };
                zoxide = {
                  enable = true;
                  enableZshIntegration = true;
                };
                zsh.enable = true;
              };
            };
          };
          networking = {
            computerName = "aachen";
            hostName = "aachen";
          };
          nix = {
            package = pkgs.nixFlakes;
            extraOptions = ''
              bash-prompt-prefix = (nix:$name)\040
              extra-nix-path = nixpkgs=flake:nixpkgs
              experimental-features = nix-command flakes auto-allocate-uids
              build-users-group = nixbld
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
