{
  # udisks2 puts the device on D-Bus but mounts nothing by itself, and there
  # is no file manager here to do it.
  flake.modules.nixos.removable-media = {pkgs, ...}: {
    services.udisks2.enable = true;

    # makes mounts visible in the GTK file chooser the portal hands Firefox
    services.gvfs.enable = true;

    # Mounts under /run/media/$USER and says where in a notification.
    # --smart-tray shows an icon only while something is plugged in; it lands
    # in the bar, which hosts StatusNotifierItem.
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

    # udiskie-umount, for ejecting from a shell
    environment.systemPackages = [pkgs.udiskie];
  };
}
