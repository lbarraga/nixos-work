{
  # TLP rather than power-profiles-daemon: the two conflict, and ppd expects a
  # desktop power menu to drive it. niri has none, so its profile would never
  # move off balanced. TLP switches on whether the charger is in.
  flake.modules.nixos.power = {
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        # names must come from /sys/firmware/acpi/platform_profile_choices;
        # this machine has no "low-power", and TLP ignores unlisted profiles
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "quiet";

        # on by default, and a suspended smartcard reader is a YubiKey that
        # stops answering mid-operation
        USB_AUTOSUSPEND = 0;
      };
    };

    # throttles early and gently, instead of leaving it to the firmware
    services.thermald.enable = true;
  };
}
