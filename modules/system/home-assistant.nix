{
  flake.modules.nixos.home-assistant = {
    # systemd resolves `DeviceAllow=char-ttyACM` against /proc/devices when the
    # unit starts, and silently drops the rule if the name is not there yet.
    # cdc_acm loads on demand, so a stick plugged in after boot is denied.
    boot.kernelModules = [ "cdc_acm" ];

    services.home-assistant = {
      enable = true;
      openFirewall = true;

      extraComponents = [
        "default_config"
        "met"
        "zha"
      ];

      config = {
        default_config = { };
        homeassistant = {
          name = "Home";
          latitude = 51.0536;
          longitude = 3.7253;
          unit_system = "metric";
        };
        http = { };
      };
    };
  };
}
