{ config, ... }: {
  flake.modules.nixos.workstation = {
    imports = with config.flake.modules.nixos; [
      base
      locale
      network
      user
      audio
      niri
      zsh
      fonts
      cli-tools
      claude-code
      notifications
      bluetooth
      printing
      removable-media
      yubikey
      login
      common-apps
      music
    ];
  };
}
