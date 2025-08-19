# Powerlevel10k Cyberpunk Theme Configuration
# Created by AKAOIO Terminal

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  
  # Unset all configuration options
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  
  # Zsh >= 5.1 is required
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                            PROMPT CONFIGURATION                                  ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # Left prompt segments
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # OS identifier with custom icon
    dir                     # Current directory
    vcs                     # Git status
    newline                 # Line break
    prompt_char            # Prompt symbol
  )
  
  # Right prompt segments
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # Exit code of last command
    command_execution_time  # Command duration
    background_jobs        # Background jobs indicator
    virtualenv             # Python virtual environment
    anaconda               # Conda environment
    pyenv                  # Python version
    goenv                  # Go version
    nodenv                 # Node.js version
    node_version           # Node.js version
    package                # Package version
    rust_version           # Rust version
    dotnet_version         # .NET version
    kubecontext           # Kubernetes context
    terraform             # Terraform workspace
    aws                   # AWS profile
    azure                 # Azure account
    gcloud                # Google Cloud
    docker_machine        # Docker machine
    time                  # Current time
  )
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                              CYBERPUNK COLORS                                    ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # Color palette - Professional & Neutral
  local ACCENT_BLUE=39      # Professional blue
  local ACCENT_CYAN=51      # Cyan accent
  local ACCENT_GREEN=46     # Success green
  local ACCENT_GRAY=244     # Neutral gray
  local ACCENT_YELLOW=226   # Warning yellow
  local ACCENT_ORANGE=208   # Orange accent
  local ACCENT_RED=196      # Error red
  local DARK_BG=236         # Dark background
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                              GENERAL SETTINGS                                    ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # Icon set
  typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
  
  # Powerline Style Configuration
  typeset -g POWERLEVEL9K_MODE='powerline'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' '
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  
  # Single line prompt (no multiline)
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  
  # Remove multiline prefixes for powerline style
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                            SEGMENT: OS ICON                                      ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=255
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$ACCENT_BLUE
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=' '
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                           SEGMENT: DIRECTORY                                     ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=31
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  
  # Special directories
  typeset -g POWERLEVEL9K_DIR_CLASSES=(
    '/etc/*'                        ETC         '⚙'
    '~'                            HOME        '🏠'
    '~/*'                          HOME_SUBFOLDER '📁'
    '~/Desktop/*'                  DESKTOP     '🖥'
    '~/Documents/*'                DOCUMENTS   '📄'
    '~/Downloads/*'                DOWNLOADS   '⬇'
    '~/Music/*'                    MUSIC       '🎵'
    '~/Pictures/*'                 PICTURES    '🖼'
    '~/Videos/*'                   VIDEOS      '🎬'
    '~/projects/*'                 PROJECTS    '💼'
    '~/code/*'                     CODE        '💻'
    '*'                           DEFAULT     '📁'
  )
  
  # Shorten directory path
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=true
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                            SEGMENT: VCS (GIT)                                    ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=22
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=130
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=208
  
  # Disable VCS for special directories
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~|~/Downloads'
  
  # Git icons
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_GITLAB_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=' '
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='✚'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='●'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
  typeset -g POWERLEVEL9K_VCS_STASH_ICON='⚑'
  typeset -g POWERLEVEL9K_VCS_TAG_ICON=' '
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                          SEGMENT: PROMPT CHAR                                    ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # Prompt character with powerline style
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$ACCENT_GREEN
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIOWR_CONTENT_EXPANSION='▶'
  
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$ACCENT_RED
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIOWR_CONTENT_EXPANSION='▶'
  
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                            SEGMENT: STATUS                                       ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=255
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=22
  
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=255
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=196
  
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                     SEGMENT: COMMAND EXECUTION TIME                              ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=226
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION='⏱'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                        SEGMENT: BACKGROUND JOBS                                  ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=255
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=33
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⚙'
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                         SEGMENT: VIRTUALENV                                      ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$ACCENT_GREEN
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION='🐍'
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                         SEGMENT: NODE VERSION                                    ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$ACCENT_GREEN
  typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_EXPANSION='⬢'
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                           SEGMENT: PACKAGE                                       ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_PACKAGE_FOREGROUND=$ACCENT_BLUE
  typeset -g POWERLEVEL9K_PACKAGE_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_PACKAGE_VISUAL_IDENTIFIER_EXPANSION='📦'
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                            SEGMENT: TIME                                         ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$ACCENT_GRAY
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION='🕐'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                         LANGUAGE VERSIONS                                        ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # Go
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=$ACCENT_CYAN
  typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_GO_VERSION_VISUAL_IDENTIFIER_EXPANSION='🐹'
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true
  
  # Rust
  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=$ACCENT_ORANGE
  typeset -g POWERLEVEL9K_RUST_VERSION_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_RUST_VERSION_VISUAL_IDENTIFIER_EXPANSION='🦀'
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true
  
  # Python
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$ACCENT_YELLOW
  typeset -g POWERLEVEL9K_PYENV_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_PYENV_VISUAL_IDENTIFIER_EXPANSION='🐍'
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                          CLOUD PROVIDERS                                         ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # AWS
  typeset -g POWERLEVEL9K_AWS_FOREGROUND=$ACCENT_ORANGE
  typeset -g POWERLEVEL9K_AWS_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_AWS_VISUAL_IDENTIFIER_EXPANSION='☁'
  
  # Kubernetes
  typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=$ACCENT_BLUE
  typeset -g POWERLEVEL9K_KUBECONTEXT_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_KUBECONTEXT_VISUAL_IDENTIFIER_EXPANSION='☸'
  
  # Docker
  typeset -g POWERLEVEL9K_DOCKER_MACHINE_FOREGROUND=$ACCENT_BLUE
  typeset -g POWERLEVEL9K_DOCKER_MACHINE_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_DOCKER_MACHINE_VISUAL_IDENTIFIER_EXPANSION='🐳'
  
  # Terraform
  typeset -g POWERLEVEL9K_TERRAFORM_FOREGROUND=$ACCENT_CYAN
  typeset -g POWERLEVEL9K_TERRAFORM_BACKGROUND=$DARK_BG
  typeset -g POWERLEVEL9K_TERRAFORM_VISUAL_IDENTIFIER_EXPANSION='💠'
  
  # ╔═══════════════════════════════════════════════════════════════════════════════╗
  # ║                          PERFORMANCE SETTINGS                                    ║
  # ╚═══════════════════════════════════════════════════════════════════════════════╝
  
  # Instant prompt
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  
  # Transient prompt
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  
  # Hot reload
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  
  # Gitstatus
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.05
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  
  # Configuration file
  typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
  
  # Reload if already loaded
  (( ! $+functions[p10k] )) || p10k reload
}

# Restore options
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'