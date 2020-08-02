#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154

include_zlib=(
  /usr/local/opt/zlib/lib
  /usr/local/opt/zlib/include
)

include_sqlite=(
  /usr/local/opt/sqlite/lib
  /usr/local/opt/sqlite/include
)

includes=(
  include_zlib
  include_sqlite
)


# The bash way
function build_array_bash() {
  index=$1
  local output=()

  # https://stackoverflow.com/a/17841619/5277711
  function join_by { local IFS="$1"; shift; echo "$*"; }

  for path in ${!include_@} ; do
    ref=$segment;
    ref_array="${ref}[${index}]"
    output+=("${!ref_array}")
  done

  echo "$(join_by : "${output[@]}")"
}

# The zsh way
function build_array_zsh() {
  index=$(( $1 + 1 ))
  heading=$2
  local output=()

  for segment in "${includes[@]}" ; do
    output+=("${heading}""${${(P)segment}[index]}")
  done

  sep=" "
#  echo "${(pj:$sep:)output}"
}

# LDFLAGS="$(build_array_zsh 0 -L)"
# CPPFLAGS="$(build_array_zsh 1 -I)"
#echo $LDFLAGS
#echo $CPPFLAGS
#export LDFLAGS
#export CPPFLAGS
