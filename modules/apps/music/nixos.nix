{
  flake.modules.nixos.music = { pkgs, mine, ... }: {
    environment.systemPackages = [ mine.rmpc ];

    # A user service, not services.mpd: that one runs system-wide with User=,
    # and so has no XDG_RUNTIME_DIR to find the session's pipewire socket in.
    systemd.user.services.mpd = {
      description = "Music Player Daemon";
      partOf = [ "graphical-session.target" ];
      after = [
        "graphical-session.target"
        "pipewire.service"
      ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        # mpd expands ~ in its config but creates none of the directories
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Music %h/.local/share/mpd/playlists";
        ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${./mpd.conf}";
        Restart = "on-failure";
      };
    };
  };
}
