{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    # Aivazovsky, The Ninth Wave (1850), public domain. Fetched rather than
    # committed so the repo stays free of a multi-megabyte binary.
    wallpaper = pkgs.fetchurl {
      name = "ninth-wave.jpg";
      url = "https://upload.wikimedia.org/wikipedia/commons/5/54/Aivazovsky%2C_Ivan_-_The_Ninth_Wave.jpg";
      hash = "sha256-cKiZM4RJcW1sJSnR9Zsx33uFGWW7waBBXS++SZIUarM=";
    };

    # The QML refers to the image as a plain relative path, so the image has to
    # sit inside the config dir. Assembling the directory keeps the .qml files
    # untouched -- dropping a new one into ./quickshell still just works.
    barConfig = pkgs.runCommand "niri-bar-config" {} ''
      cp -r ${./quickshell} $out
      chmod -R u+w $out
      ln -s ${wallpaper} $out/wallpaper.jpg
    '';

    niriBar = inputs.wrapper-modules.wrappers.quickshell.wrap {
      inherit pkgs;
      configDir = barConfig;
    };
  in {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      "config.kdl".path = ./config.kdl;
      runtimePkgs = [
        config.packages.foot
        config.packages.fuzzel
        pkgs.xwayland-satellite
        pkgs.playerctl
        pkgs.brightnessctl
        pkgs.procps
        {
          data = niriBar;
          prefix = true;
        }
      ];
    };
    packages.default = config.packages.niri;
  };
}
