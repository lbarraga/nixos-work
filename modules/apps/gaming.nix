{
  flake.modules.nixos.gaming = {
    programs.steam.enable = true;

    # xbox controller pairing
    hardware.xpadneo.enable = true;
  };
}
