{ inputs, ... }: {
  perSystem = { pkgs, config, ... }: {
    packages.swayidle = inputs.wrapper-modules.wrappers.swayidle.wrap {
      inherit pkgs;

      # swayidle holds logind's sleep inhibitor until this command exits, and
      # hyprlock does not exit until the session is unlocked -- run it in the
      # foreground and the machine never suspends. So background it and hold
      # the inhibitor for a second instead, which is long enough for the lock
      # surface to be up before the freeze. Without the delay the screen is
      # whatever was on it when RAM comes back.
      events.before-sleep = ''
        ${pkgs.procps}/bin/pidof hyprlock > /dev/null || ${config.packages.hyprlock}/bin/hyprlock & ${pkgs.coreutils}/bin/sleep 1
      '';
    };
  };
}
