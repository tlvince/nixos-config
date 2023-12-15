# nixos-config

NixOS configuration for the [Framework Laptop 13 AMD Ryzen 5 7640U](https://github.com/tlvince/framework-laptop-13-amd-7640u).

## Automation

Flake updates are [scheduled daily](https://github.com/tlvince/nixos-config/blob/1a43225e7815f0d1e14e81bdbb6f92fd1190862d/.github/workflows/update-flake.yml#L4-L5), which, on update, triggers a [build](https://github.com/tlvince/nixos-config/blob/1a43225e7815f0d1e14e81bdbb6f92fd1190862d/.github/workflows/build.yml) that tests the update and runs a diff. [Example run](https://github.com/tlvince/nixos-config/actions/runs/7159972408#summary-19493825548).

## Untracked

These require manual intervention:

- /home/tlv/.aws
- /home/tlv/.gnupg
- /home/tlv/.password-store
- /home/tlv/.ssh
- /var/lib/btrbk/.ssh
