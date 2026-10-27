{
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        # Keyed randomly at every boot, so it needs no passphrase and still
        # keeps swapped-out pages off the disk. Rules out hibernation.
        swap = {
          size = "16G";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
        # No LUKS here, unlike the laptop: this machine does not leave the
        # house, and the laptop's passphrase prompt buys nothing on it.
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
