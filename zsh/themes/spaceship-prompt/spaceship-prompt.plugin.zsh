# https://denysdovhan.com/spaceship-prompt/docs/Options.html
# shellcheck disable=SC2034

# manually set root folder, fix later.
#SPACESHIP_ROOT=/Users/enihsyou/GitHub/spaceship-prompt

SPACESHIP_PROMPT_ORDER=(
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  # hg            # Mercurial section (hg_branch  + hg_status)
  # package       # Package version
  # gradle        # Gradle section
  # maven         # Maven section
  # node          # Node.js section
  # ruby          # Ruby section
  # elixir        # Elixir section
  # xcode         # Xcode section
  # swift         # Swift section
  golang        # Go section
  # php           # PHP section
  # rust          # Rust section
  # haskell       # Haskell Stack section
  # julia         # Julia section
  # docker        # Docker section
  # aws           # Amazon Web Services section
  # gcloud        # Google Cloud Platform section
  venv          # virtualenv section
  # conda         # conda virtualenv section
  # pyenv         # Pyenv section
  # dotnet        # .NET section
  # ember         # Ember.js section
  # kubectl       # Kubectl context section
  # terraform     # Terraform workspace section
  # ibmcloud      # IBM Cloud section
  # battery       # Battery level and status
  # vi_mode       # Vi-mode indicator
  # proxy         # My proxy plugin
  # exec_time     # Execution time
  exec_time_ms  # Execution time in millisecond
  exit_code     # Exit code section
  line_sep      # Line break
  char          # Prompt character
)

SPACESHIP_RPROMPT_ORDER=(
  jobs          # Background jobs indicator
)

# Prompt
SPACESHIP_PROMPT_ADD_NEWLINE=false

# Char
# SPACESHIP_CHAR_SYMBOL='\uf155' # nf-fa-dollar
#SPACESHIP_CHAR_SUFFIX=''
# SPACESHIP_CHAR_SYMBOL_ROOT='\uf292 ' # nf-fa-hashtag
SPACESHIP_CHAR_SYMBOL_ROOT='#' # nf-fa-hashtag

# Time
SPACESHIP_TIME_SHOW=true
#SPACESHIP_TIME_PREFIX=''

# User
SPACESHIP_USER_SHOW=needed

# Dir
SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_LOCK_SYMBOL='\uf023'

# Git
SPACESHIP_GIT_SYMBOL='\uf09b '
SPACESHIP_GIT_STATUS_SHOW=false

# Git branch
SPACESHIP_GIT_BRANCH_PREFIX='\ue725 '

# Docker
SPACESHIP_DOCKER_VERBOSE=true

# Execution time
SPACESHIP_EXEC_TIME_ELAPSED=1
SPACESHIP_EXEC_TIME_MS_ELAPSED=1
SPACESHIP_EXEC_TIME_SHOW=false
SPACESHIP_EXEC_TIME_MS_SHOW=true

# Jobs
SPACESHIP_JOBS_AMOUNT_PREFIX=' '

# Exit code
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_EXIT_CODE_SYMBOL='\uf00d '


