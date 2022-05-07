# delta

link_delta_launch_cmdline() {
	base="$HOME/.config/delta"
	link="$HOME/.config/delta/gitconfig.color"
	case $1 in
		dark)
			want="$base/color-dark.gitconfig"
			;;
		light)
			want="$base/color-light.gitconfig"
			;;
	esac
	if [ ! "$link" -ef "$want" ]; then
		(cd "$base" && gln --symbolic --force --verbose "$want" "$(basename "$link")")
	fi
}

if is_system_appearence_dark; then
	link_delta_launch_cmdline "dark"
else
	link_delta_launch_cmdline "light"
fi

unset -f link_delta_launch_cmdline

