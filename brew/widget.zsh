# configuration setup file for brew installed programs.

# bat
if [[ "$ITERM_PROFILE" == "Default" ]]; then
	export BAT_THEME="GitHub"
else
	export BAT_THEME="OneHalfDark"
fi
export BAT_PAGER="less -SR"

# cheat
# https://github.com/chrisallenlane/cheat#enabling-syntax-highlighting
#export CHEATCOLORS=true

# fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'tree -L 4 {} | head -200'"

# Groovy
#export GROOVY_HOME=/usr/local/opt/groovy/libexe
