# https://github.com/tlvince/shell-config/blob/9498a951e5ed612f106b4ae53c579fe2c9ce2a8c/.shell/functions
 
# Create the directories as named operands and enter the first.
mkc() {
  mkdir -p "$@" && cd "$1"
}
 
# Spellchecker using aspell.
spell() {
  echo "$@" | aspell -a | grep -Ev "^@|^$"
}
 
# Navigate $1 directories up.
up() {
  local num=${1:-1}
  cd "$(printf "../"%.0s {1..$num})"
}

# Play a SomaFM stream.
somafm() {
  1=${1:-"groovesalad"}
  mpv --playlist="https://somafm.com/$1.pls"
}
 
passGenerate() {
  [ $1 ] || { echo "$0 <name> [length]"; return; }
  2=${2:-100}
  pass generate --clip "$@"
}
 
passCopyTail() {
  pass "$1" | tail -n1 | wl-copy
}
 
aws-env() {
  profile="${1:-default}"
  region="$(aws configure get region --profile $profile)"
  export AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id --profile $profile)"
  export AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key --profile $profile)"
  export AWS_REGION="$region"
  export AWS_DEFAULT_REGION="$region" 
  echo "$profile environment variables exported"
}
 
cht() {
  curl --silent "https://cht.sh/$1" | "$PAGER"
}

curl-headers() {
  curl --dump-header - --output /dev/null --silent --show-error "$@" | "$PAGER"
}

yq-pretty() {
  yq --colors --output-format yaml --prettyPrint "$@" | "$PAGER"
}

# tmux dev layout
# https://github.com/basecamp/omarchy/blob/11e549a8baa8dbcd5bdd4c70a14161a44e2d5602/default/bash/fns/tmux#L3
tdl() {
  tmux rename-window "${PWD:t}"
  tmux split-window -vd -p 15 -c "$PWD"
  local ai_pane=$(tmux split-window -hdP -p 30 -c "$PWD" -F '#{pane_id}')
  tmux send-keys -t "$ai_pane" "${1:-opencode}" C-m
  tmux send-keys "${EDITOR:-nvim} ." C-m
}
