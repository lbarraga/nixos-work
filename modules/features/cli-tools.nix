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

    # The system builds a whole editor and then left EDITOR at the NixOS
    # default, so `git commit`, `systemctl edit` and `visudo` all opened nano.
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
