#!/usr/bin/env bash
set -euxo pipefail

nix flake update nixpkgs-upstream
nixpkgs_rev="$(jq -er '.nodes."nixpkgs-upstream".locked.rev' flake.lock)"

source "${BASH_SOURCE[0]%/*}/nixpkgs-patches.sh"

if (( ${#patches[@]} == 0 )); then
  echo "No picks left; retire the fork instead (see update-flake.yml)" >&2
  exit 1
fi

pipx run --spec ghcherry==1.6.0 ghcherry -- \
  --target tlvince/nixpkgs@nixos-config \
  --first-hard-reset-to "NixOS/nixpkgs/${nixpkgs_rev}" \
  "${patches[@]}"

nix flake update nixpkgs
