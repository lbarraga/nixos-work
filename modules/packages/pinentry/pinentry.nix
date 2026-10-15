{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    # A pinentry that matches the rest of the desktop. Shared rather than
    # private to the yubikey feature, because the wifi picker asks for
    # passphrases too and two differently themed password boxes on one desktop
    # would be worse than the duplication.
    #
    # gpg-agent's `pinentry-program` takes a path and no arguments, so the
    # theme has to be baked into the rofi that pinentry-rofi calls. bemenu
    # cannot do this: it is a dmenu bar, always full width at a screen edge,
    # with no option for a centred box.
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
