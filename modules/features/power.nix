{
  # The laptop reported its battery but never managed it. `services.upower` is
  # already on for the bar's battery widget, and upower only ever reads; this
  # is the half that acts.
  #
  # TLP rather than power-profiles-daemon. The two conflict, and ppd is built
  # to be driven from a desktop's power menu -- niri has none, so its profile
  # would sit on "balanced" forever. TLP switches on whether the charger is in,
  # which is the one signal available here without a UI.
  flake.modules.nixos.power = {
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        # This machine offers cool/quiet/balanced/performance and no
        # "low-power" -- a profile the firmware does not list is one TLP warns
        # about and then ignores, so the names are taken from
        # /sys/firmware/acpi/platform_profile_choices rather than from habit.
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "quiet";

        # TLP suspends idle USB devices by default, and a suspended smartcard
        # reader is a YubiKey that stops answering mid-`gpg --card-status`.
        # The saving is small and the failure is baffling, so it stays off.
        USB_AUTOSUSPEND = 0;
      };
    };

    # Intel thermal daemon: throttles early and gently, rather than leaving it
    # to the firmware to do late and hard.
    services.thermald.enable = true;
  };
}
