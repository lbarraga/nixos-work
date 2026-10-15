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

    # ExecReload is a list and assignment appends, so the empty string is
    # needed to drop the wrapper's own --path line rather than run both.
    systemd.user.services.niri.serviceConfig.ExecReload = lib.mkForce [
      ""
      "${mine.niri}/bin/niri msg action load-config-file"
    ];

    # without this PAM file hyprlock rejects every password, silently
    security.pam.services.hyprlock = {};

    environment.systemPackages = [
      mine.foot
      mine.fuzzel
      pkgs.bibata-cursors

      # wl-copy/wl-paste for the shell. nvim does not need it: nixvim carries
      # its own copy.
      pkgs.wl-clipboard
    ];

    environment.sessionVariables = {
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = toString cursorSize;
    };

    xdg.icons.fallbackCursorThemes = [cursorTheme];
  };
}
