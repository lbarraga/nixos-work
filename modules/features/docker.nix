{
  flake.modules.nixos.docker = {pkgs, ...}: {
    virtualisation.docker = {
      enable = true;

      # The socket is only created when something asks for it, so the daemon
      # is not sitting in memory on a laptop that boots without containers.
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
