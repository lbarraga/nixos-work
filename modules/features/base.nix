{
  flake.modules.nixos.base = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.nh.enable = true;
    programs.nix-ld.enable = true;
  };
}
