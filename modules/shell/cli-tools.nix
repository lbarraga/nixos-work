{
  flake.modules.nixos.cli-tools = { pkgs, mine, ... }: {
    environment.systemPackages = [
      mine.nvim
    ]
    ++ (with pkgs; [
      fastfetch
      git
      btop
      killall
      tree
      unzip
      wget
    ]);

    environment.variables.EDITOR = "nvim";

    programs.git = {
      enable = true;
      config = {
        user.name = "Lukas Barragan Torres";
        user.email = "lukas.barragantorres@ugent.be";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
