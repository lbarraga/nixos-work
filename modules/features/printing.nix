{
  # Printers advertise over mDNS, so avahi is what finds them and nssmdns4 is
  # what resolves the .local name it found.
  #
  # No drivers: anything recent speaks IPP Everywhere. Add to
  # `services.printing.drivers` only if a specific printer needs one.
  flake.modules.nixos.printing = {
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
