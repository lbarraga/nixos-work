{pkgs, ...}: {
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [yubikey-personalization];
  hardware.gpgSmartcards.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  services.gnome.gcr-ssh-agent.enable = false;

  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-manager # `ykman` — inspect and configure the key
  ];
}
