{
  # Plugging in a USB stick did nothing whatsoever. udisks2 is what puts the
  # device on D-Bus, but it only offers -- without something listening there is
  # nobody to accept, and the desktop has no file manager to do it.
  flake.modules.nixos.removable-media = {pkgs, ...}: {
    services.udisks2.enable = true;

    # What makes a mounted stick show up in GTK's file chooser, which is the
    # one xdg-desktop-portal-gtk hands to Firefox.
    services.gvfs.enable = true;

    # udiskie is the listener: it mounts under /run/media/$USER, says where in
    # a notification, and keeps a tray icon for as long as something is plugged
    # in. `--smart-tray` rather than `--tray`, so there is no permanent icon on
    # a laptop with nothing in it.
    #
    # Both halves work here rather than by luck: udiskie ships the
    # libappindicator and libnotify typelibs, the bar hosts
    # StatusNotifierItem, and quickshell is already the notification daemon.
    systemd.user.services.udiskie = {
      description = "Automount removable media";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.udiskie}/bin/udiskie --automount --notify --smart-tray";
        Restart = "on-failure";
      };
    };

    # udiskie-umount, for ejecting without going through the tray.
    environment.systemPackages = [pkgs.udiskie];
  };
}
