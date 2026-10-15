{
  flake.modules.nixos.office = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      libreoffice
      xournalpp
      vlc
      gthumb
      cava
    ];
  };
}
