{
  flake.modules.nixos.personal-apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      deezer-desktop
      discord
      element-desktop
      anki
      synology-drive-client
    ];

    # The old config autostarted this through home-manager's xdg.configFile.
    # A user unit does the same job and does not need niri's config.kdl, which
    # both hosts share.
    systemd.user.services.synology-drive = {
      description = "Synology Drive client";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.synology-drive-client}/bin/synology-drive";
        Restart = "on-failure";
      };
    };
  };
}
