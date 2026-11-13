#!/usr/bin/env bash
# setup.sh — interactive installer/linker for this dotfiles repo.
#
# Merges the old setup scripts:
#   install_pack.sh   → setup.sh packages
#   change_Shell.sh   → setup.sh shell
#   install_conf.sh   → setup.sh config
#   backup.sh         → setup.sh backup
#
# With no subcommand it starts an interactive wizard.
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="$HOME/.local/bin"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/matugen"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
BACKUP_ROOT="$HOME/config"
MATUGEN_STATE="$STATE_DIR/selected.toml"

CONFIG_DIRS=(
  waybar fastfetch kitty hypr matugen mako alacritty
  gtk-3.0 gtk-4.0 qt5ct qt6ct
  wofi wofi-power wofi-screenshot wofi-wallpaper
  yazi nvim
)
EXTRA_LINKS=(tmux/.tmux.conf kdeglobals)
CONFIG_ITEMS=("${CONFIG_DIRS[@]}" "${EXTRA_LINKS[@]}")

BACKUP_ITEMS=()
for _d in "${CONFIG_DIRS[@]}"; do BACKUP_ITEMS+=(".config/$_d"); done
BACKUP_ITEMS+=(.bashrc .zshrc .config/kdeglobals tmux/.tmux.conf)
unset _d

PKG_GROUPS=(essentials hyprland terminal theme apps aur)
declare -A PKG_MEMBERS=(
  [essentials]="base-devel git curl wget unzip tree htop fd nodejs npm python-pip"
  [hyprland]="hyprland hyprshutdown waybar wofi mako hyprlock hypridle awww grim slurp wl-clipboard libnotify brightnessctl playerctl wireplumber dolphin bluetui"
  [terminal]="kitty nvim tmux yazi lazygit opencode tree-sitter"
  [theme]="matugen imagemagick ttf-jetbrains-mono-nerd adw-gtk-theme kconfig"
  [apps]="librewolf vlc"
  [aur]="bibata-cursor-theme wifitui-bin"
)
AUR_MEMBERS=(bibata-cursor-theme wifitui-bin)
declare -A SEEN_PAC=() SEEN_AUR=()

MATUGEN_TARGETS=(
  hyprland kitty mako waybar wofi wofi-power wofi-screenshot
  gtk3 gtk4 qt5ct qt6ct kde
)
declare -A MATUGEN_KEY=(
  [hyprland]=hyprland [kitty]=kitty [mako]=mako [waybar]=waybar
  [wofi]=wofi [wofi-power]=wofi_power [wofi-screenshot]=wofi_screenshot
  [gtk3]=gtk3 [gtk4]=gtk4 [qt5ct]=qt5ct [qt6ct]=qt6ct [kde]=kde
)

# ─── state ────────────────────────────────────────────────────────────────────
CMD=""
INTERACTIVE=0
DRY_RUN=0
ASSUME_YES=0
SHELL_CHOICE=ask
SET_DEFAULT=ask
PKG_CHOICE=ask
CFG_CHOICE=ask
DO_BACKUP=ask
MATUGEN_CHOICE=ask
MT_CHOICE=all
WP_CHOICE=repo
THEME_ACTION=theme
REGENERATE=0

PAC_RESOLVED=0
CFG_RESOLVED=0
MT_RESOLVED=0
WP_RESOLVED=0

PAC_SEL=()
AUR_SEL=()
PAC_POOL=()
AUR_POOL=()
PKG_GROUP_SEL=()
CFG_SEL=()
MT_SEL=()
WALLPAPER=""

if [[ -t 1 ]]; then
  C_GREEN=$'\033[32m'
  C_RESET=$'\033[0m'
else
  C_GREEN=""
  C_RESET=""
fi

# ─── output ───────────────────────────────────────────────────────────────────
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'warning: %s\n' "$*" >&2; }
info() { printf '\n%s── %s ──%s\n' "$C_GREEN" "$*" "$C_RESET"; }

usage() {
  cat <<'EOF'
Usage: setup.sh [subcommand] [options]

Subcommands (no subcommand = interactive wizard):
  packages   update system and install selected packages (Arch only)
  shell      install/select a shell and optionally make it the default
  config     back up and symlink dotfiles into ~/.config and ~/.local/bin
  backup     copy the current configs to ~/config/config<date>
  matugen    apply the selected Matugen targets / wallpaper
  all        shell + config + matugen

Options:
  --shell=zsh|bash|fish|none
  --set-default | --no-set-default
  --packages=all|none|group,group|pkg,pkg
  --configs=all|none|name,name
  --backup | --no-backup
  --matugen=yes|no|install
  --matugen-targets=all|none|hyprland,kitty,wofi-power,...
  --wallpaper=repo:<file>|path:<file>|current|none
  --theme-action=theme|colors-only|none
  --regenerate
  --dry-run
  -y, --yes
  -h, --help

Interactive mode asks about the shell, package groups
(with an optional per-package pass), configs, backup,
and all Matugen options (install, link, targets,
wallpaper, action, regenerate).
EOF
}

# ─── prompts ──────────────────────────────────────────────────────────────────
ask_yes() {
  local prompt=$1 def=${2:-y} ans hint='[Y/n]'
  [[ $def == n ]] && hint='[y/N]'
  while :; do
    read -r -p "$prompt $hint " ans || return 1
    ans=${ans:-$def}
    case ${ans,,} in
      y|yes) return 0 ;;
      n|no)  return 1 ;;
    esac
    echo "please answer y or n" >&2
  done
}

choose_one() {
  local prompt=$1 default=$2; shift 2
  local -a items=("$@")
  local ans i
  while :; do
    printf '%s\n' "$prompt" >&2
    for i in "${!items[@]}"; do
      printf '  %d) %s\n' "$((i + 1))" "${items[i]}" >&2
    done
    read -r -p "Choice [$default]: " ans || return 1
    ans=${ans:-$default}
    if [[ $ans =~ ^[0-9]+$ ]] && [[ $ans -ge 1 ]] && [[ $ans -le ${#items[@]} ]]; then
      printf '%s\n' "${items[ans - 1]}"
      return 0
    fi
    for i in "${items[@]}"; do
      if [[ $ans == "$i" ]]; then
        printf '%s\n' "$i"
        return 0
      fi
    done
    echo "invalid: $ans" >&2
  done
}

# choose_many <prompt> <all|none> <result-array> <items...>
# Numbers toggle, ranges select, a=all, n=none, Enter=done.
choose_many() {
  local prompt=$1 default=$2 out=$3; shift 3
  local -n result=$out
  local -a items=("$@")
  declare -A sel=()
  local ans i tok lo hi

  if [[ $default == all ]]; then
    for i in "${!items[@]}"; do sel[$i]=1; done
  fi

  while :; do
    printf '%s\n' "$prompt" >&2
    for i in "${!items[@]}"; do
      if [[ -n ${sel[$i]:-} ]]; then
        printf '  %2d) [x] %s\n' "$((i + 1))" "${items[i]}" >&2
      else
        printf '  %2d) [ ] %s\n' "$((i + 1))" "${items[i]}" >&2
      fi
    done
    read -r -p "Toggle (1 3 5-7 · a=all · n=none · Enter=done) " ans || return 1
    [[ -z $ans ]] && break
    case ${ans,,} in
      a|all)  for i in "${!items[@]}"; do sel[$i]=1; done; continue ;;
      n|none) sel=(); continue ;;
    esac
    for tok in ${ans//,/ }; do
      if [[ $tok =~ ^([0-9]+)-([0-9]+)$ ]]; then
        lo=${BASH_REMATCH[1]}
        hi=${BASH_REMATCH[2]}
        for ((i = lo - 1; i < hi; i++)); do
          if [[ $i -ge 0 ]] && [[ $i -lt ${#items[@]} ]]; then sel[$i]=1; fi
        done
      elif [[ $tok =~ ^[0-9]+$ ]]; then
        i=$((tok - 1))
        if [[ $i -lt 0 ]] || [[ $i -ge ${#items[@]} ]]; then
          echo "no item $tok" >&2
          continue
        fi
        if [[ -n ${sel[$i]:-} ]]; then
          unset "sel[$i]"
        else
          sel[$i]=1
        fi
      else
        echo "ignored: $tok" >&2
      fi
    done
  done

  result=()
  for i in "${!items[@]}"; do
    if [[ -n ${sel[$i]:-} ]]; then result+=("${items[i]}"); fi
  done
  return 0
}

# ─── helpers ──────────────────────────────────────────────────────────────────
is_arch()  { [[ -f /etc/arch-release ]]; }
is_nixos() { [[ -e /etc/NIXOS ]]; }
run_priv() { if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

require_user() {
  if [[ $EUID -eq 0 ]]; then
    die "run this step as your normal user, not root (root is only for 'setup.sh packages')"
  fi
}

is_selected() {
  local needle=$1 x
  shift
  for x in "$@"; do
    if [[ $x == "$needle" ]]; then return 0; fi
  done
  return 1
}

# ─── packages ─────────────────────────────────────────────────────────────────
add_pkg() {
  local p=$1
  if [[ " ${AUR_MEMBERS[*]} " == *" $p "* ]]; then
    if [[ -z ${SEEN_AUR[$p]:-} ]]; then SEEN_AUR[$p]=1; AUR_POOL+=("$p"); fi
  else
    if [[ -z ${SEEN_PAC[$p]:-} ]]; then SEEN_PAC[$p]=1; PAC_POOL+=("$p"); fi
  fi
}

flatten_groups() {
  local g p
  PAC_POOL=()
  AUR_POOL=()
  SEEN_PAC=()
  SEEN_AUR=()
  for g in "$@"; do
    if [[ -z ${PKG_MEMBERS[$g]:-} ]]; then die "unknown package group: $g"; fi
    for p in ${PKG_MEMBERS[$g]}; do add_pkg "$p"; done
  done
}

resolve_package_spec() {
  local spec=${1:-all}
  local tok p
  local -a groups=() extras=()
  PAC_SEL=()
  AUR_SEL=()

  case $spec in
    ask|all) groups=("${PKG_GROUPS[@]}") ;;
    none)    PAC_RESOLVED=1; return 0 ;;
    *)
      local -a toks=()
      IFS=',' read -r -a toks <<< "$spec"
      for tok in "${toks[@]}"; do
        tok=${tok//[[:space:]]/}
        [[ -z $tok ]] && continue
        if [[ -n ${PKG_MEMBERS[$tok]:-} ]]; then
          groups+=("$tok")
        else
          extras+=("$tok")
        fi
      done
      ;;
  esac

  flatten_groups "${groups[@]}"
  for tok in "${extras[@]}"; do
    if [[ $tok == aur:* ]]; then
      p=${tok#aur:}
      if [[ -z ${SEEN_AUR[$p]:-} ]]; then SEEN_AUR[$p]=1; AUR_POOL+=("$p"); fi
    else
      add_pkg "$tok"
    fi
  done

  PAC_SEL=("${PAC_POOL[@]}")
  AUR_SEL=("${AUR_POOL[@]}")
  PAC_RESOLVED=1
}

wizard_packages() {
  choose_many "Package groups" all PKG_GROUP_SEL "${PKG_GROUPS[@]}" || die "cancelled"
  flatten_groups "${PKG_GROUP_SEL[@]}"
  PAC_SEL=("${PAC_POOL[@]}")
  AUR_SEL=("${AUR_POOL[@]}")
  if [[ ${#PAC_SEL[@]} -gt 0 ]] && ask_yes "Customize individual pacman packages?" n; then
    choose_many "Pacman packages" all PAC_SEL "${PAC_POOL[@]}" || die "cancelled"
  fi
  PAC_RESOLVED=1
}

install_yay() {
  local tmp
  tmp=$(mktemp -d)
  if ! (
    git clone --depth=1 https://aur.archlinux.org/yay.git "$tmp/yay" &&
    cd "$tmp/yay" &&
    makepkg -si --noconfirm
  ); then
    rm -rf "$tmp"
    die "failed to build yay"
  fi
  rm -rf "$tmp"
}

install_packages() {
  if [[ $PAC_RESOLVED -eq 0 ]]; then resolve_package_spec "$PKG_CHOICE"; fi
  if [[ $MATUGEN_CHOICE == no ]]; then
    local -a kept=()
    local p
    for p in "${PAC_SEL[@]}"; do
      if [[ $p != matugen ]]; then kept+=("$p"); fi
    done
    PAC_SEL=("${kept[@]}")
  fi

  local total=$((${#PAC_SEL[@]} + ${#AUR_SEL[@]}))
  if [[ $total -eq 0 ]]; then info "No packages selected"; return 0; fi

  if [[ $DRY_RUN -eq 1 ]]; then
    info "Would install packages"
    printf '  pacman (%d): %s\n' "${#PAC_SEL[@]}" "${PAC_SEL[*]:-}"
    printf '  AUR    (%d): %s\n' "${#AUR_SEL[@]}" "${AUR_SEL[*]:-}"
    return 0
  fi

  is_arch || die "package installation is Arch-only"

  info "Updating system repositories"
  run_priv pacman -Syu --noconfirm

  if [[ ${#PAC_SEL[@]} -gt 0 ]]; then
    info "Installing pacman packages"
    run_priv pacman -S --noconfirm --needed "${PAC_SEL[@]}"
  fi

  if [[ ${#AUR_SEL[@]} -gt 0 ]]; then
    if [[ $EUID -eq 0 ]]; then
      warn "skipping AUR packages as root: ${AUR_SEL[*]}"
      warn "run 'setup.sh packages --packages=aur' as your normal user afterwards"
    else
      if ! command -v yay >/dev/null 2>&1; then install_yay; fi
      info "Installing AUR packages"
      yay -S --needed --noconfirm "${AUR_SEL[@]}"
    fi
  fi
}

# ─── shell ────────────────────────────────────────────────────────────────────
install_shell_pkg() {
  local sh=$1
  if command -v "$sh" >/dev/null 2>&1; then return 0; fi
  if is_nixos; then
    warn "NixOS: install $sh through configuration.nix, not this script"
    return 1
  fi
  case $sh in
    zsh)
      if is_arch; then run_priv pacman -S --noconfirm --needed zsh
      elif [[ -f /etc/debian_version ]]; then run_priv apt-get update && run_priv apt-get install -y zsh
      elif [[ -f /etc/fedora-release ]]; then run_priv dnf install -y zsh
      else die "no supported package manager for zsh"; fi
      ;;
    bash)
      if is_arch; then run_priv pacman -S --noconfirm --needed bash
      elif [[ -f /etc/debian_version ]]; then run_priv apt-get update && run_priv apt-get install -y bash
      elif [[ -f /etc/fedora-release ]]; then run_priv dnf install -y bash
      else die "no supported package manager for bash"; fi
      ;;
    fish)
      if is_arch; then run_priv pacman -S --noconfirm --needed fish
      elif [[ -f /etc/debian_version ]]; then run_priv apt-get update && run_priv apt-get install -y fish
      elif [[ -f /etc/fedora-release ]]; then run_priv dnf install -y fish
      else die "no supported package manager for fish"; fi
      ;;
    *) die "unknown shell: $sh" ;;
  esac
}

change_shell() {
  local choice=$SHELL_CHOICE
  [[ $choice == ask ]] && choice=zsh
  if [[ $choice == none ]]; then info "Shell unchanged"; return 0; fi

  if [[ $DRY_RUN -eq 1 ]]; then
    info "Would install/configure shell: $choice (default: $SET_DEFAULT)"
    return 0
  fi

  install_shell_pkg "$choice" || return 0

  if is_nixos; then
    warn "NixOS manages shells declaratively: set users.defaultUserShell = pkgs.$choice"
    return 0
  fi

  local path target_user do_default
  path=$(command -v "$choice")
  target_user=${SUDO_USER:-${USER:-$(id -un)}}
  do_default=$SET_DEFAULT
  if [[ $do_default == ask ]]; then
    if [[ $INTERACTIVE -eq 1 ]]; then
      if ask_yes "Set $choice as your default shell?" y; then
        do_default=yes
      else
        do_default=no
      fi
    else
      do_default=no
    fi
  fi

  if [[ $do_default == yes ]]; then
    # chsh requires the shell to be listed in /etc/shells.
    if ! grep -qx "$path" /etc/shells 2>/dev/null; then
      printf '%s\n' "$path" | run_priv tee -a /etc/shells >/dev/null
    fi
    info "Changing default shell to $choice"
    run_priv chsh -s "$path" "$target_user"
    echo "Default shell changed — log out and back in (or run: exec $choice)"
  else
    echo "Default shell unchanged. To change it later: chsh -s $path"
  fi
}

# ─── configs ──────────────────────────────────────────────────────────────────
resolve_config_spec() {
  local spec=${1:-all}
  local tok
  CFG_SEL=()

  case $spec in
    ask|all) CFG_SEL=("${CONFIG_ITEMS[@]}") ;;
    none)    ;;
    *)
      local -a toks=()
      IFS=',' read -r -a toks <<< "$spec"
      for tok in "${toks[@]}"; do
        tok=${tok//[[:space:]]/}
        [[ -z $tok ]] && continue
        if ! is_selected "$tok" "${CONFIG_ITEMS[@]}"; then die "unknown config: $tok"; fi
        CFG_SEL+=("$tok")
      done
      ;;
  esac

  CFG_RESOLVED=1
}

backup_configs() {
  local dest="$BACKUP_ROOT/config$(date +%F)"
  local rel src target

  if [[ $DRY_RUN -eq 1 ]]; then
    info "Would back up configs to $dest"
    return 0
  fi

  mkdir -p "$dest"
  info "Backing up configs to $dest"
  for rel in "${BACKUP_ITEMS[@]}"; do
    src="$HOME/$rel"
    if [[ ! -e $src ]] && [[ ! -L $src ]]; then
      echo "  skip (missing): $rel"
      continue
    fi
    target="$dest/$rel"
    rm -rf "$target"
    mkdir -p "$(dirname "$target")"
    cp -a "$src" "$target"
    echo "  $rel"
  done
}

link_tree() {
  local src=$1 dst=$2
  local item base target
  local old_dotglob old_nullglob

  mkdir -p "$dst"
  old_dotglob=$(shopt -p dotglob || true)
  old_nullglob=$(shopt -p nullglob || true)
  shopt -s dotglob nullglob

  for item in "$src"/*; do
    base=${item##*/}
    target="$dst/$base"
    if [[ $item -ef $target ]]; then continue; fi
    if [[ -e $target ]] && [[ ! -L $target ]]; then
      mv "$target" "${target}.bak.$(date +%s)"
      echo "  backed up $target"
    fi
    ln -sfnr "$item" "$target"
  done

  eval "$old_dotglob"
  eval "$old_nullglob"
}

# True when a real directory only contains symlinks that point at the
# matching items in the repo (i.e. it was created by a previous run).
dir_is_managed() {
  local dst=$1 src=$2
  local entry base
  local -a entries=()
  local old_dotglob old_nullglob

  old_dotglob=$(shopt -p dotglob || true)
  old_nullglob=$(shopt -p nullglob || true)
  shopt -s dotglob nullglob
  entries=("$dst"/*)
  eval "$old_dotglob"
  eval "$old_nullglob"

  if [[ ${#entries[@]} -eq 0 ]]; then return 0; fi

  for entry in "${entries[@]}"; do
    if [[ ! -L $entry ]]; then return 1; fi
    base=${entry##*/}
    if [[ ! -e $src/$base ]]; then return 1; fi
    if [[ "$(readlink -f "$entry")" != "$(readlink -f "$src/$base")" ]]; then
      return 1
    fi
  done
  return 0
}

link_config_dir() {
  local folder=$1
  local src="$DOTS_DIR/$folder"
  local dst="$CONFIG_DIR/$folder"
  local resolved

  if [[ ! -d $src ]]; then warn "missing in repo: $folder"; return 0; fi

  if [[ -e $dst ]] && [[ ! -L $dst ]]; then
    if ! dir_is_managed "$dst" "$src"; then
      rm -rf "$dst.bak"
      mv "$dst" "$dst.bak"
      echo "backed up $dst → $dst.bak"
    fi
  elif [[ -L $dst ]]; then
    resolved=$(readlink -f "$dst")
    if [[ $resolved == "$src" ]]; then
      echo "already linked: $folder"
      return 0
    fi
    warn "replacing stale symlink $dst → $resolved"
    rm -rf "$dst.bak"
    mv "$dst" "$dst.bak"
    echo "backed up $dst → $dst.bak"
  fi

  link_tree "$src" "$dst"
  echo "linked $folder"
}

link_extra() {
  local item=$1 src dst

  case $item in
    kdeglobals)      src="$DOTS_DIR/kdeglobals";        dst="$CONFIG_DIR/kdeglobals" ;;
    tmux/.tmux.conf) src="$DOTS_DIR/tmux/.tmux.conf";   dst="$HOME/.tmux.conf" ;;
    *) warn "unknown extra link: $item"; return 0 ;;
  esac

  if [[ ! -f $src ]]; then warn "missing in repo: $src"; return 0; fi

  if [[ -e $dst ]] && [[ ! -L $dst ]]; then
    mv "$dst" "${dst}.bak"
    echo "backed up $dst → ${dst}.bak"
  fi

  if [[ -L $dst ]] && [[ "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    return 0
  fi

  ln -sfnr "$src" "$dst"
  echo "linked $src → $dst"
}

link_scripts() {
  local pair src name

  if is_nixos; then
    warn "NixOS: skipping ~/.local/bin links (home-manager provides the wrappers)"
    return 0
  fi

  mkdir -p "$BIN_DIR"
  for pair in \
    "wofi-power.sh:wofi-power" \
    "wofi-screenshot.sh:wofi-screenshot" \
    "wofi-wallpaper.sh:wofi-wallpaper" \
    "set-theme.sh:set-theme" \
    "matugen/post-hook-scripts/gtk-themes-reload.sh:gtk-themes-reload"
  do
    src=${pair%%:*}
    name=${pair##*:}
    if [[ ! -f $DOTS_DIR/$src ]]; then warn "missing in repo: $src"; continue; fi
    if [[ -e $BIN_DIR/$name ]] && [[ ! -L $BIN_DIR/$name ]]; then
      mv "$BIN_DIR/$name" "$BIN_DIR/$name.bak"
      echo "backed up $BIN_DIR/$name → $BIN_DIR/$name.bak"
    fi
    ln -sfnr "$DOTS_DIR/$src" "$BIN_DIR/$name"
    echo "linked $src → $BIN_DIR/$name"
  done
}

install_configs() {
  if [[ $CFG_RESOLVED -eq 0 ]]; then resolve_config_spec "$CFG_CHOICE"; fi

  if is_nixos; then
    warn "NixOS: configs are managed by home-manager (nixos/home/dotfiles.nix)"
    if [[ $INTERACTIVE -eq 1 ]]; then
      if ! ask_yes "Run the manual symlinker anyway?" n; then return 0; fi
    else
      die "refusing to symlink on NixOS; use home-manager instead"
    fi
  fi

  if [[ $MATUGEN_CHOICE == no ]]; then
    local -a kept=()
    local c
    for c in "${CFG_SEL[@]}"; do
      if [[ $c != matugen ]]; then kept+=("$c"); fi
    done
    CFG_SEL=("${kept[@]}")
  fi

  if [[ ${#CFG_SEL[@]} -eq 0 ]]; then info "No configs selected"; return 0; fi

  if [[ $DO_BACKUP == ask ]]; then
    if [[ $INTERACTIVE -eq 1 ]]; then
      if ask_yes "Back up current configs first?" y; then DO_BACKUP=yes; else DO_BACKUP=no; fi
    else
      DO_BACKUP=no
    fi
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    info "Would link configs into $CONFIG_DIR"
    printf '  %s\n' "${CFG_SEL[@]}"
    if [[ $DO_BACKUP == yes ]]; then
      echo "  (after backing up to $BACKUP_ROOT/config$(date +%F))"
    fi
    return 0
  fi

  if [[ $DO_BACKUP == yes ]]; then backup_configs; fi

  local folder item
  for folder in "${CONFIG_DIRS[@]}"; do
    if is_selected "$folder" "${CFG_SEL[@]}"; then link_config_dir "$folder"; fi
  done
  for item in "${EXTRA_LINKS[@]}"; do
    if is_selected "$item" "${CFG_SEL[@]}"; then link_extra "$item"; fi
  done

  link_scripts
}

# ─── matugen ──────────────────────────────────────────────────────────────────
resolve_targets() {
  local spec=${1:-all}
  local tok
  declare -A seen=()
  MT_SEL=()

  case $spec in
    ask|all) MT_SEL=("${MATUGEN_TARGETS[@]}") ;;
    none)    ;;
    *)
      local -a toks=()
      IFS=',' read -r -a toks <<< "$spec"
      for tok in "${toks[@]}"; do
        tok=${tok//[[:space:]]/}
        [[ -z $tok ]] && continue
        if [[ -z ${MATUGEN_KEY[$tok]:-} ]]; then die "unknown Matugen target: $tok"; fi
        if [[ -z ${seen[$tok]:-} ]]; then seen[$tok]=1; MT_SEL+=("$tok"); fi
      done
      ;;
  esac

  MT_RESOLVED=1
}

matugen_src() {
  if [[ -f "$CONFIG_DIR/matugen/config.toml" ]]; then
    printf '%s\n' "$CONFIG_DIR/matugen/config.toml"
  else
    printf '%s\n' "$DOTS_DIR/matugen/config.toml"
  fi
}

# Keep [config] and only the [templates.*] blocks for the chosen targets.
build_matugen_config() {
  local src=$1 dst=$2
  shift 2
  local t
  local -a keys=()
  local csv

  for t in "$@"; do keys+=("${MATUGEN_KEY[$t]}"); done
  csv=$(IFS=,; printf '%s' "${keys[*]}")

  awk -v wanted="$csv" '
    BEGIN {
      n = split(wanted, w, ",")
      for (i = 1; i <= n; i++) want[w[i]] = 1
      show = 1
    }
    /^[[:space:]]*\[templates\./ {
      name = $0
      sub(/^[^[]*\[templates\./, "", name)
      sub(/\].*$/, "", name)
      show = (name in want)
      if (show) print
      found[name] = 1
      next
    }
    /^[[:space:]]*\[/ { show = 1 }
    show { print }
    END {
      for (i = 1; i <= n; i++) {
        if (!(w[i] in found)) {
          printf "missing template: %s\n", w[i] > "/dev/stderr"
          exit 2
        }
      }
    }
  ' "$src" > "$dst"
}

save_selection() {
  local -a targets=("$@")
  local src
  mkdir -p "$STATE_DIR"
  src=$(matugen_src)
  build_matugen_config "$src" "$MATUGEN_STATE" ${targets[@]+"${targets[@]}"}
}

persist_selection() {
  if [[ ${#MT_SEL[@]} -eq ${#MATUGEN_TARGETS[@]} ]]; then
    rm -f "$MATUGEN_STATE"
    echo "matugen: all targets selected, using the repo config"
  else
    save_selection "${MT_SEL[@]}"
    echo "matugen: saved ${#MT_SEL[@]} target(s) to $MATUGEN_STATE"
  fi
}

filter_targets() {
  local t
  local -a keep=()

  for t in "${MT_SEL[@]}"; do
    case $t in
      kde)
        if ! command -v kwriteconfig6 >/dev/null 2>&1; then
          warn "Matugen target 'kde' needs kwriteconfig6; dropping it"
          continue
        fi
        ;;
      gtk3|gtk4)
        if ! command -v gsettings >/dev/null 2>&1; then
          warn "Matugen target '$t' needs gsettings; dropping it"
          continue
        fi
        ;;
    esac
    keep+=("$t")
  done

  MT_SEL=("${keep[@]}")
}

read_current_wallpaper() {
  local wp
  wp=$(cat "$CACHE_DIR/current-wallpaper" 2>/dev/null || true)
  if [[ -z $wp ]] || [[ ! -f $wp ]]; then
    die "no current wallpaper recorded at $CACHE_DIR/current-wallpaper"
  fi
  printf '%s\n' "$wp"
}

list_wallpapers() {
  find -L "$DOTS_DIR/hypr/wallpaper" -maxdepth 1 -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) \
    -printf '%f\n' | sort
}

resolve_wallpaper() {
  local f
  case $WP_CHOICE in
    repo|repo:*)
      f=${WP_CHOICE#repo:}
      if [[ $f == "$WP_CHOICE" ]] || [[ -z $f ]]; then f=wallpaper-26.png; fi
      WALLPAPER="$DOTS_DIR/hypr/wallpaper/$f"
      ;;
    path:*)  WALLPAPER=${WP_CHOICE#path:} ;;
    current) WALLPAPER=$(read_current_wallpaper) ;;
    none|"") WALLPAPER="" ;;
    *)       WALLPAPER=$WP_CHOICE ;;
  esac

  WP_RESOLVED=1
  if [[ -n $WALLPAPER ]] && [[ ! -f $WALLPAPER ]]; then
    die "wallpaper not found: $WALLPAPER"
  fi
}

run_colors_only() {
  local -a cfg_args=()
  if [[ -f $MATUGEN_STATE ]]; then cfg_args=(-c "$MATUGEN_STATE"); fi
  command -v matugen >/dev/null 2>&1 || die "matugen is not installed"
  matugen image "$WALLPAPER" ${cfg_args[@]+"${cfg_args[@]}"}
}

wizard_matugen() {
  if ! ask_yes "Set up Matugen colour generation?" y; then
    MATUGEN_CHOICE=no
    THEME_ACTION=none
    return 0
  fi

  MATUGEN_CHOICE=yes
  if ! is_selected matugen "${PAC_SEL[@]}"; then PAC_SEL+=(matugen); fi
  if ! is_selected matugen "${CFG_SEL[@]}"; then CFG_SEL+=(matugen); fi

  choose_many "Matugen targets" all MT_SEL "${MATUGEN_TARGETS[@]}" || die "cancelled"
  MT_RESOLVED=1

  THEME_ACTION=$(choose_one "Apply action?" theme theme colors-only none) || die "cancelled"

  if [[ $THEME_ACTION != none ]]; then
    local source choice
    source=$(choose_one "Wallpaper source?" repo repo path current none) || die "cancelled"
    case $source in
      repo)
        local -a wps=()
        mapfile -t wps < <(list_wallpapers)
        if [[ ${#wps[@]} -eq 0 ]]; then die "no wallpapers in $DOTS_DIR/hypr/wallpaper"; fi
        choice=$(choose_one "Wallpaper" "wallpaper-26.png" "${wps[@]}") || die "cancelled"
        WALLPAPER="$DOTS_DIR/hypr/wallpaper/$choice"
        ;;
      path)
        read -r -p "Wallpaper path: " WALLPAPER || die "cancelled"
        ;;
      current)
        WALLPAPER=$(read_current_wallpaper)
        ;;
      none)
        WALLPAPER=""
        THEME_ACTION=none
        ;;
    esac
    WP_RESOLVED=1
    if [[ -n $WALLPAPER ]] && [[ ! -f $WALLPAPER ]]; then die "wallpaper not found: $WALLPAPER"; fi
  fi

  if ask_yes "Regenerate existing setup now (current wallpaper)?" n; then
    REGENERATE=1
    THEME_ACTION=colors-only
    WALLPAPER=$(read_current_wallpaper)
    WP_RESOLVED=1
  fi
}

matugen_step() {
  if [[ $MATUGEN_CHOICE == no ]]; then
    warn "Matugen disabled by choice"
    if [[ $DRY_RUN -eq 0 ]]; then rm -f "$MATUGEN_STATE"; fi
    return 0
  fi

  if [[ $MT_RESOLVED -eq 0 ]]; then resolve_targets "$MT_CHOICE"; fi
  filter_targets

  if [[ $DRY_RUN -eq 1 ]]; then
    local tmp
    tmp=$(mktemp)
    if [[ ${#MT_SEL[@]} -ne ${#MATUGEN_TARGETS[@]} ]]; then
      build_matugen_config "$(matugen_src)" "$tmp" ${MT_SEL[@]+"${MT_SEL[@]}"}
    fi
    rm -f "$tmp"
    info "Would write Matugen section with ${#MT_SEL[@]} target(s)"
    printf '  %s\n' "${MT_SEL[*]:-none}"
    if [[ $WP_RESOLVED -eq 0 ]]; then resolve_wallpaper; fi
    if [[ $THEME_ACTION == none ]]; then
      echo "  no colours applied"
    elif [[ -n $WALLPAPER ]]; then
      echo "  action: $THEME_ACTION · wallpaper: $WALLPAPER"
    fi
    return 0
  fi

  persist_selection

  if [[ $THEME_ACTION == none ]]; then
    info "Matugen selection saved (no colours applied)"
    return 0
  fi

  if [[ $WP_RESOLVED -eq 0 ]]; then resolve_wallpaper; fi
  if [[ -z $WALLPAPER ]]; then info "Matugen: no wallpaper selected"; return 0; fi

  info "Applying Matugen theme"
  if [[ $THEME_ACTION == colors-only ]]; then
    run_colors_only
    return 0
  fi

  if ! command -v awww >/dev/null 2>&1; then
    warn "awww is not installed; generating colours only"
    run_colors_only
    return 0
  fi
  if [[ ! -x $BIN_DIR/set-theme ]]; then
    warn "set-theme is not linked; run 'setup.sh config' first"
    run_colors_only
    return 0
  fi

  "$BIN_DIR/set-theme" "$WALLPAPER"
}

# ─── wizard ───────────────────────────────────────────────────────────────────
wizard_shell() {
  SHELL_CHOICE=$(choose_one "Which shell do you want?" zsh zsh bash fish none) || die "cancelled"
  if [[ $SHELL_CHOICE != none ]]; then
    if ask_yes "Set $SHELL_CHOICE as your default shell?" y; then
      SET_DEFAULT=yes
    else
      SET_DEFAULT=no
    fi
  fi
}

wizard_configs() {
  choose_many "Configs to link" all CFG_SEL "${CONFIG_ITEMS[@]}" || die "cancelled"
  CFG_RESOLVED=1
  if ! is_selected hypr "${CFG_SEL[@]}"; then
    warn "hypr config not selected: keybinds/autostart/colors.lua will be missing"
  fi
  if ask_yes "Back up current configs before linking?" y; then
    DO_BACKUP=yes
  else
    DO_BACKUP=no
  fi
}

print_summary() {
  info "Summary"
  printf '  shell     : %s (default: %s)\n' "$SHELL_CHOICE" "$SET_DEFAULT"
  printf '  packages  : %d pacman + %d AUR\n' "${#PAC_SEL[@]}" "${#AUR_SEL[@]}"
  if [[ ${#PAC_SEL[@]} -gt 0 ]]; then printf '              %s\n' "${PAC_SEL[*]}"; fi
  if [[ ${#AUR_SEL[@]} -gt 0 ]]; then printf '              AUR: %s\n' "${AUR_SEL[*]}"; fi
  printf '  configs   : %d selected\n' "${#CFG_SEL[@]}"
  if [[ ${#CFG_SEL[@]} -gt 0 ]]; then printf '              %s\n' "${CFG_SEL[*]}"; fi
  printf '  backup    : %s\n' "$DO_BACKUP"
  if [[ $MATUGEN_CHOICE == no ]]; then
    printf '  matugen   : disabled\n'
  else
    printf '  matugen   : %s\n' "$MATUGEN_CHOICE"
    printf '    targets : %s\n' "${MT_SEL[*]:-none}"
    printf '    action  : %s\n' "$THEME_ACTION"
    if [[ -n ${WALLPAPER:-} ]]; then
      printf '    wallpaper: %s\n' "$WALLPAPER"
    fi
  fi
}

wizard() {
  INTERACTIVE=1
  info "My-config setup"

  wizard_shell
  wizard_packages
  wizard_configs
  wizard_matugen

  print_summary

  if [[ $ASSUME_YES -eq 0 ]]; then
    if ! ask_yes "Proceed?" y; then
      echo "cancelled"
      exit 0
    fi
  fi

  install_packages
  change_shell
  install_configs
  matugen_step
}

# ─── main ─────────────────────────────────────────────────────────────────────
main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --shell=*)           SHELL_CHOICE=${1#*=} ;;
      --set-default)       SET_DEFAULT=yes ;;
      --no-set-default)    SET_DEFAULT=no ;;
      --packages=*)        PKG_CHOICE=${1#*=} ;;
      --configs=*)         CFG_CHOICE=${1#*=} ;;
      --backup)            DO_BACKUP=yes ;;
      --no-backup)         DO_BACKUP=no ;;
      --matugen=*)
        MATUGEN_CHOICE=${1#*=}
        case $MATUGEN_CHOICE in
          yes|no|install|ask) ;;
          *) die "invalid --matugen value: $MATUGEN_CHOICE" ;;
        esac
        ;;
      --matugen-targets=*) MT_CHOICE=${1#*=} ;;
      --wallpaper=*)       WP_CHOICE=${1#*=} ;;
      --theme-action=*)    THEME_ACTION=${1#*=} ;;
      --regenerate)        REGENERATE=1; THEME_ACTION=colors-only; WP_CHOICE=current ;;
      --dry-run)           DRY_RUN=1 ;;
      -y|--yes)            ASSUME_YES=1 ;;
      -h|--help)           usage; exit 0 ;;
      packages|shell|config|backup|matugen|all) CMD=$1 ;;
      *) die "unknown argument: $1 (try --help)" ;;
    esac
    shift
  done

  case $THEME_ACTION in
    theme|colors-only|none) ;;
    *) die "invalid --theme-action value: $THEME_ACTION" ;;
  esac

  if [[ -z $CMD ]]; then
    if [[ ! -t 0 ]]; then die "no TTY: use a subcommand (see --help)"; fi
    require_user
    wizard
    return 0
  fi

  if [[ $CMD != packages ]]; then require_user; fi

  case $CMD in
    packages) install_packages ;;
    shell)    change_shell ;;
    config)   install_configs ;;
    backup)   backup_configs ;;
    matugen)  matugen_step ;;
    all)
      change_shell
      install_configs
      matugen_step
      ;;
  esac
}

main "$@"