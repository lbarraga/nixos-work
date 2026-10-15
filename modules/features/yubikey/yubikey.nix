{self, ...}: {
  flake.modules.nixos.yubikey = {pkgs, ...}: let
    # the card's key, for ssh (authentication subkey) and git signing
    fingerprint = "7D7927AE9E9E61C7736EE6A8D78940BF1814BF2E";

    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [yubikey-personalization];
    hardware.gpgSmartcards.enable = true;

    # enableSSHSupport points SSH_AUTH_SOCK at gpg-agent, which is what puts
    # the authentication subkey in `ssh-add -L`.
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = mine.pinentry;
    };

    # gpg's keyring lives in $HOME, so no NixOS option declares it. This is
    # home-manager's programs.gpg.publicKeys by hand: import the public key and
    # create the card's private-key stubs. Idempotent, so it runs every login.
    systemd.user.services.gpg-card-setup = {
      description = "Import the YubiKey public key and create its card stubs";
      wantedBy = ["default.target"];
      path = [pkgs.gnupg];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        gpg --batch --quiet --import ${./keys/gpg-public.asc}
        echo "${fingerprint}:6:" | gpg --batch --quiet --import-ownertrust

        # creates the stubs; only works with the key in, so do not fail without
        gpg --batch --card-status >/dev/null 2>&1 || true
      '';
    };

    # here rather than with git: it needs the card, and the id is the card's
    programs.git.config = {
      user.signingkey = fingerprint;
      gpg.format = "openpgp";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };

    environment.systemPackages = with pkgs; [
      gnupg
      yubikey-manager # `ykman` -- inspect and configure the key
    ];
  };
}
