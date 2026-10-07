# One-shot auto-rollback guard for the RKNPU bring-up deploy.
#
# Design: this module exists ONLY in the deploy generation. At boot
# the service starts, waits out the guard window, then either rolls
# back to the previous generation (and reboots into it) or exits if
# cancelled. Cancelling during or after the window:
#
#   touch /etc/rknpu-guard-cancelled
#
# Self-cleaning: the rollback switch removes this module from /etc,
# so it cannot loop after a successful rollback. Remove the module
# declaration from cm3588.nix after validation.
#
# NOTE: deliberately NOT a timer. OnBootSec timers restart on every
# switch, and a restarted timer with an elapsed delay fires instantly
# - every nixos-rebuild switch would trigger a rollback. A sleeping
# service with restartIfChanged=false/stopIfChanged=false is immune.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  guardWindowSec = "900"; # 15 min
in
{
  options.rknpuDeploy.guard.enable = lib.mkEnableOption
    "the one-shot auto-rollback guard (remove after validation)";

  config = lib.mkIf config.rknpuDeploy.guard.enable {
    systemd.services.rknpu-rollback = {
      description = "Roll back the rknpu deploy generation unless cancelled";
      wantedBy = [ "multi-user.target" ];
      # A switch must not run or restart this unit: a restart would
      # re-run the rollback as a side effect of deploying.
      restartIfChanged = false;
      stopIfChanged = false;
      # Skip entirely once cancelled (checked again after the window,
      # so touching the marker mid-window still works).
      unitConfig.ConditionPathExists = [ "!/etc/rknpu-guard-cancelled" ];
      serviceConfig = {
        Type = "simple"; # a oneshot sleep would block multi-user.target
        ExecStart = pkgs.writeShellScript "rknpu-rollback" ''
          # systemd services have no usable PATH on NixOS; the script
          # needs readlink/ls (coreutils), grep, sed, sort, awk.
          export PATH="${lib.makeBinPath [
            pkgs.coreutils pkgs.gawk pkgs.gnused pkgs.gnugrep
          ]}:$PATH"
          sleep ${guardWindowSec}
          if [ -f /etc/rknpu-guard-cancelled ]; then
            echo "guard cancelled; staying on generation"
            exit 0
          fi
          current=$(readlink /nix/var/nix/profiles/system | grep -oE "[0-9]+")
          previous=$(ls -d /nix/var/nix/profiles/system-*-link 2>/dev/null |
            sed -E "s/.*system-([0-9]+)-link/\1/" | sort -n |
            awk -v c="$current" '$1 < c { g = $1 } END { print g }')
          if [ -z "$previous" ]; then
            echo "no previous generation found; cannot roll back"
            exit 1
          fi
          echo "rolling back to generation $previous"
          # Local primitives only: no nixos-rebuild/flake evaluation
          # here (as root it fails on the user-owned flake repo:
          # libgit2 dubious-ownership). switch restores the old
          # generation live; it does NOT change the boot default, so
          # the next reboot returns to the deployed generation unless
          # the marker is touched or the default is flipped manually.
          /nix/var/nix/profiles/system-$previous-link/bin/switch-to-configuration switch
          echo "rollback complete; rebooting into it"
          sleep 5
          systemctl reboot
        '';
      };
    };
  };
}
