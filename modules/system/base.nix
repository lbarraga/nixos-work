{self, ...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    _module.args.mine = self.packages.${pkgs.stdenv.hostPlatform.system};

    nix.settings.experimental-features = ["nix-command" "flakes"];

    # I know, I know
    nixpkgs.config.allowUnfree = true;

    programs.nh = {
      enable = true;

      # so `nh os switch` needs no path
      flake = "/home/lukasbt/nixos-work";

      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d";
      };
    };

    programs.nix-ld.enable = true;
  };
}
