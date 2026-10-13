{
  flake.modules.nixos.notifications = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.libnotify # notify-send, for testing
      pkgs.poweralertd
    ];

    systemd.packages = [pkgs.poweralertd];

    # asDropin keeps the unit the package ships; without it NixOS emits a
    # whole unit of its own with a wantedBy and no ExecStart.
    systemd.user.services.poweralertd = {
      overrideStrategy = "asDropin";
      wantedBy = ["graphical-session.target"];
    };
  };
}
