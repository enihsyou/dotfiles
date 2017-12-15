# Based on evan's prompt
# Shows the exit status of the last command if non-zero
# Uses "#" instead of "»" when running with elevated privileges
local return_code=" %(?.%{$fg_bold[green]%}%T.%{$fg[red]%}%? ↵ %{$fg_bold[green]%}%T%{$reset_color%})"

if [[ $UID -eq 0 ]]; then
        local user_host='%{$terminfo[bold]$fg[red]%}%n%{$fg_bold[white]%}@%{${fg_bold[cyan]}%}%m'
            local user_symbol='#'
            else
                    local user_host='%{$terminfo[bold]$fg[green]%}%n%{$fg_bold[white]%}@%{${fg_bold[blue]}%}%m'
                        local user_symbol='$'
                        fi


#PROMPT="%m %{${fg_bold[red]}%}:: %{${fg[green]}%}%3~%(0?. . %{${fg[red]}%}%? )%{${fg[blue]}%}»%{${reset_color}%} "
PROMPT="╭─${user_host} %{${fg_bold[red]}%}::%{$reset_color%} %{$terminfo[bold]$FG[226]%}%3~%{${reset_color}%}
╰─%{${fg[blue]}%}%B${user_symbol}%b %{${reset_color}%}"
RPS1="%B${return_code}%b"

