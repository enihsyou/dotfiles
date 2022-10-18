# kitty

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
	esac
	if [ ! "$link" -ef "$want" ]; then
		(cd "$base" && gln --symbolic --force --verbose "$want" "$link")
		kitty @ set-colors --configured --all "$file"
	fi
}

if is_system_appearence_dark; then
	link_kitty_launch_cmdline "dark"
else
	link_kitty_launch_cmdline "light"
fi

unset -f link_kitty_launch_cmdline
