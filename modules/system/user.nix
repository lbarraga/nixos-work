{
  flake.modules.nixos.user = {
    config,
    lib,
    ...
  }: {
    options.my.username = lib.mkOption {
      type = lib.types.str;
      default = "lukasbt";
      description = "The login account every host creates.";
    };

    config.users.users.${config.my.username} = {
      isNormalUser = true;
      description = "Lukas Barragan Torres";
      extraGroups = ["wheel" "networkmanager" "dialout"];
      initialPassword = "changeme";
    };
  };
}
