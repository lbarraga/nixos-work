{
  flake.modules.nixos.base = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.nh = {
      enable = true;

      # So `nh os switch` works from anywhere, with no path. nh reads this as
      # NH_FLAKE.
      flake = "/home/lukasbt/nixos-work";

      # Nothing was collecting garbage before this: the store only ever grew.
      # --keep-since is a floor and not a ceiling -- nh still applies its own
      # `--keep 1`, so the generation currently booted survives even on a
      # machine that has not been rebuilt in over a month.
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d";
      };
    };

    programs.nix-ld.enable = true;
  };
}
