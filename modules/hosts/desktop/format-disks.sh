#!/usr/bin/env bash
# Wipes /dev/nvme0n1, applies the layout in _disko.nix, runs nixos-install.
# Run from the installer ISO. Asks for the root password.
set -euo pipefail

cd "$(dirname "$0")/../../.."

read -r -p "This will WIPE /dev/nvme0n1 and install NixOS to it. Continue? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake .#desktop

sudo nixos-install --flake .#desktop
