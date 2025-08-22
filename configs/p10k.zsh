# AKAOIO Terminal - Dynamic Theme Support
# Format: user@host ~/dir (git) > 

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Get current theme (default to dracula)
  local current_theme="${TERMINAL_THEME:-dracula}"
  
  # Disable icons for universal compatibility
  typeset -g POWERLEVEL9K_MODE='compatible'
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
  
  # Two-line prompt for better readability on small screens
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # First line: path and git info
    context                 # user@hostname
    dir                     # current directory  
    vcs                     # git status
    newline                 # line break
    prompt_char            # > on second line
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Two-line settings - no backgrounds anywhere
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_BACKGROUND=                 # global no background
  
  # Dynamic theme colors based on $TERMINAL_THEME
  case "$current_theme" in
    dracula)
      # Dracula colors - no backgrounds, text only
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#BD93F9'  # purple text
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#8BE9FD'      # cyan text
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#50FA7B'     # green text
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#F1FA8C'  # yellow text
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FFB86C' # orange text
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF79C6'    # pink
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF5555'  # red
      ;;
      
    cyberpunk)
      # Cyberpunk neon colors
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#FF00FF'  # bright magenta
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#00FFFF'      # bright cyan
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#00FF00'     # bright green
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#FFFF00'  # bright yellow
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FF6600' # bright orange
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF00FF'    # bright magenta
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF0000'  # bright red
      ;;
      
    nord)
      # Nord cool colors
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#81A1C1'  # nord9 blue
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#88C0D0'      # nord8 cyan
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#A3BE8C'     # nord14 green
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#EBCB8B'  # nord13 yellow
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#D08770' # nord12 orange
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#B48EAD'    # nord15 purple
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#BF616A'  # nord11 red
      ;;
      
    gruvbox)
      # Gruvbox warm colors
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#D3869B'  # purple
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#83A598'      # cyan/aqua
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#B8BB26'     # green
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#FABD2F'  # yellow
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FE8019' # orange
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FB4934'    # bright red
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#CC241D'  # red
      ;;
      
    *)
      # Default fallback to dracula
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#BD93F9'  # purple text
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#8BE9FD'      # cyan text
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#50FA7B'     # green text
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#F1FA8C'  # yellow text
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FFB86C' # orange text
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF79C6'    # pink
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF5555'  # red
      ;;
  esac
  
  # Common settings for all themes
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=           # no background
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=               # no background
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30
  
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=              # no background
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=           # no background
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=          # no background
  
  # Disable folder icons
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=false
  typeset -g POWERLEVEL9K_HOME_ICON=
  typeset -g POWERLEVEL9K_HOME_SUB_ICON=
  typeset -g POWERLEVEL9K_FOLDER_ICON=
  typeset -g POWERLEVEL9K_ETC_ICON=
  
  # ASCII git symbols
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=
  typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  
  # ASCII prompt character - no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=            # no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='>'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='>'
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