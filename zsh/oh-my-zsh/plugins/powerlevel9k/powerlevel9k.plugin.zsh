# set Nerd-Fonts
# see https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#option-4-install-nerd-fonts
POWERLEVEL9K_MODE='nerdfont-complete'

# Termianl colors refers to https://jonasjacek.github.io/colors/

# Prompt settings
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{black}%F{green} \uf155%f%F{black} %k\ue0b0%f "
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Prompt elements
if [[ "${TERM}" =~ "tmux" || "${TERM}" =~ "screen" ]]; then
    # Segment list for left prompt
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( root_indicator dir_writable dir vcs )
    # Segment list for right prompt
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=( command_execution_time status )
else
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( ssh root_indicator user dir_writable dir vcs )
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=( status command_execution_time background_jobs history time )
fi
POWERLEVEL9K_RAM_ELEMENTS="Both"

# Separators https://github.com/ryanoasis/nerd-fonts/blob/master/readme_cn.md#powerline-extra-symbols
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\ue0b0'
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\ue0b1'
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\ue0b2'
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\ue0b3'

# Context
DEFAULT_USER=$USER
POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=false
POWERLEVEL9K_ALWAYS_SHOW_USER=false
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='green'
POWERLEVEL9K_CONTEXT_TEMPLATE="%F{148}%n%F{145}@%M%f"
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='black'
POWERLEVEL9K_CONTEXT_HOST_DEPTH=4

# Dirs
POWERLEVEL9K_DIR_HOME_BACKGROUND='green'
POWERLEVEL9K_DIR_HOME_FOREGROUND='black'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='green'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='black'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='yellow'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='black'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

# OS segment
POWERLEVEL9K_OS_ICON_BACKGROUND='black'
POWERLEVEL9K_LINUX_ICON=$'\uf31c'

# VCS icons
POWERLEVEL9K_VCS_GIT_ICON=$'\uf402'
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=$'\uf408'
POWERLEVEL9K_VCS_STAGED_ICON=$'\uf055'
POWERLEVEL9K_VCS_UNSTAGED_ICON=$'\uf421'
POWERLEVEL9K_VCS_UNTRACKED_ICON=$'\uf00d'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$'\uf0ab '
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$'\uf0aa '

# VCS colours
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='208'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='black'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='yellow'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='black'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='green'

# VCS CONFIG
POWERLEVEL9K_SHOW_CHANGESET=false

# Status
POWERLEVEL9K_OK_ICON=$'\uf00c'
POWERLEVEL9K_FAIL_ICON=$'\uf00d'
POWERLEVEL9K_CARRIAGE_RETURN_ICON=$'\uf810'
POWERLEVEL9K_STATUS_VERBOSE=true
POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE=true

# Battery
POWERLEVEL9K_BATTERY_LOW_FOREGROUND='red'
POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND='yellow'
POWERLEVEL9K_BATTERY_CHARGED_FOREGROUND='green'
POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND='blue'

# Command execution time
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="25"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="145"

# Time
POWERLEVEL9K_TIME_FORMAT="%F{black}\uf017 %D{%H:%M}%f"
POWERLEVEL9K_TIME_BACKGROUND='green'

# Disk usage
POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=true

# Ram
POWERLEVEL9K_RAM_ELEMENTS="Both"
