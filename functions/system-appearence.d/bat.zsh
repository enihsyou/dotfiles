# bat & delta

link_bat_launch_cmdline() {
	base="$HOME/.config/bat"
	link="$HOME/.config/bat/config"
	case $1 in
		dark)
			want="$base/config-dark"
			;;
		light)
			want="$base/config-light"
			;;
	esac
	if [ ! "$link" -ef "$want" ]; then
		(cd "$base" && gln --symbolic --force --verbose "$want" "$(basename "$link")")
	fi
}

if is_system_appearence_dark; then
	link_bat_launch_cmdline "dark"
else
	link_bat_launch_cmdline "light"
fi

unset -f link_bat_launch_cmdline
