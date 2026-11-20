# ~/.bashrc — bash counterpart of .zshrc.
#
# No framework: history, aliases and a Tokyo Night prompt (dir + git + exit
# status on line one, prompt symbol on line two) in plain bash. Needs bash
# >= 4.2; git and zoxide/fzf/bash-completion are optional and only used when
# present.

# Interactive shells only.
[[ $- == *i* ]] || return 0

# =============================================================================
# XDG / ENVIRONMENT
# =============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export EDITOR="${EDITOR:-nvim}"

# =============================================================================
# HISTORY
# =============================================================================
HISTFILE="$XDG_DATA_HOME/bash/history"
[[ -d ${HISTFILE%/*} ]] || mkdir -p "${HISTFILE%/*}"
HISTSIZE=8000
HISTFILESIZE=8000
# ignoredups + ignorespace: a command starting with a space stays out of history
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize

# =============================================================================
# COMPLETION
# =============================================================================
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

# =============================================================================
# ALIASES
# =============================================================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias ..='cd ..'
alias ...='cd ../..'
# Git
alias gs='git status'
alias gd='git diff'
alias gap='git add -p'
# Nix
alias s='nix search nixpkgs'
alias u='sudo nixos-rebuild switch --flake ~/Projects/My-config/nixos#x280'

# =============================================================================
# TOOLS (each only when installed)
# =============================================================================
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

if command -v fzf >/dev/null 2>&1 && fzf --bash >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# =============================================================================
# PROMPT (Tokyo Night)
# =============================================================================
# Directory and branch names are printed verbatim, so a directory called
# '$(rm -rf ~)' cannot execute anything when the prompt is rendered.
shopt -u promptvars

__tn_git() {
  __tn_git_plain=''
  __tn_git_dirty=0
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) ||
    branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0

  local line xy x y status
  local -i staged=0 modified=0 untracked=0 conflicted=0
  status=$(git status --porcelain 2>/dev/null)

  while IFS= read -r line; do
    [[ -z $line ]] && continue
    xy=${line:0:2}
    case $xy in
      '??')                  ((untracked++));  continue ;;
      DD|AU|UD|UA|DU|AA|UU)  ((conflicted++)); continue ;;
    esac
    x=${xy:0:1}
    y=${xy:1:1}
    [[ $x != ' ' && $x != '?' ]] && ((staged++))
    [[ $y != ' ' ]] && ((modified++))
  done <<< "$status"

  local seg=" ${branch}"
  (( staged ))     && seg+=" ✚${staged}"
  (( modified ))   && seg+=" ✱${modified}"
  (( untracked ))  && seg+=" ?${untracked}"
  (( conflicted )) && seg+=" ✖${conflicted}"
  seg=${seg//\\/\\\\}
  __tn_git_plain="$seg "

  (( staged + modified + untracked + conflicted )) && __tn_git_dirty=1
  return 0
}

__tn_prompt() {
  local -i last=$?

  local blue='\[\e[38;2;122;162;247m\]'
  local green='\[\e[38;2;158;206;106m\]'
  local yellow='\[\e[38;2;224;175;104m\]'
  local red='\[\e[38;2;247;118;142m\]'
  local dim='\[\e[38;2;86;95;137m\]'
  local reset='\[\e[0m\]'

  local dir=${PWD/#$HOME/\~}
  dir=${dir//\\/\\\\}
  local dir_col="${blue} ${dir}${reset}"

  __tn_git
  local git_pl=${__tn_git_plain}
  local git_col=''
  if [[ -n $git_pl ]]; then
    if (( __tn_git_dirty )); then
      git_col="${yellow}${git_pl}${reset}"
    else
      git_col="${green}${git_pl}${reset}"
    fi
  fi

  local status_pl='' status_col=''
  if (( last )); then
    status_pl=" ✘ ${last} "
    status_col="${red}${status_pl}${reset}"
  fi

  local time_pl
  printf -v time_pl '%(%H:%M)T' -1

  local -i gap=$(( ${COLUMNS:-80} - ${#dir} - 1 - ${#git_pl} - ${#status_pl} - ${#time_pl} - 1 ))
  (( gap < 1 )) && gap=1
  local pad
  printf -v pad '%*s' "$gap" ''

  local sym='❯' sym_col=$green
  if (( EUID == 0 )); then
    sym='#'
    sym_col=$red
  fi

  PS1="${dir_col}${git_col}${status_col}${pad}${dim}${time_pl}${reset}"$'\n'"${sym_col} ${sym} ${reset}"
  PS2="${dim}  ${sym} ${reset}"
}

PS1='\w\$ '
PROMPT_COMMAND='__tn_prompt; history -a'
