{
  flake.modules.nixos.login = {
    pkgs,
    mine,
    ...
  }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${mine.niri}/bin/niri-session";
    };
  };
}
