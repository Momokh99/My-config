# NixOS configuration

Flake-based NixOS + Home Manager setup for **momo's ThinkPad X280** (`20KES4BT1K`),
plus a VM host for testing and an ISO host for a live image.

The repo's existing dotfiles are not copied into the Nix store. Home Manager
symlinks them back to `~/Projects/My-config` with
`mkOutOfStoreSymlink`, so they stay editable and matugen can keep writing the
generated colour files into the repo.

## Layout

```
flake.nix               # at the repo root
nixos/
├── modules/
│   ├── common.nix      # nix settings, users, audio, graphics, fonts
│   ├── desktop.nix     # Hyprland, portals, greetd, session packages
│   ├── browser.nix     # Helium (third-party flake)
│   └── thinkpad.nix    # TLP, thermald, microcode
├── home/
│   ├── default.nix
│   ├── packages.nix
│   └── dotfiles.nix
├── hosts/
│   ├── vm.nix          # VM test host, no LUKS/disk assumptions
│   ├── iso.nix         # minimal NixOS installer ISO
│   └── x280/
│       ├── default.nix
│       ├── hardware.nix  # kernel modules (static)
│       └── storage.nix   # LUKS2 + btrfs, by-partlabel
└── install.sh
```

## Test in a VM

From any machine with Nix and flakes enabled, at the repo root:

```bash
nix build .#nixosConfigurations.vm.config.system.build.vm
QEMU_OPTS="-m 3072 -smp 4" ./result/bin/run-nixos-vm
```

The VM host copies the repo into `~/Projects/My-config` on first boot so the
live dotfile links resolve. To include uncommitted work, use `path:.`:

```bash
nix build "path:.#nixosConfigurations.vm.config.system.build.vm"
```

Log in as `momo` / `nixos`. The session is Hyprland via UWSM. If the greeter
does not start it, switch to a TTY and run:

```bash
uwsm start hyprland-uwsm.desktop
```

If you already have an installed NixOS VM, generate its hardware file once and
switch instead:

```bash
sudo nixos-generate-config --show-hardware-config > nixos/hosts/vm-hardware.nix
sudo nixos-rebuild switch --flake .#vm
```

## Build a custom ISO

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
ls -lh result/iso/
```

The custom image only adds a few tools (git, cryptsetup, btrfs-progs, …) and is
otherwise a normal minimal installer. For most installs the official ISO from
<https://nixos.org/download> works just as well.

## Automatic install

Boot the NixOS ISO (UEFI), connect to the network (`nmtui`), clone this repo,
then:

```bash
sudo nixos/install.sh --disk /dev/nvme0n1
```

The script:

1. refuses to run unless it is root, UEFI, and the target is a real disk of at
   least 32 GiB that is not mounted and does not host the running system or the
   repo,
2. asks you to type the device path before erasing anything,
3. creates a 2 GiB ESP (label `ESP`) and a LUKS2 container (label `cryptroot`),
4. creates btrfs subvolumes `@`, `@home`, `@nix`, `@log`, `@cache`,
5. prompts for the LUKS passphrase,
6. copies this repository to `/home/momo/Projects/My-config` on the target,
7. runs `nixos-install --flake path:.../My-config#x280`.

Useful flags:

```bash
--dry-run     # print every command, change nothing
--host NAME   # install another host from nixos/hosts/
--yes         # skip the confirmation (dangerous)
```

The script uses `path:` flake references, so uncommitted changes are included.

After reboot, log in as `momo` / `nixos`, run `passwd`, then:

```bash
sudo nixos-rebuild switch --flake path:~/Projects/My-config#x280
```

## Manual install

If you prefer doing it by hand, the script is a linear list of commands. The
important parts are the partition labels, because `storage.nix` refers to them:

```bash
sgdisk -n1:0:+2G -t1:ef00 -c1:ESP \
       -n2:0:0   -t2:8309 -c2:cryptroot /dev/nvme0n1
cryptsetup luksFormat --type luks2 --label cryptroot /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot
mkfs.btrfs -L nixos /dev/mapper/cryptroot
```

Then create and mount the five subvolumes as in `install.sh`, format the ESP
with `mkfs.fat -F32 -n ESP`, and finish with:

```bash
nixos-install --flake path:/path/to/My-config#x280 --no-root-passwd
```

Do **not** copy a generated `hardware-configuration.nix` into this flake: the
filesystems and LUKS device are already declared in `hosts/x280/storage.nix`.
`hosts/x280/hardware.nix` only carries kernel modules.

## X280 notes

- **Touchscreen.** The ELAN panel works through libinput with no extra config.
  Test with `libinput list-devices` / `libinput debug-events`. If coordinates
  need calibration, add a udev rule with `LIBINPUT_CALIBRATION_MATRIX`.
- **Scaling.** 1080p on 12.5" is about 176 PPI. `hyprland.lua` uses
  `scale = "auto"`; set `scale = "1.25"` on `eDP-1` if the UI is too small.
- **Battery.** Single `BAT0`, currently about 70% of design capacity. TLP charge
  thresholds are set to 80/85 in `modules/thinkpad.nix`.
- **Fingerprint.** No reader was detected on USB, so `fprintd` is not enabled.

## Known issues in the existing dotfiles

- `~/.p10k.zsh` is not tracked, so Powerlevel10k prompts for setup on first run.
- The repo `.zshrc` loads `OMZP::archlinux` and pacman-related aliases, which are
  meaningless on NixOS.
- Repo scripts are wrapped by `home/dotfiles.nix` because their
  `#!/usr/bin/env bash` shebang does not exist on NixOS. If you add a new
  script that is executed directly, add a wrapper there too.

## Updating

```bash
nix flake update
sudo nixos-rebuild switch --flake .#x280
```

`home-manager` generations are managed by NixOS; roll back with
`sudo nixos-rebuild switch --rollback`.
