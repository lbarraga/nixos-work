{
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [];
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
        "just-perfection-desktop@just-perfection"
        "space-bar@luchrioh"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "statusAreaHorizontalSpacing@mathematical.coffee.gmail.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      dash = false;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 9;
      audible-bell = false;
    };

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
    };

    # Pins the work apps to a fixed workspace whenever they open. The desktop
    # ids for the two firefox profiles come from home/work-session.nix.
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "firefox-ugent.desktop:2"
        "Mattermost.desktop:2"
        "firefox-imec.desktop:3"
      ];
    };

    "org/gnome/shell/extensions/space-bar/behavior" = {
      show-empty-workspaces = false;
      toggle-overview = false;
    };

    "org/gnome/desktop/interface" = {
      cursor-theme = "Adwaita";
      cursor-size = 24;
      icon-theme = "Adwaita";
      font-name = "Cantarell 11";
      document-font-name = "Cantarell 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      switch-to-workspace-7 = ["<Super>7"];
      switch-to-workspace-8 = ["<Super>8"];
      switch-to-workspace-9 = ["<Super>9"];

      close = ["<Super>q"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open Terminal";
      command = "ghostty";
      binding = "<Super>Return";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Start Work Session";
      command = "work-start";
      binding = "<Super><Shift>w";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "Firefox (UGent)";
      command = "firefox-ugent";
      binding = "<Super><Shift>u";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "Firefox (IMEC)";
      command = "firefox-imec";
      binding = "<Super><Shift>i";
    };

    # Legacy GNOME terminal preference, still honoured by some older apps.
    "org/gnome/desktop/applications/terminal" = {
      exec = "ghostty";
      exec-arg = "-e";
    };

    "org/gnome/desktop/notifications/application/com-mitchellh-ghostty" = {
      application-id = "com.mitchellh.ghostty.desktop";
      enable = false;
    };
  };
}
