{inputs, ...}: {
  flake.modules.nixos.cli-tools = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.neovim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ (with pkgs; [
      git
      htop
      btop
      killall
      tree
      fastfetch
      unzip
    ]);

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
