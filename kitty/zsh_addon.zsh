# kitty integration

if [ "$TERM" = "xterm-kitty" ]; then
	alias ssh='kitty +kitten ssh'
fi

darwinSpecific() {
	link_kitty_launch_cmdline() {
		base="$HOME/.config/kitty"
		link="$HOME/.config/kitty/macos-launch-services-cmdline"
		case $1 in
			dark)
				want="$base/macos-launch-services-cmdline-dark.conf"
				file="$base/basic-dark.conf"
				;;
			light)
				want="$base/macos-launch-services-cmdline-light.conf"
				file="$base/basic-light.conf"
				;;
			*)
				return
				;;
		esac
		if [ ! "$link" -ef "$want" ]; then
			gln --relative --symbolic --force --verbose "$want" "$(basename "$link")"
			kitty @ set-colors --configured --all "$file"
		fi
	}
	if [ "Dark" = "$(defaults read -g AppleInterfaceStyle 2> /dev/null)" ]; then
		link_kitty_launch_cmdline "dark"
	else
		link_kitty_launch_cmdline "light"
	fi
	unset -f darwinSpecific link_kitty_launch_cmdline
}

check_kitty_appearance() {
	# 先手动运行 之后想办法加入到kitty的事件系统中
	case $(uname) in
	Darwin*) darwinSpecific ;;
	esac
}
