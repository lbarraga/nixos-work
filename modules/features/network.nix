{self, ...}: {
  flake.modules.nixos.network = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    networking.networkmanager.enable = true;
    networking.firewall.enable = true;

    # what the bar's wifi icon opens, by name -- keep in sync with
    # `managerCommand` in NetworkWidget.qml
    environment.systemPackages = [mine.networkmanager-dmenu];
  };
}
