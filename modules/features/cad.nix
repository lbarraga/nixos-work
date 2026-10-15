{
  flake.modules.nixos.cad = {pkgs, ...}: {
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      freecad
      orca-slicer
    ];

    # FreeCAD reads GTK3's gsettings schemas at runtime and aborts without
    # them on the path.
    environment.extraInit = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };
}
