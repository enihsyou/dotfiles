# vim

link_vim_launch_cmdline() {
	base="$HOME/.vim/colors"
	link="$HOME/.vim/colors/system-appearance.vim"
	case $1 in
		dark)
			want="$HOME/.vim_runtime/sources_forked/peaksea/colors/peaksea.vim"
			;;
		light)
			want="$HOME/.vim_runtime/sources_forked/onehalf/colors/onehalflight.vim"
			;;
	esac
	if [ ! "$link" -ef "$want" ]; then
		(cd "$base" && gln --symbolic --force --verbose "$want" "$link")
	fi
}

if is_system_appearence_dark; then
	link_vim_launch_cmdline "dark"
else
	link_vim_launch_cmdline "light"
fi

unset -f link_vim_launch_cmdline
