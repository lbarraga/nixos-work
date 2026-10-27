{
  flake.modules.nixos.user = {
    users.users.lukasbt = {
      isNormalUser = true;
      description = "Lukas Barragan Torres";
      extraGroups = ["wheel" "networkmanager" "dialout"];
      initialPassword = "changeme";
    };
  };
}
