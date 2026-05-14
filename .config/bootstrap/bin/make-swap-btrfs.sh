#!/usr/bin/env bash

# For now, just a list of commands to follow, no error checking or roll-backs.

# Create a subvolume for the swap file:

btrfs subvolume create /swap

# This creates the swapfile, but also makes sure that the swap-file is
# 'pre-allocated (i.e. no holes)' and 'Copy-on-write must be disabled'.
# https://wiki.archlinux.org/title/Btrfs#Swap_file

btrfs filesystem mkswapfile --size 16g --uuid clear /swap/swapfile

# Active swap!
swapon /swap/swapfile

# Add the following to fstab:
# /swap/swapfile none swap defaults 0 0

# Then follow instructions here: https://wiki.archlinux.org/title/Zswap
# for zswap.
