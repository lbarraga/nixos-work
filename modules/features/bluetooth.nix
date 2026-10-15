{lib, ...}: {
  # The laptop has an adapter (hci0, unblocked) but nothing was enabling the
  # stack, so bluetooth.service never ran and bluez was not on the bus at all.
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # blueman-manager is the window the bar's bluetooth icon opens. The service
    # also installs the polkit rules that pairing needs, which is why this is
    # `services.blueman` rather than just the package.
    services.blueman.enable = true;

    # ...but not its tray applet. The bar already draws a bluetooth icon, and
    # two of them sitting next to each other is just clutter. The unit comes
    # from the blueman package itself, so it is emptied rather than disabled.
    systemd.user.services.blueman-applet.wantedBy = lib.mkForce [];
  };
}
