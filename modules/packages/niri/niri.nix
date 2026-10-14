{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    # Monet, Charing Cross Bridge, Fog on the Thames (1903), Harvard Art
    # Museums. The painting is public domain; the photograph of it is the
    # museum's, under CC BY-SA 4.0. Fetched rather than committed so the repo
    # stays free of a multi-megabyte binary.
    wallpaper = pkgs.fetchurl {
      name = "charing-cross-fog.jpg";
      url = "https://upload.wikimedia.org/wikipedia/commons/6/6f/Monet_-_Charing_Cross_Bridge_Fog_on_the_Thames%2C_1903.jpg";
      hash = "sha256-BnII6HdiuQSZrGTEhvUsX0v7JAQu1qRheVPl36Hpe/A=";
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
        config.packages.hyprlock
        {
          data = niriBar;
          prefix = true;
        }
      ];
    };
    packages.default = config.packages.niri;
  };
}
