{self, ...}: {
  flake.modules.nixos.niri = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
    cursorTheme = "Bibata-Modern-Amber";
    cursorSize = 24;
  in {
    programs.niri = {
      enable = true;
      package = mine.niri;
    };
    hardware.graphics.enable = true;
    services.upower.enable = true;

    environment.systemPackages = [
      mine.foot
      mine.fuzzel
      pkgs.bibata-cursors
    ];

    environment.sessionVariables = {
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = toString cursorSize;
    };

    xdg.icons.fallbackCursorThemes = [cursorTheme];
  };
}
