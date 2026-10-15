{
  # CUPS, plus the half that finds printers. Campus and home printers both
  # advertise themselves over mDNS rather than sitting at an address you know,
  # so avahi is what makes them appear at all, and nssmdns4 is what lets the
  # rest of the system resolve the .local name avahi found.
  #
  # No driver packages: anything made in the last decade speaks IPP Everywhere,
  # which CUPS drives with no driver at all. Add to `services.printing.drivers`
  # only when a specific printer turns out to need it.
  flake.modules.nixos.printing = {
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
