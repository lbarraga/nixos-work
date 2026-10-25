{self, ...}: {
  flake.modules.nixos.brave = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
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
