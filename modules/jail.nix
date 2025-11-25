{
  jail-nix,
  pkgs,
  ...
}: {
  _module.args.jail = jail-nix.lib.extend {
    inherit pkgs;

    additionalCombinators = builtinCombinators:
      with builtinCombinators; {
        # TODO: Remove jail.nix network combinator override
        # Issue URL: https://github.com/tlvince/nixos-config/issues/394
        # Bind uplink resolvers for systemd-resolved compatibility
        # See: https://todo.sr.ht/~alexdavid/jail.nix/6
        # labels: module:jail, host:framework
        network = state:
          compose [
            time-zone
            (share-ns "net")
            (runtime-deep-ro-bind "/etc/hosts")
            (runtime-deep-ro-bind "/etc/nsswitch.conf")
            (ro-bind "/run/systemd/resolve/resolv.conf" "/etc/resolv.conf")
            (runtime-deep-ro-bind "/etc/ssl")
            (write-text "/etc/hostname" "${state.hostname}\n")
            (unsafe-add-raw-args "--hostname ${escape state.hostname}")
          ]
          state;
      };
  };
}
