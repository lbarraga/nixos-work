{self, ...}: {
  flake.modules.nixos.yubikey = {pkgs, ...}: let
    # The card's key: used for ssh (authentication subkey) and git signing.
    fingerprint = "7D7927AE9E9E61C7736EE6A8D78940BF1814BF2E";

    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [yubikey-personalization];
    hardware.gpgSmartcards.enable = true;

    # enableSSHSupport points SSH_AUTH_SOCK at gpg-agent, which is what makes
    # the card's authentication subkey show up in `ssh-add -L`.
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = mine.pinentry;
    };

    # gpg keeps its keyring in $HOME, so there is nothing for a NixOS option to
    # declare. This does what home-manager's programs.gpg.publicKeys does: it
    # imports the public key and asks the card for its private-key stubs, which
    # is what ssh and git signing need. Idempotent, so it just runs every login.
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

        # Creates the stubs that point gpg at the card. Only works with the key
        # plugged in, so do not fail the unit when it is not.
        gpg --batch --card-status >/dev/null 2>&1 || true
      '';
    };

    # Commit signing lives here rather than with git itself: it only works on a
    # machine that has the card, and the key id is the card's.
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
