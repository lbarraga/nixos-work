{pkgs, ...}: {
  home.packages = with pkgs; [
    # Office
    libreoffice
    obsidian

    claude-code

    # CLI tools
    htop
    btop
    killall
    tree
    fastfetch
    unzip

    # Misc
    vlc
    gthumb

    zotero
    poppler-utils
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
