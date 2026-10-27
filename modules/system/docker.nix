{
  flake.modules.nixos.docker = {pkgs, ...}: {
    virtualisation.docker = {
      enable = true;

      # socket-activated, so the daemon is not resident on every boot
      enableOnBoot = false;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    users.users.lukasbt.extraGroups = ["docker"];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
