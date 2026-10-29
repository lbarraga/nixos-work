{ config, ... }: {
  flake.modules.nixos.printing = {
    # CUPS finds network printers over mDNS and nothing else.
    imports = [ config.flake.modules.nixos.mdns ];

    services.printing.enable = true;
  };
}
