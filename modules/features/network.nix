{self, ...}: {
  flake.modules.nixos.network = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    networking.networkmanager.enable = true;
    networking.firewall.enable = true;

    # What the bar's wifi icon opens. The bar calls it by name, so this and
    # `managerCommand` in NetworkWidget.qml have to agree.
    environment.systemPackages = [mine.networkmanager-dmenu];
  };
}
