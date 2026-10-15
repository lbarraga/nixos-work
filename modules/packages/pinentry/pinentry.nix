{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    # Shared rather than private to the yubikey feature: the wifi picker asks
    # for passphrases too, and two differently themed password boxes would be
    # worse than the duplication.
    #
    # gpg-agent's `pinentry-program` takes a path and no arguments, so the
    # theme has to be baked into the rofi that pinentry-rofi calls. bemenu
    # cannot: it is a bar at a screen edge, with no centred box.
    packages.pinentry = let
      themedRofi = pkgs.symlinkJoin {
        name = "rofi-pinentry";
        paths = [pkgs.rofi];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/rofi --add-flags "-theme ${./pinentry.rasi}"
        '';
      };
    in
      pkgs.pinentry-rofi.override {rofi = themedRofi;};
  };
}
