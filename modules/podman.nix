{ config, lib, pkgs, ... }: let
  cfg = config.nairobi.podman;
in {
  options = {
    nairobi.podman.enable = lib.mkEnableOption "podman";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.podman ];
    launchd = {
      enable = true;
      agents.podman = {
        enable = true;
        config = let
          script = pkgs.writeShellApplication {
            name = "podman";
            runtimeInputs = [
              pkgs.jq
              pkgs.podman
              pkgs.qemu
            ];
            text = ''
              count=$(podman machine list --format=json | jq '. | length')
              if [ "$count" = "0" ]; then
                podman machine init
                podman machine start
              fi
            '';
          };
        in {
          ProgramArguments = [
            "${script}/bin/podman"
          ];
          RunAtLoad = true;
        };
      };
    };
  };
}