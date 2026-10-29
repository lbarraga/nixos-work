{ config, ... }: {
  # Resolving <name>.local on the LAN.
  flake.modules.nixos.mdns = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # The other half, answering to our own name.
  flake.modules.nixos.mdns-publish = {
    imports = [ config.flake.modules.nixos.mdns ];

    services.avahi.publish = {
      enable = true;
      addresses = true;
    };
  };
}
