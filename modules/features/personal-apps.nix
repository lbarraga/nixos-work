{
  flake.modules.nixos.personal-apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      deezer-desktop
      discord
      element-desktop
      anki
      synology-drive-client
    ];

    systemd.user.services.synology-drive = {
      description = "Synology Drive client";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.synology-drive-client}/bin/synology-drive";
        ExecStop = "${pkgs.synology-drive-client}/bin/synology-drive stop";
      };
    };
  };
}
