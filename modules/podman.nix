{ config, lib, pkgs, ... }: let
  cfg = config.nairobi.podman;
in {
  options = {
    nairobi.podman.enable = lib.mkEnableOption "podman";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.podman ];
  };
}