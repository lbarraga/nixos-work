{
  flake.modules.nixos.base = { pkgs, ... }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    environment.systemPackages = with pkgs; [
      vim
      git
    ];
  };
}
