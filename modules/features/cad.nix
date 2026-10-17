{self, ...}: {
  flake.modules.nixos.cad = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    programs.dconf.enable = true;

    environment.systemPackages = [
      pkgs.freecad
      mine.orca-slicer
    ];

    # FreeCAD reads GTK3's gsettings schemas at runtime and aborts without
    # them on the path.
    environment.extraInit = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };
}
