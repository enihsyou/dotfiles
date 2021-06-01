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
#  package       # Package version
#  node          # Node.js section
#  ruby          # Ruby section
  golang        # Go section
#  docker        # Docker section
  venv          # virtualenv section
#  pyenv         # Pyenv section
#  kubectl       # Kubectl context section
#  proxy         # My proxy plugin
  exec_time     # Execution time
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  line_sep      # Line break
  char          # Prompt character
)

# Prompt
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=true

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

# Jobs
SPACESHIP_JOBS_AMOUNT_PREFIX=' '

# Exit code
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_EXIT_CODE_SYMBOL='\uf00d '


