#!/usr/bin/env bash
set -euxo pipefail

nix flake update nixpkgs-upstream
nixpkgs_rev="$(jq -er '.nodes."nixpkgs-upstream".locked.rev' flake.lock)"

picks=(
  # TODO: Drop nodejs pick when PR is merged upstream
  # Issue URL: https://github.com/tlvince/nixos-config/issues/534
  # See: https://github.com/NixOS/nixpkgs/pull/570428
  # labels: host:nea, module:minuspod
  https://github.com/NixOS/nixpkgs/commit/9907adc0d10cd2636b9dbe9e96bea31689764469
  # TODO: Drop fastflowlm pick when PR is merged upstream
  # Issue URL: https://github.com/tlvince/nixos-config/issues/468
  # See: https://github.com/NixOS/nixpkgs/pull/513841
  # labels: host:framework
  #https://github.com/JohnMolotov/nixpkgs/commit/db67e0576aa590228a55deacae8abdb9254f4580
  # TODO: Drop dsh pick when PR is merged upstream
  # Issue URL: https://github.com/tlvince/nixos-config/issues/512
  # See: https://github.com/NixOS/nixpkgs/pull/554081
  # labels: host:nea, module:dsh
  https://github.com/tlvince/nixpkgs/commit/bb92a908f642b89de7f190aa0183a15510331aac
  # TODO: Drop minuspod pick when PR is merged upstream
  # Issue URL: https://github.com/tlvince/nixos-config/issues/535
  # See: https://github.com/NixOS/nixpkgs/pull/568344
  # labels: host:nea, module:minuspod
  https://github.com/NixOS/nixpkgs/pull/568344
  # TODO: Drop soloist pick when PR is merged upstream
  # Issue URL: https://github.com/tlvince/nixos-config/issues/533
  # See: https://github.com/NixOS/nixpkgs/pull/565860
  # labels: host:cm3588
  https://github.com/NixOS/nixpkgs/pull/565860
)

if ((${#picks[@]})); then
  pipx run --spec ghcherry==1.6.0 ghcherry -- \
    --target tlvince/nixpkgs@nixos-config \
    --first-hard-reset-to "NixOS/nixpkgs/${nixpkgs_rev}" \
    "${picks[@]}"
else
  gh api \
    --method PATCH \
    repos/tlvince/nixpkgs/git/refs/heads/nixos-config \
    -f sha="$nixpkgs_rev" \
    -F force=true \
    >/dev/null
fi

nix flake update nixpkgs
