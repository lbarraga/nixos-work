{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    # A wifi picker on top of fuzzel. NetworkManager has no small window of
    # its own: nm-connection-editor only edits saved connections, and the only
    # GUI that scans is the whole of GNOME Settings.
    packages.networkmanager-dmenu = let
      settings = pkgs.writeText "networkmanager-dmenu.ini" ''
        [dmenu]
        dmenu_command = ${config.packages.fuzzel}/bin/fuzzel --dmenu
        compact = True
        prompt = network

        # passphrases go through the same box as the YubiKey PIN, not in clear
        pinentry = ${config.packages.pinentry}/bin/pinentry-rofi

        [pinentry]
        description = Wi-Fi password
        prompt = password
      '';
    in
      inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.networkmanager_dmenu;
        flags."--config" = settings;
      };
  };

  flake.modules.nixos.network = {mine, ...}: {
    networking.networkmanager.enable = true;
    networking.firewall.enable = true;

    # what the bar's wifi icon opens, by name -- keep in sync with
    # `managerCommand` in NetworkWidget.qml
    environment.systemPackages = [mine.networkmanager-dmenu];
  };
}
