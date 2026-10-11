#!/usr/bin/env bash
# Wipes /dev/nvme0n1, lays out the partitions declared in _disko.nix,
# and runs nixos-install. Prompts once up front, then prompts for the
# LUKS passphrase (disko) and the root password (nixos-install). Run from
# inside the installer ISO after cloning this flake onto the live system.
set -euo pipefail

cd "$(dirname "$0")/../../.."

read -r -p "This will WIPE /dev/nvme0n1 and install NixOS to it. Continue? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake .#laptop

sudo nixos-install --flake .#laptop
