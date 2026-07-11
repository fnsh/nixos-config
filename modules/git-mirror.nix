# NixOS module for mirroring public git repositories.
#
# Each instance:
#   - Clones the repository on first run (if the directory is absent or empty)
#   - Fetches and hard-resets to origin every <interval> (default: 5 min)
#   - Handles force-pushes correctly by always resetting to the remote branch
#
# A persistent systemd timer ensures the sync runs even after downtime.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gitMirror;

  instanceSubmodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "git mirror instance ${name}" // {
          default = true;
        };

        url = lib.mkOption {
          type = lib.types.str;
          description = "URL of the public git repository to mirror.";
          example = "https://git.darmstadt.ccc.de/ffda/fastd-keys.git";
        };

        directory = lib.mkOption {
          type = lib.types.str;
          description = "Absolute path where the repository will be checked out.";
          example = "/var/lib/git-mirrors/fastd-keys";
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "5min";
          description = "How often to sync the repository (systemd time span syntax).";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "root";
          description = "User that owns the checkout and runs the sync.";
        };

        branch = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Branch to track. If null, the repository's HEAD branch is used
            (whatever the remote advertises as default).
          '';
        };

        reloadUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            Systemd units to reload after a successful sync.
            Use this to notify fastd (or other services) that the repo has changed,
            e.g. [ "fastd-vpn.service" ].
          '';
          example = [ "fastd-vpn.service" ];
        };
      };
    }
  );

  enabledInstances = lib.filterAttrs (_: inst: inst.enable) cfg.instances;

  mkSyncScript =
    name: inst:
    pkgs.writeShellScript "git-mirror-${name}-sync" ''
      set -euo pipefail

      DIR=${lib.escapeShellArg inst.directory}
      URL=${lib.escapeShellArg inst.url}

      # Clone if the working tree doesn't exist yet.
      if [ ! -d "$DIR/.git" ]; then
        rm -rf "$DIR"
        ${pkgs.git}/bin/git clone -- "$URL" "$DIR"
      fi

      cd "$DIR"

      # Fetch, pruning refs that vanished on the remote.
      # --force ensures we accept non-fast-forward updates (force pushes).
      ${pkgs.git}/bin/git fetch --prune --force origin

      # Determine the branch to reset to.
      ${if inst.branch != null then
        "BRANCH=${lib.escapeShellArg inst.branch}"
      else
        ''
          # Ask the remote which branch HEAD points at.
          BRANCH=$(${pkgs.git}/bin/git ls-remote --symref origin HEAD \
            | ${pkgs.gawk}/bin/awk '/^ref:/ { sub("refs/heads/", "", $2); print $2 }')
          # Fall back to the local HEAD branch if ls-remote gave nothing.
          if [ -z "$BRANCH" ]; then
            BRANCH=$(${pkgs.git}/bin/git symbolic-ref --short HEAD 2>/dev/null || echo main)
          fi
        ''}

      # Hard-reset to the remote branch – this handles force pushes correctly.
      ${pkgs.git}/bin/git reset --hard "origin/$BRANCH"

      # Remove any untracked files / dirs left over from previous states.
      ${pkgs.git}/bin/git clean -fd

      ${lib.concatMapStrings (unit: ''
        ${pkgs.systemd}/bin/systemctl reload ${lib.escapeShellArg unit} 2>/dev/null || true
      '') inst.reloadUnits}
    '';

  mkService =
    name: inst:
    lib.nameValuePair "git-mirror-${name}" {
      description = "Git mirror – ${name} (${inst.url})";
      after = [
        "network.target"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = inst.user;
        ExecStart = mkSyncScript name inst;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

  mkTimer =
    name: inst:
    lib.nameValuePair "git-mirror-${name}" {
      description = "Git mirror timer – ${name}";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # Repeat on this cadence.
        OnUnitActiveSec = inst.interval;
        # Catch up on missed runs (e.g. after downtime).
        Persistent = true;
      };
    };
in
{
  options.services.gitMirror = {
    instances = lib.mkOption {
      type = lib.types.attrsOf instanceSubmodule;
      default = { };
      description = "Named git mirror instances.";
    };
  };

  config = lib.mkIf (enabledInstances != { }) {
    environment.systemPackages = [ pkgs.git ];

    systemd.services = lib.mapAttrs' mkService enabledInstances;
    systemd.timers = lib.mapAttrs' mkTimer enabledInstances;
  };
}
