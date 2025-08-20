# AKAOIO Terminal - Professional Cyberpunk One-Line Theme
# Format: user@host ~/dir (git) $ 

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Two-line prompt for better readability on small screens
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # First line: path and git info
    context                 # user@hostname
    dir                     # current directory  
    vcs                     # git status
    newline                 # line break
    prompt_char            # ❯ on second line
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Two-line settings - no backgrounds anywhere
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_BACKGROUND=                 # global no background
  
  # Rainbow colors - no backgrounds, text only
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=198     # hot pink text
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=        # no background
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=226         # bright yellow text
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=            # no background
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30
  
  # Git - rainbow colors, no backgrounds
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=46     # bright green text
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=       # no background
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=201 # bright magenta text
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=    # no background
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=51 # bright cyan text
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=   # no background
  
  # Rainbow prompt character - no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=     # no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=51    # cyan
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196  # red  
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  
  # Disable multiline prompt decorations
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  
  # Separators - compact spacing
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=

  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'