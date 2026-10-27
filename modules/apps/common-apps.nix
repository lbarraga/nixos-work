{
  # apps shared by all workstations/laptops
  flake.modules.nixos.common-apps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      obsidian
      papers # gnome pdf viewer
      gthumb
      vlc
    ];

    xdg.mime.defaultApplications."application/pdf" = "org.gnome.Papers.desktop";
  };
}
