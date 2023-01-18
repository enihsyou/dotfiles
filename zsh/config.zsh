# ZSH config
# References http://zsh.sourceforge.net/Doc/Release/Options.html

setopt PROMPT_SUBST
#setopt IGNORE_EOF
# Scripts and Functions https://github.com/Neal/dotfiles/blob/master/zsh/setopt.zsh
setopt MULTIOS            # perform implicit tees or cats when multiple redirections are attempted
# preceding option would interferences with antibody - spaceship-prompt.
# if that happens, comment out LOCAL_OPTIONS
setopt LOCAL_OPTIONS      # allow functions to have local options
setopt LOCAL_TRAPS        # allow functions to have local traps

# Jobs https://github.com/mattjj/my-oh-my-zsh/blob/master/environment.zsh
setopt LONG_LIST_JOBS     # List jobs in the long format by default.
setopt AUTO_RESUME        # Attempt to resume existing job before creating a new process.
setopt NOTIFY             # Report status of background jobs immediately.
setopt NO_BG_NICE         # Don't run all background jobs at a lower priority.
setopt NO_HUP             # Don't kill jobs on shell exit.
# unsetopt CHECK_JOBS       # Don't report on jobs when shell exit.

# History https://github.com/mattjj/my-oh-my-zsh/blob/master/history.zsh
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY            # Allow multiple terminal sessions to all append to one zsh command history
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# Completion https://github.com/Neal/dotfiles/blob/master/zsh/setopt.zsh
setopt ALWAYS_TO_END             # When completing from the middle of a word, move the cursor to the end of the word
setopt AUTO_MENU                 # show completion menu on successive tab press. needs unsetop menu_complete to work
setopt AUTO_NAME_DIRS            # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt COMPLETE_IN_WORD          # if unset the cursor is set to the end of the word if completion is started

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

# https://stackoverflow.com/a/73241402
# https://github.com/kovidgoyal/kitty/issues/838#issuecomment-770328902
bindkey "\e[1;3D" backward-word     # ⌥←
bindkey "\e[1;3C" forward-word      # ⌥→
