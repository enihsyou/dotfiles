# kitty integration

if [ "$TERM" = "xterm-kitty" ]; then
	alias ssh='kitty +kitten ssh'
fi

# 先手动运行 之后想办法加入到kitty的事件系统中
check_kitty_appearance() {
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
			(cd "$base" && gln --symbolic --force --verbose "$want" "$(basename "$link")")
			kitty @ set-colors --configured --all "$file"
		fi
	}

	case $OSTYPE in
		darwin*)
			if is_system_appearence_dark; then
				link_kitty_launch_cmdline "dark"
			else
				link_kitty_launch_cmdline "light"
			fi
			;;
	esac
	unset -f link_kitty_launch_cmdline
}
