# shellcheck disable=SC2139

linuxSpecific() {
	echo "TODO: implement $0 in java/exports.sh"
}

darwinSpecific() {
	# Java home of Java 8
	alias java8="env JAVA_HOME=$(/usr/libexec/java_home -v1.8)"
	# Java home of Java 11
	alias java11="env JAVA_HOME=$(/usr/libexec/java_home -v11)"

	# this export is for GraalVM components,
	# until GraalVM will be provided by HomeBrew.
	# export PATH="$PATH:$(/usr/libexec/java_home -v11)/bin"
	# export LLVM_TOOLCHAIN=$(lli --print-toolchain-path)
}

case $(uname) in
	Linux*) linuxSpecific ;;
	Darwin*) darwinSpecific ;;
	*) echo "Unsupported OS type" >&2 ;;
esac
