{self, ...}: {
  flake.modules.nixos.base = {
    config,
    pkgs,
    ...
  }: {
    _module.args.mine = self.packages.${pkgs.stdenv.hostPlatform.system};

    nix.settings.experimental-features = ["nix-command" "flakes"];

    # I know, I know
    nixpkgs.config.allowUnfree = true;

    programs.nh = {
      enable = true;

      # so `nh os switch` needs no path
      flake = "/home/${config.my.username}/nixos-work";

      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d";
      };
    };

    programs.nix-ld.enable = true;
  };
}
