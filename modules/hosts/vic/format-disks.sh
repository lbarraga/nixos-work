#!/usr/bin/env bash
# Wipes /dev/nvme0n1, applies the layout in _disko.nix, runs nixos-install.
# Run from the installer ISO. Asks for the root password.
set -euo pipefail

cd "$(dirname "$0")/../../.."

read -r -p "This will WIPE /dev/nvme0n1 and install NixOS to it. Continue? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }

# disko runs mkfs only where blkid finds no filesystem, and clears the
# partition table only where blkid finds nothing on the disk at all. So a
# factory-partitioned drive survives its "destroy": this machine came with
# Windows, the new ESP landed on the old one's offset, and NixOS spent its
# first day booting from Lenovo's 96M FAT16. Kill the signatures first.
sudo wipefs -a /dev/nvme0n1?* 2>/dev/null || true
sudo wipefs -a /dev/nvme0n1

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake .#vic

sudo nixos-install --flake .#vic
