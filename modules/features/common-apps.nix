{
  flake.modules.nixos.common-apps = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.obsidian
      pkgs.papers # gnome pdf viewer
    ];

    xdg.mime.defaultApplications."application/pdf" = "org.gnome.Papers.desktop";
  };
}
