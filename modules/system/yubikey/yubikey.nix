{
  flake.modules.nixos.yubikey =
    { pkgs, mine, ... }:
    let
      # my cards fingerprint
      fingerprint = "7D7927AE9E9E61C7736EE6A8D78940BF1814BF2E";
    in
    {
      services.pcscd.enable = true;
      services.udev.packages = with pkgs; [ yubikey-personalization ];
      hardware.gpgSmartcards.enable = true;

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = mine.pinentry;
      };

      systemd.user.services.gpg-card-setup = {
        description = "Import the YubiKey public key and create its card stubs";
        wantedBy = [ "default.target" ];
        path = [ pkgs.gnupg ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          gpg --batch --quiet --import ${./gpg-public.asc}
          echo "${fingerprint}:6:" | gpg --batch --quiet --import-ownertrust

          # creates the stubs
          gpg --batch --card-status >/dev/null 2>&1 || true
        '';
      };

      programs.git.config = {
        user.signingkey = fingerprint;
        gpg.format = "openpgp";
        commit.gpgsign = true;
        tag.gpgsign = true;
      };

      environment.systemPackages = with pkgs; [
        gnupg
        yubikey-manager
        yubioath-flutter
      ];
    };
}
