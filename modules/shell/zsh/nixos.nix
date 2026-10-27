{
  flake.modules.nixos.zsh = {
    pkgs,
    lib,
    mine,
    ...
  }: let
    zsh = "${mine.zsh}/bin/zsh";
  in {
    programs.zsh = {
      enable = true;
      autosuggestions.enable = false;
      syntaxHighlighting.enable = false;
      enableCompletion = true;
      enableGlobalCompInit = false;

      shellAliases = {
        ls = null;
        l = null;
        ll = null;
      };

      promptInit = "";
      interactiveShellInit = lib.mkAfter ''
        source ${mine.zsh}/zsh-dot-dir/.zshrc
      '';
    };

    environment.shells = [zsh];
    users.users.lukasbt.shell = zsh;

    environment.systemPackages = [pkgs.eza pkgs.xdg-utils];
  };
}
