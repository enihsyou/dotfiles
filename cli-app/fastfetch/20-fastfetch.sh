#!/usr/bin/env bash
# shellcheck disable=SC2086
# Run 'whatever-fetch' on SSH session login

# This file is intended to be placed in /etc/update-motd.d/ and
# executed by pam_motd.so upon login (Debian). It may also be placed in /etc/profile.d/
# to run when profile files are loaded; the two differ in execution timing.

# read username from 'sshd-session' process
# https://superuser.com/questions/981897/trying-to-print-username-at-message-of-the-day-motd/1178598#1178598
p1=$(ps --no-headers -o ppid $PPID)
p2=$(ps --no-headers -o ppid $p1)
us=$(ps --no-headers -o command $p2 | awk '{ print $2 }' | sed "s/[[:digit:].-]//g")

# Separate the following output from the above for nicer appearance
printf "\n"

# fastfetch reads the username from the USER environment variable,
# so we override it to change the username displayed in the title format.
# https://github.com/fastfetch-cli/fastfetch/blob/805e2774293d27f0f5b803ff2b35f3332e2a1bb6/src/util/platform/FFPlatform_unix.c#L177
#
# '--pipe false' is required to enable colored output
USER="$us" fastfetch --pipe false
