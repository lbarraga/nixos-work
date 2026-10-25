{self, ...}: {
  flake.modules.nixos.niri = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
    cursorTheme = "Bibata-Modern-Ice";
    cursorSize = 24;
  in {
    programs.niri = {
      enable = true;
      package = mine.niri;
    };
    hardware.graphics.enable = true;
    services.upower.enable = true;

    # without this PAM file hyprlock rejects every password, silently
    security.pam.services.hyprlock = {};

    environment.systemPackages = [
      mine.foot
      mine.fuzzel
      pkgs.bibata-cursors
      pkgs.adwaita-icon-theme
      pkgs.wl-clipboard
    ];

    environment.sessionVariables = {
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = toString cursorSize;

      # Electron and Chromium apps -- brave, discord, element, obsidian,
      # mattermost -- fall back to XWayland without it.
      NIXOS_OZONE_WL = "1";
    };

    xdg.icons.fallbackCursorThemes = [cursorTheme];
  };
}
