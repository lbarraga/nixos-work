{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      keybind = [
        "alt+h=goto_split:left"
        "alt+l=goto_split:right"
        "alt+j=goto_split:down"
        "alt+k=goto_split:up"
      ];
    };
  };
}
