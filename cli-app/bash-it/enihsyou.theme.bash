# shellcheck shell=bash
# base on essential.theme

function _user-prompt() {
    local -r user='\u'

    if [[ "${EUID}" -eq 0 ]]; then
        # Privileged users:
        local -r user_color="${bold_red?}"
    else
        # Standard users:
        local -r user_color="${bold_green?}"
    fi

    # Print the current user's name (colored according to their current EUID):
    printf '%b%s%b' "${user_color}" "${user}" "${normal?}"
}

function _host-prompt() {
    local -r host='\h'

    # Check whether or not $SSH_TTY is set:
    if [[ -z "${SSH_TTY:-}" ]]; then
        # For local hosts, set the host's prompt color to blue:
        local -r host_color="${bold_blue?}"
    else
        # For remote hosts, set the host's prompt color to red:
        local -r host_color="${bold_red?}"
    fi

    # Print the current hostname (colored according to $SSH_TTY's status):
    printf '%b%s%b' "${host_color}" "${host}" "${normal?}"
}

function _user-at-host-prompt() {
    # Concatenate the user and host prompts into: user@host:
    _user-prompt
    printf '%b@' "${bold_white?}"
    _host-prompt
}

function _dynamic_clock_icon {
	# static clock icon if duration is less than 1 second.
	# because dynamic compute value is garbish then.
	if [[ $1 < 1 ]]; then
		COMMAND_DURATION_ICON="🕛"
		return
	fi
	local clock_hand
	# clock hand value is between 90 and 9b in hexadecimal.
	# so between 144 and 155 in base 10.
	printf -v clock_hand '%x' $((((${1:-${SECONDS}} - 1) % 12) + 144))
	printf -v 'COMMAND_DURATION_ICON' '%b' "\xf0\x9f\x95\x$clock_hand"
}

function _duration-prompt() {
    local duration=$(_command_duration)
    if [[ -n "$duration" ]]; then
        _cursor_right="\[\e[200C"
        _cursor_adjust="\[\e[${#duration}D"
        printf '%b%b%b%s%b' "${_cursor_right}" "${_cursor_adjust}" "${white}" "${duration}" "${normal?}"
    fi
}

function _exit-status-prompt() {
    local -r prompt_string="${1}"
    local -r exit_status="${2}"

    # Check the exit status of the last command captured by $exit_status:
    if [[ "${exit_status}" -eq 0 ]]; then
        # For commands that return an exit status of zero, set the exit status's
        # notifier to green:
        local -r exit_status_color="${bold_green?}"
    else
        # For commands that return a non-zero exit status, set the exit status's
        # notifier to red:
        local -r exit_status_color="${bold_red?}"
    fi

    if [[ "${prompt_string}" -eq 1 ]]; then
        # $PS1:
        printf '%b$%b' "${exit_status_color}" "${normal?} "
    elif [[ "${prompt_string}" -eq 2 ]]; then
        # $PS2:
        printf '%b|%b' "${exit_status_color}" "${normal?} "
    else
        # Default:
        printf '%b?%b' "${exit_status_color}" "${normal?} "
    fi
}

function _ps1() {
    local -r time='\t'
    local -r pwd='\w'

    printf '%b%s ' "${bold_white?}" "${time}"
    _user-at-host-prompt
    printf '%b %b%s' "${bold_white?}" "${normal?}" "${pwd}"
    _duration-prompt
    printf '\n'
    _exit-status-prompt 1 "${exit_status}"
}

function _ps2() {
    _exit-status-prompt 2 "${exit_status}"
}

function prompt_command() {
    # Capture the exit status of the last command:
    local -r exit_status="${?}"

    # Build the $PS1 prompt:
    PS1="$(_ps1)"

    # Build the $PS2 prompt:
    PS2="$(_ps2)"
}

safe_append_prompt_command prompt_command
