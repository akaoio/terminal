# Minimal Clean Powerlevel10k Configuration
# Two-line prompt with cyberpunk colors, no backgrounds, ASCII only

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Color palette - Cyberpunk style
  local CYAN=51
  local BLUE=39  
  local GREEN=46
  local YELLOW=226
  local ORANGE=208
  local RED=196
  local GRAY=244
  local WHITE=255

  # Left prompt - Two lines: user@host dir (git) \n >
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # user@hostname
    dir                     # current directory
    vcs                     # git status
    newline                 # \n
    prompt_char            # > or triangle
  )

  # Right prompt - minimal
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    command_execution_time  # execution time
    status                  # exit code
  )

  # Clean style - no backgrounds
  typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=' '
  
  # Two-line prompt
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''

  # Context (user@host) - cyan/blue cyberpunk
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$CYAN
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$RED
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'

  # Directory - green
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$GREEN
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$GRAY
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$GREEN
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=50

  # VCS (Git) - colored by status
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$GREEN
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$YELLOW
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$ORANGE
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$GRAY
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  
  # Git format - simple with ASCII
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=''
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=''
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='*'  
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='<'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='>'
  typeset -g POWERLEVEL9K_VCS_STASH_ICON='#'
  typeset -g POWERLEVEL9K_VCS_TAG_ICON='@'

  # Prompt character - triangle ASCII
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$CYAN
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$RED
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='▸'     # Small triangle
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT_EXPANSION='◂'     # Triangle left
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='▸'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT_EXPANSION='◂'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # Command execution time - yellow, no icon
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$YELLOW
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=''

  # Status - only show on error
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$RED
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='[!]'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false

  # Performance
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.05

  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'