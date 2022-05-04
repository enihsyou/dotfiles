# configuration setup file for brew installed programs.
# TODO move to brew/alias.zsh
color_profile=''
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
	color_profile='light'
elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
	color_profile='light'
elif [[ "$ITERM_PROFILE" == "Default" ]]; then
	color_profile='nord'
elif [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]]; then
	color_profile=''
fi

# cheat
# https://github.com/chrisallenlane/cheat#enabling-syntax-highlighting
#export CHEATCOLORS=true

# fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'tree -L 4 {} | head -200'"
if [[ $color_profile == "light" ]]; then
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#4d4d4c,bg:#eeeeee,hl:#d7005f
    --color=fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f
    --color=info:#4271ae,prompt:#8959a8,pointer:#d7005f
    --color=marker:#4271ae,spinner:#4271ae,header:#4271ae'
elif [[ $color_profile == "nord" ]]; then
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=dark
    --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
    --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef'
fi
# Groovy
#export GROOVY_HOME=/usr/local/opt/groovy/libexe

# some cleanup
unset color_profile
