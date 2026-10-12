{
  flake.modules.nixos.yubikey = {pkgs, ...}: let
    # The card's key: used for ssh (authentication subkey) and git signing.
    fingerprint = "7D7927AE9E9E61C7736EE6A8D78940BF1814BF2E";

    # gpg-agent's `pinentry-program` takes a path and no arguments, so the
    # theme has to be baked into the rofi that pinentry-rofi calls.
    # bemenu cannot do this: it is a dmenu bar, always full width at a screen
    # edge, with no option for a centred box.
    themedRofi = pkgs.symlinkJoin {
      name = "rofi-pinentry";
      paths = [pkgs.rofi];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/rofi --add-flags "-theme ${./pinentry.rasi}"
      '';
    };

    # Private to this feature: a pinentry is not useful on its own.
    pinentry = pkgs.pinentry-rofi.override {rofi = themedRofi;};
  in {
    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [yubikey-personalization];
    hardware.gpgSmartcards.enable = true;

    # enableSSHSupport points SSH_AUTH_SOCK at gpg-agent, which is what makes
    # the card's authentication subkey show up in `ssh-add -L`.
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pinentry;
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
