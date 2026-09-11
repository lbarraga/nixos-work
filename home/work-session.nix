{ pkgs, config, lib, ... }:

let
  firefoxDir = "${config.xdg.configHome}/mozilla/firefox";

  teams = "https://teams.microsoft.com";
  outlook = "https://outlook.office.com/mail/";

  # Firefox 154 keeps the profile names in its "Profile Groups" database rather
  # than in profiles.ini, so the profiles are addressed by their directory.
  profiles = {
    ugent = {
      label = "UGent";
      dir = "dIH00BBV.Profile 1";
      urls = [ teams outlook ];
    };
    imec = {
      label = "IMEC";
      dir = "VtuG7Wfp.Profile 2";
      urls = [ teams outlook ];
    };
  };

  # MOZ_APP_REMOTINGNAME becomes the wayland app id, which is what lets GNOME
  # tell the two profiles apart -- both in the overview and in
  # auto-move-windows (see home/gnome.nix). Without it both windows are plain
  # "firefox" and can't be pinned to different workspaces.
  mkLauncher = key: profile: pkgs.writeShellScriptBin "firefox-${key}" ''
    export MOZ_APP_REMOTINGNAME=firefox-${key}
    exec firefox --profile "${firefoxDir}/${profile.dir}" "$@"
  '';

  launchers = lib.mapAttrs mkLauncher profiles;

  startLine = key: profile:
    ''start_if_down "${profile.label}" "${profile.dir}" ''
    + "${launchers.${key}}/bin/firefox-${key} ${lib.escapeShellArgs profile.urls}";

  workStart = pkgs.writeShellScriptBin "work-start" ''
    # Skip whatever is already up, so hitting the shortcut twice doesn't pile
    # up duplicate tabs. Firefox carries the profile directory in its cmdline.
    start_if_down() {
      name=$1
      pattern=$2
      shift 2
      if ${pkgs.procps}/bin/pgrep -f -- "$pattern" > /dev/null; then
        echo "$name: already running"
      else
        echo "$name: starting"
        "$@" &
      fi
    }

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList startLine profiles)}
    start_if_down "Mattermost" "mattermost-desktop" ${mattermost}/bin/mattermost-desktop
  '';

  # Mattermost hardcodes the wayland app id "Mattermost.Desktop", which doesn't
  # match its own Mattermost.desktop file, so GNOME never associates the window
  # with the app and auto-move-windows can't place it. StartupWMClass bridges
  # the two. Under xwayland the class instead comes from argv[0] -- the shared
  # electron binary -- so --class pins that to the same string.
  appId = "Mattermost.Desktop";

  mattermost = pkgs.symlinkJoin {
    name = "mattermost-desktop-pinned";
    paths = [ pkgs.mattermost-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/mattermost-desktop
      makeWrapper ${pkgs.mattermost-desktop}/bin/mattermost-desktop \
        $out/bin/mattermost-desktop \
        --add-flags "--class=${appId}"

      rm $out/share/applications/Mattermost.desktop
      substitute ${pkgs.mattermost-desktop}/share/applications/Mattermost.desktop \
        $out/share/applications/Mattermost.desktop \
        --replace-fail "${pkgs.mattermost-desktop}/bin/mattermost-desktop" \
                       "$out/bin/mattermost-desktop"
      echo "StartupWMClass=${appId}" >> $out/share/applications/Mattermost.desktop
    '';
  };

  mkDesktopEntry = key: profile: {
    name = "Firefox (${profile.label})";
    genericName = "Web Browser";
    exec = "${launchers.${key}}/bin/firefox-${key} %U";
    icon = "firefox";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    # Ties the window's app id back to this entry, which is how
    # auto-move-windows resolves it.
    settings.StartupWMClass = "firefox-${key}";
  };
in
{
  home.packages = lib.attrValues launchers ++ [
    workStart
    mattermost
  ];

  xdg.desktopEntries = lib.mapAttrs' (key: profile:
    lib.nameValuePair "firefox-${key}" (mkDesktopEntry key profile)
  ) profiles;
}
