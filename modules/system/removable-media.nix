{
  flake.modules.nixos.removable-media = {pkgs, ...}: {
    services.udisks2.enable = true;

    # makes mounts visible in the GTK file chooser the portal hands Firefox
    services.gvfs.enable = true;

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
