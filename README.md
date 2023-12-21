# nixos-config

NixOS configuration for the [Framework Laptop 13 AMD Ryzen 5 7640U](https://github.com/tlvince/framework-laptop-13-amd-7640u).

## Automation


Flake updates are [scheduled daily](https://github.com/tlvince/nixos-config/blob/53de242809614c64c61152210d624a7990fbc1b8/.github/workflows/update-flake.yml#L5), which, on update, triggers a [build](https://github.com/tlvince/nixos-config/blob/53de242809614c64c61152210d624a7990fbc1b8/.github/workflows/build.yml) that tests the update and runs a diff. [Example run](https://github.com/tlvince/nixos-config/pull/33).

## Untracked

These require manual intervention:

```
/home/tlv/.aws
/home/tlv/.gnupg
/home/tlv/.password-store
/home/tlv/.ssh
/var/lib/btrbk/.ssh
```
