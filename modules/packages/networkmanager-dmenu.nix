{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    # A wifi picker and nothing else: the list of nearby networks, connect,
    # disconnect, toggle the radio. NetworkManager has no small GTK window of
    # its own for this -- nm-connection-editor only edits saved connections,
    # and the only GUI that scans is the whole GNOME Settings application --
    # so this drives the already-themed fuzzel instead.
    packages.networkmanager-dmenu = let
      settings = pkgs.writeText "networkmanager-dmenu.ini" ''
        [dmenu]
        dmenu_command = ${config.packages.fuzzel}/bin/fuzzel --dmenu
        compact = True
        prompt = network

        # Passphrases go through the same themed box as the YubiKey PIN rather
        # than being typed in clear text into the picker.
        pinentry = ${config.packages.pinentry}/bin/pinentry-rofi

        [pinentry]
        description = Wi-Fi password
        prompt = password
      '';
    in
      pkgs.symlinkJoin {
        name = "networkmanager-dmenu";
        paths = [pkgs.networkmanager_dmenu];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/networkmanager_dmenu \
            --add-flags "--config ${settings}"
        '';
        meta.mainProgram = "networkmanager_dmenu";
      };
  };
}
