#!/usr/bin/env bash
#
# nixos/install.sh — destructive, opinionated NixOS installer for this flake.
#
# Run from the NixOS live ISO as root:
#
#   ./install.sh --disk /dev/nvme0n1
#
# It wipes the target disk and creates:
#   p1  2 GiB  vfat   label ESP
#   p2  rest   LUKS2  label cryptroot -> btrfs subvolumes
#       @  /        @home /home      @nix /nix
#       @log /var/log                @cache /var/cache
#
set -euo pipefail

HOST="x280"
DISK=""
ASSUME_YES=0
DRY_RUN=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: $0 --disk /dev/nvme0n1 [options]

Options:
  --disk DEV     Target whole disk (required)
  --host NAME    Flake host to install (default: $HOST)
  --yes, -y      Skip the interactive confirmation (dangerous)
  --dry-run      Print the commands without executing them
  -h, --help     Show this help

The disk is completely erased. Back up first.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk)    DISK="${2:-}"; shift 2 ;;
    --host)    HOST="${2:-}"; shift 2 ;;
    --yes|-y)  ASSUME_YES=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

run() {
  printf '  +'
  printf ' %q' "$@"
  printf '\n'
  if (( DRY_RUN == 0 )); then
    "$@"
  fi
}

[[ $EUID -eq 0 ]] || die "run this as root (from the NixOS live ISO)"
[[ -d /sys/firmware/efi ]] || die "not booted in UEFI mode"
[[ -n "$DISK" ]] || { usage; die "--disk is required"; }
[[ -b "$DISK" ]] || die "$DISK is not a block device"
[[ -f "$REPO_DIR/flake.nix" ]] || die "flake not found at $REPO_DIR/flake.nix"
[[ -f "$REPO_DIR/nixos/hosts/$HOST/default.nix" ]] || die "unknown host: $HOST"
[[ -f "$REPO_DIR/nixos/hosts/$HOST/storage.nix" ]] || die "host $HOST has no storage.nix"

for cmd in sgdisk cryptsetup mkfs.btrfs mkfs.fat nixos-install; do
  command -v "$cmd" >/dev/null 2>&1 || die "missing command: $cmd"
done

mountpoint -q /mnt && die "/mnt is already mounted; unmount it first"

# Do not wipe the disk that hosts the running system or this repository.
ROOT_SRC="$(findmnt -n -o SOURCE / 2>/dev/null | sed 's/\[.*//' || true)"
case "$ROOT_SRC" in
  "$DISK"|"$DISK"p*|"$DISK"[0-9]*) die "$DISK hosts the running system ($ROOT_SRC)" ;;
esac

REPO_SRC="$(findmnt -n -o SOURCE -T "$REPO_DIR" 2>/dev/null | sed 's/\[.*//' || true)"
case "$REPO_SRC" in
  "$DISK"|"$DISK"p*|"$DISK"[0-9]*)
    die "this repository lives on $DISK; copy it to /tmp or a USB stick first"
    ;;
esac

if lsblk -n -o MOUNTPOINTS "$DISK" | grep -q '[^[:space:]]'; then
  die "$DISK has mounted partitions; unmount them first"
fi

SIZE_BYTES="$(blockdev --getsize64 "$DISK")"
(( SIZE_BYTES >= 32 * 1024 * 1024 * 1024 )) || die "$DISK is smaller than 32 GiB"

if [[ "$DISK" =~ [0-9]$ ]]; then
  PART_PREFIX="p"
else
  PART_PREFIX=""
fi
ESP="${DISK}${PART_PREFIX}1"
CRYPT="${DISK}${PART_PREFIX}2"

log "target disk : $DISK ($(numfmt --to=iec "$SIZE_BYTES"))"
log "host        : $HOST"
log "flake       : $REPO_DIR#$HOST"
echo
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$DISK"
echo

if (( ASSUME_YES == 0 )); then
  warn "This ERASES $DISK completely, including the current operating system."
  read -r -p "Type the device path to continue: " CONFIRM
  [[ "$CONFIRM" == "$DISK" ]] || die "aborted"
fi

MOUNTED=0
cleanup() {
  set +e
  if (( MOUNTED )); then
    umount -R /mnt 2>/dev/null
  fi
  cryptsetup close cryptroot 2>/dev/null
}
trap cleanup EXIT

log "partitioning"
run wipefs -a "$DISK"
run sgdisk --zap-all "$DISK"
run sgdisk \
  -n1:0:+2G -t1:ef00 -c1:ESP \
  -n2:0:0   -t2:8309 -c2:cryptroot \
  "$DISK"
run partx -u "$DISK" || true
run udevadm settle

for _ in $(seq 1 10); do
  [[ -b "$ESP" && -b "$CRYPT" ]] && break
  sleep 1
done
[[ -b "$ESP" && -b "$CRYPT" ]] || die "partitions did not appear"

log "creating LUKS2 container on $CRYPT"
run cryptsetup luksFormat --type luks2 --label cryptroot "$CRYPT"
run cryptsetup open "$CRYPT" cryptroot

log "creating btrfs filesystem"
run mkfs.btrfs -f -L nixos /dev/mapper/cryptroot
run mount /dev/mapper/cryptroot /mnt
MOUNTED=1

run btrfs subvolume create \
  /mnt/@ \
  /mnt/@home \
  /mnt/@nix \
  /mnt/@log \
  /mnt/@cache
run umount /mnt

run mount -o compress=zstd:3,noatime,subvol=@ /dev/mapper/cryptroot /mnt
run mkdir -p /mnt/home /mnt/nix /mnt/var/log /mnt/var/cache /mnt/boot
run mount -o compress=zstd:3,noatime,subvol=@home  /dev/mapper/cryptroot /mnt/home
run mount -o compress=zstd:3,noatime,subvol=@nix   /dev/mapper/cryptroot /mnt/nix
run mount -o compress=zstd:3,noatime,subvol=@log   /dev/mapper/cryptroot /mnt/var/log
run mount -o compress=zstd:3,noatime,subvol=@cache /dev/mapper/cryptroot /mnt/var/cache

log "formatting and mounting the EFI system partition"
run mkfs.fat -F32 -n ESP "$ESP"
run mount "$ESP" /mnt/boot

log "copying the repository into the target home"
run mkdir -p /mnt/home/momo/Projects
run cp -a "$REPO_DIR" /mnt/home/momo/Projects/My-config
# First normal user on NixOS gets uid/gid 1000.
run chown -R 1000:1000 /mnt/home/momo

export NIX_CONFIG="experimental-features = nix-command flakes"

if ! getent hosts cache.nixos.org >/dev/null 2>&1; then
  warn "cannot resolve cache.nixos.org; the install needs network access"
fi

log "installing NixOS (host: $HOST)"
run nixos-install --flake "path:$REPO_DIR#$HOST" --no-root-passwd

if (( DRY_RUN )); then
  log "dry run complete; nothing was changed"
  exit 0
fi

log "done"
cat <<EOF

NixOS has been installed to $DISK.

Next steps:
  1. reboot (remove the USB stick)
  2. log in as momo with the password "nixos"
  3. run: passwd
  4. rebuild from the repo with:
       sudo nixos-rebuild switch --flake path:~/Projects/My-config#$HOST

If you want to keep working in this live environment, the new system is
mounted at /mnt. Reboot when ready.
EOF
