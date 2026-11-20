# Powerlevel10k configuration for My-config.
#
# This is a hand-maintained minimal config, not a wizard-generated one: it only
# sets the options this prompt actually uses, everything else falls back to
# Powerlevel10k's defaults. Loading it also tells Powerlevel10k that the prompt
# is configured, so the interactive first-run wizard never starts.
#
# `p10k configure` still works; it replaces this file with a full config.
# ~/.zshrc additionally defines POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
# so a missing config file shows the stock prompt instead of the wizard.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options so `source ~/.p10k.zsh` applies changes live.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  ##################################[ prompt layout ]###################################
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    newline                 # \n
    prompt_char             # prompt symbol
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    time                    # current time
  )

  # Transparent background, nerd font icons, no line break before the prompt.
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Trim the past prompt down to a single character.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # Instant prompt without "console output during initialization" warnings.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # Hot reload costs 1-2ms per prompt; `p10k reload` covers config edits.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  ##################################[ prompt_char ]####################################
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#9ece6a'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f7768e'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

  #####################################[ dir ]#########################################
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#7aa2f7'
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7dcfff'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#bb9af7'
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50

  #####################################[ vcs ]#########################################
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#9ece6a'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#e0af68'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#e0af68'
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#f7768e'
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='#565f89'
  # Show exact counts instead of "+".
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  ####################################[ status ]#######################################
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#f7768e'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#f7768e'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND='#f7768e'
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false

  ###########################[ command_execution_time ]################################
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#e0af68'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  ####################################[ time ]########################################
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#7dcfff'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # If p10k is already loaded, reload configuration.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
