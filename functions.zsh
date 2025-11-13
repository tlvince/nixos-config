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
