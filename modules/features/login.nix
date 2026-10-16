{self, ...}: {
  flake.modules.nixos.login = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${mine.niri}/bin/niri-session";
    };
  };
}
