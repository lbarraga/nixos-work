{lib, ...}: {
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # what the bar's bluetooth icon opens. The service, not just the package:
    # it also installs the polkit rules pairing needs.
    services.blueman.enable = true;

    # ...but not its tray applet; the bar already draws the icon. The unit
    # comes from the package, so it is emptied rather than disabled.
    systemd.user.services.blueman-applet.wantedBy = lib.mkForce [];
  };
}
