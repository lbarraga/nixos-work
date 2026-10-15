{self, ...}: {
  flake.modules.nixos.brave = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    environment.systemPackages = [mine.brave];

    # Writes /etc/brave/policies/managed, which is the only way to install an
    # extension without a per-profile click. Force-installed, so they can be
    # disabled but not removed.
    programs.chromium = {
      enable = true;
      extensions = [
        "dhlnjfhjjbminbjbegeiijdakdkamjoi" # nord theme
        "nngceckbapebfimnlniiiahkandclblb" # bitwarden
        "hjfkenebldkfgibelglepinlabpjfbll" # no youtube shorts
        "mnjggcdmjocbbbhaepdhchncahnbgone" # youtube sponsorblock
      ];
    };

    # The desktop has no firefox, so links out of discord and element need a
    # handler named here. Both the binary and the desktop file are
    # "brave-origin", not "brave".
    xdg.mime.defaultApplications = {
      "text/html" = "com.brave.Origin.desktop";
      "x-scheme-handler/http" = "com.brave.Origin.desktop";
      "x-scheme-handler/https" = "com.brave.Origin.desktop";
    };
  };
}
