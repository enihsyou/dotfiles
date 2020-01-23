#!/usr/bin/env zsh

N=100000
cmd="ls"

TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

echo "Benchmark $SHELL"
echo
echo "type:"
time (repeat $N {type $cmd &>/dev/null})

echo
echo "hash:"
time (repeat $N {hash $cmd &>/dev/null})

echo
echo "command -v:"
time (repeat $N {command -v $cmd &>/dev/null})

echo
echo "which:"
time (repeat $N {which $cmd &>/dev/null})

echo
echo '$+commands:'
time (repeat $N { (( $+commands[$cmd] )) })
