#!/usr/bin/env zsh
# P10K Mobile-First Configuration
# Optimized for Termux and small screens
# No backgrounds, compact, clean

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Mobile-first: Compact single-line prompt
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir_short      # Shortened directory (~/p/terminal instead of ~/Projects/terminal)
    vcs_compact    # Compact git (main* instead of  main ✚1 ⚑2)
    prompt_char    # Simple $ or #
  )
  
  # No right prompt on mobile
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
  
  # Single line, no extra spacing
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
  
  # NO BACKGROUNDS AT ALL - Critical for Termux
  typeset -g POWERLEVEL9K_BACKGROUND=''
  
  # Dir settings - compact
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=''
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=39  # Bright blue
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=39
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  
  # Shorten directory path
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=25
  
  # Custom dir segment for mobile
  typeset -g POWERLEVEL9K_DIR_SHORT_BACKGROUND=''
  typeset -g POWERLEVEL9K_DIR_SHORT_FOREGROUND=39
  typeset -g POWERLEVEL9K_DIR_SHORT_VISUAL_IDENTIFIER_EXPANSION=''
  
  # Git - ultra compact
  typeset -g POWERLEVEL9K_VCS_BACKGROUND=''
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=46      # Green
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=226   # Yellow
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=196  # Red
  
  # Compact git format: "main*" instead of " main ✚1 ⚑2"
  typeset -g POWERLEVEL9K_VCS_COMPACT_BACKGROUND=''
  typeset -g POWERLEVEL9K_VCS_COMPACT_CLEAN_FOREGROUND=46
  typeset -g POWERLEVEL9K_VCS_COMPACT_MODIFIED_FOREGROUND=226
  typeset -g POWERLEVEL9K_VCS_COMPACT_UNTRACKED_FOREGROUND=196
  
  # Hide git icons - use simple indicators
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=''
  typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
  typeset -g POWERLEVEL9K_VCS_GIT_GITLAB_ICON=''
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=''
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='*'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='↓'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='↑'
  
  # Simplify git format
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=false
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${${${P9K_CONTENT/⌥/}// /}//\%/%%}'
  
  # Prompt character - simple
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=46
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='$'
  
  # Minimal separators - just space
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  
  # Remove all padding and whitespace
  typeset -g POWERLEVEL9K_WHITESPACE_BETWEEN_{LEFT,RIGHT}_SEGMENTS=''
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=''
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=''
  
  # Instant prompt
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  
  # Custom segments implementation
  function prompt_dir_short() {
    local path=${(%):-%~}
    # Shorten path: ~/Projects/terminal → ~/p/terminal
    path=${path/#$HOME/\~}
    if [[ $path == "~" ]]; then
      p10k segment -f 39 -t '~'
    else
      # Split and shorten
      local parts=("${(@s:/:)path}")
      local result=""
      for ((i=1; i<${#parts[@]}; i++)); do
        if [[ ${parts[$i]} == "~" ]]; then
          result="~"
        elif [[ $i -lt $((${#parts[@]}-1)) ]]; then
          result="$result/${parts[$i]:0:1}"
        else
          result="$result/${parts[$i]}"
        fi
      done
      result=${result#/}
      p10k segment -f 39 -t "$result"
    fi
  }
  
  function prompt_vcs_compact() {
    local vcs_info=$(git branch --show-current 2>/dev/null)
    if [[ -n $vcs_info ]]; then
      local color=46  # green for clean
      local suffix=""
      
      # Check git status
      if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        color=226  # yellow for modified
        suffix="*"
      fi
      
      p10k segment -f $color -t "${vcs_info}${suffix}"
    fi
  }
  
  # Performance
  typeset -g POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME=true
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=false
  
  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'