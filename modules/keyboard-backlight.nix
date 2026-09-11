{...}: {
  # Dell kb backlight goes off every 10s, annoying. there is no option for allways on so 12h is max.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="leds", KERNEL=="dell::kbd_backlight", ATTR{stop_timeout}="12h"
  '';
}
