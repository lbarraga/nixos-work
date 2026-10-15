{inputs, ...}: {
  flake.modules.nixos.cli-tools = {pkgs, ...}: let
    mine = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    environment.systemPackages =
      [
        mine.nvim
        mine.fastfetch
      ]
      ++ (with pkgs; [
        git
        htop
        btop
        killall
        tree
        unzip
        wget
      ]);

    # otherwise `git commit` and friends open the NixOS default, nano
    environment.variables.EDITOR = "nvim";

    programs.git = {
      enable = true;
      config = {
        user.name = "Lukas Barragan Torres";
        user.email = "lukas.barragantorres@ugent.be";
        init.defaultBranch = "main";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
