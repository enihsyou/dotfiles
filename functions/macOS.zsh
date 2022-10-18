# functions load on macOS
case $OSTYPE in
	darwin*) ;;
	*) return ;;
esac

# tell whether is macOS Dark mode is on.
function is_system_appearence_dark() {
	if [ "Dark" = "$(defaults read -g AppleInterfaceStyle 2> /dev/null)" ]; then
		return 0
	else
		return 1
	fi
}

function refresh_system_appearence() {
	for funcfile in "$DOTFILES"/functions/system-appearence.d/*.zsh; do
		source "$funcfile"
	done
}
