{ self, ... }: {
  flake.modules.nixos.niri = { pkgs, ... }:
    let
      mine = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      programs.niri = {
        enable = true;
        package = mine.niri;
      };
      hardware.graphics.enable = true;
      services.upower.enable = true;
      environment.systemPackages = [ mine.foot mine.fuzzel ];
    };
}
