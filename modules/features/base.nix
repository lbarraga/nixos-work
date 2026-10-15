{
  flake.modules.nixos.base = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.nh = {
      enable = true;

      # exported as NH_FLAKE, so `nh os switch` needs no path
      flake = "/home/lukasbt/nixos-work";

      # nh keeps at least one generation on top of --keep-since, so the
      # booted one survives even after a month without a rebuild.
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d";
      };
    };

    programs.nix-ld.enable = true;
  };
}
