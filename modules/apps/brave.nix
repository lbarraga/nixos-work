{inputs, ...}: {
  perSystem = {system, ...}: {
    packages.brave = inputs.nixpkgs-unstable.legacyPackages.${system}.brave-origin.override {
      commandLineArgs = ["--disable-features=WebRtcAllowInputVolumeAdjustment"];
    };
  };

  flake.modules.nixos.brave = {mine, ...}: {
    environment.systemPackages = [mine.brave];

    programs.chromium = {
      enable = true;
      extensions = [
        "dhlnjfhjjbminbjbegeiijdakdkamjoi" # nord theme
        "nngceckbapebfimnlniiiahkandclblb" # bitwarden
        "hjfkenebldkfgibelglepinlabpjfbll" # no youtube shorts
        "mnjggcdmjocbbbhaepdhchncahnbgone" # youtube sponsorblock
      ];
    };

    xdg.mime.defaultApplications = {
      "text/html" = "com.brave.Origin.desktop";
      "x-scheme-handler/http" = "com.brave.Origin.desktop";
      "x-scheme-handler/https" = "com.brave.Origin.desktop";
    };
  };
}
