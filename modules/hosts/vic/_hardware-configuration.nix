# A guess, in nixos-generate-config's own shape so it can be overwritten whole:
#
#   nixos-generate-config --show-hardware-config --no-filesystems \
#     > modules/hosts/vic/_hardware-configuration.nix
#
# --no-filesystems is the flag that matters: disko owns fileSystems.* and
# swapDevices via _disko.nix.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
