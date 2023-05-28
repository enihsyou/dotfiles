# antidote lazy load zsh plugin
# This plugin loads antidote into the current shell

function antidote() {
  echo "🚨 antidote not loaded! Loading now..."
  unset -f antidote
  source /usr/local/opt/antidote/share/antidote/antidote.zsh
}
