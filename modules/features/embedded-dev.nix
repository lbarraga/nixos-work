{
  flake.modules.nixos.embedded-dev = {
    users.groups.plugdev = {};
    users.users.lukasbt.extraGroups = ["plugdev"];

    # RP2040 in bootloader mode, so picotool and friends do not need root
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000c", MODE="0660", GROUP="users", TAG+="uaccess"
    '';
  };
}
