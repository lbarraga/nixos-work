{self, ...}: {
  flake.modules.nixos.niri = {
    pkgs,
    lib,
    ...
  }: let
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

    # ExecReload is a systemd list: a second assignment appends rather than
    # replaces, so the wrapper's --path line would still run after ours and
    # load the empty config anyway. The empty string first resets the list.
    systemd.user.services.niri.serviceConfig.ExecReload = lib.mkForce [
      ""
      "${mine.niri}/bin/niri msg action load-config-file"
    ];

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
