linuxSpecific() {
    echo "TODO: implement $0 in java/exports.sh"
}

darwinSpecific() {
    # Java home of Java 8
    alias java8="env JAVA_HOME=$(/usr/libexec/java_home -v1.8)"
    # Java home of Java 11
    alias java11="env JAVA_HOME=$(/usr/libexec/java_home -v11)"
}

case $(uname) in
    Linux*)  linuxSpecific;;
    Darwin*) darwinSpecific;;
    *) echo "Unsupported OS type" >&2
esac