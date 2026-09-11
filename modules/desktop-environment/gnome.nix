{pkgs, ...}: {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    gnome-console
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.space-bar
    gnomeExtensions.launch-new-instance
    gnomeExtensions.status-area-horizontal-spacing
    gnomeExtensions.user-themes
    adwaita-icon-theme
  ];
}
