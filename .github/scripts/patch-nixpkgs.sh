#!/usr/bin/env bash
set -euxo pipefail

nixpkgs_rev="$(git ls-remote https://github.com/NixOS/nixpkgs refs/heads/nixos-unstable | cut -f1)"
[[ "$nixpkgs_rev" ]] || { echo "failed to resolve nixos-unstable rev" && exit 1; }

picks=(
  # TODO: Drop fastflowlm pick when PR is merged upstream
  # Issue URL: https://github.com/tlvince/nixos-config/issues/468
  # See: https://github.com/NixOS/nixpkgs/pull/513841
  # labels: host:framework, module:fastflowlm
  # 1/4 maintainers: add JohnMolotov
  https://github.com/NixOS/nixpkgs/commit/e27050233a545e249ed3764a1e3f2c9c446bc361
  # 2/4 tokenizers-cpp: init at 0.1.1
  https://github.com/NixOS/nixpkgs/commit/333823505b6d120017270af3570c2ac1d3e49eea
  # 3/4 xrt: init at 2.21.75
  https://github.com/NixOS/nixpkgs/commit/39ccb34eb16936defa4f48fca0be6966fdcc250b
  # 4/4 fastflowlm: init at 1.0.11
  https://github.com/NixOS/nixpkgs/commit/89a920f939be301dcdc7f548d0cd06e994fd7ff6
  # fixups
  https://github.com/tlvince/nixpkgs/commit/81667973074333ff7f64347272f39c4c75b60209
)

pipx run --spec ghcherry==1.6.0 ghcherry -- \
  --target tlvince/nixpkgs@nixos-config \
  --first-hard-reset-to "NixOS/nixpkgs/${nixpkgs_rev}" \
  "${picks[@]}"
