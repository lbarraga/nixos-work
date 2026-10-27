{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    # Shared rather than private to the yubikey feature: the wifi picker asks
    # for passphrases too, and two differently themed password boxes would be
    # worse than the duplication.
    #
    # gpg-agent's `pinentry-program` takes a path and no arguments, so the
    # theme has to be baked into the rofi that pinentry-rofi calls. bemenu
    # cannot: it is a bar at a screen edge, with no centred box.
    packages.pinentry =
      let
        themedRofi = inputs.wrapper-modules.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.rofi;
          flags."-theme" = ./pinentry.rasi;
        };
      in
      pkgs.pinentry-rofi.override { rofi = themedRofi; };
  };
}
