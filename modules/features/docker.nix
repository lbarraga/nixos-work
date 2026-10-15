{
  flake.modules.nixos.docker = {pkgs, ...}: {
    virtualisation.docker = {
      enable = true;

      # socket-activated, so the daemon is not resident on every boot
      enableOnBoot = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };

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
