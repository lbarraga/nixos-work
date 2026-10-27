{ config, ... }: {
  flake.modules.nixos.niri =
    { pkgs, mine, ... }:
    let
      cursorTheme = "Bibata-Modern-Ice";
      cursorSize = 24;
    in
    {
      imports = [ config.flake.modules.nixos.hyprlock ];

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

      xdg.icons.fallbackCursorThemes = [ cursorTheme ];
    };
}
