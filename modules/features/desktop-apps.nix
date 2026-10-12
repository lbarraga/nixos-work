{
  flake.modules.nixos.desktop-apps = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      obsidian
      mattermost-desktop
      firefox
    ];
  };
}
