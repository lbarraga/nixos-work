{
  flake.modules.nixos.home-assistant =
    { config, ... }:
    let
      inherit (config.services.home-assistant) configDir;

      seed.f = {
        user = "hass";
        group = "hass";
        mode = "0644";
      };
    in
    {
      boot.kernelModules = [ "cdc_acm" ];

      systemd.tmpfiles.settings."10-home-assistant" = {
        "${configDir}/automations.yaml" = seed;
        "${configDir}/scenes.yaml" = seed;
        "${configDir}/scripts.yaml" = seed;
      };

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

          "automation ui" = "!include automations.yaml";
          "scene ui" = "!include scenes.yaml";
          "script ui" = "!include scripts.yaml";

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
