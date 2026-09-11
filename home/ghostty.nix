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

  # Make Ghostty the default terminal for anything following the freedesktop
  # xdg-terminal-exec spec (GTK/GLib "open in terminal", desktop entries with
  # Terminal=true, etc.).
  xdg.configFile."xdg-terminals.list".text = ''
    com.mitchellh.ghostty.desktop
  '';
}
