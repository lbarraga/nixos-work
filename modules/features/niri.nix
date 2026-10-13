{self, ...}: {
  flake.modules.nixos.niri = {
    pkgs,
    lib,
    ...
  }: let
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

    # The niri wrapper ships an ExecReload pointing at its own generated
    # niri-config.kdl, which is empty because our config arrives through
    # "config.kdl".path rather than the wrapper's `settings`. Every switch
    # reloads the unit and would load that empty file into the running
    # session, wiping every keybind. Without --path, niri reloads the file it
    # actually started with.
    systemd.user.services.niri.serviceConfig.ExecReload =
      lib.mkForce "${mine.niri}/bin/niri msg action load-config-file";

    # hyprlock authenticates through PAM. Without this service file every
    # password is rejected, with no hint as to why.
    security.pam.services.hyprlock = {};

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
