{self, ...}: {
  flake.modules.nixos.cad = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    programs.dconf.enable = true;

    environment.systemPackages = [
      pkgs.freecad
      mine.orca-slicer
    ];
  };
}
