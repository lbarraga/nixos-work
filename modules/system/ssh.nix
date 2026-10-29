{
  flake.modules.nixos.ssh = { config, ... }: {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users.${config.my.username}.openssh.authorizedKeys.keyFiles = [
      ./yubikey/ssh-public.pub
    ];
  };
}
