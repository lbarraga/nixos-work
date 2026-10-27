{
  flake.modules.nixos.mouse-config = {pkgs, ...}: {
    # piper is the GUI; ratbagd is the daemon it talks to
    services.ratbagd.enable = true;
    environment.systemPackages = [pkgs.piper];
  };
}
