{
  pkgs,
  lib,
  config,
  ...
}:
let
  fastdServices = lib.concatMapStringsSep " " (domain: "fastd-dom${toString domain.id}.service") (
    builtins.attrValues config.fnsh.sites.fnsh.domains
  );
in
{
  systemd.timers.fastd-key-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "5min";
      Unit = "fastd-key-update.service";
    };
  };
  systemd.services.fastd-key-update = {
    # Cannot use DynamicUser because we need to run systemctl
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "fastd-keys";
    };
    after = [
      "network.target"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.git
      pkgs.systemdMinimal
    ];
    script = ''
      set -euf

      target_dir="$STATE_DIRECTORY"
      target_repo="https://github.com/fnsh/fastd-keys.git"

      cd "$target_dir"

      old_hash=$(git rev-parse HEAD || echo)

      if [ ! -d ".git" ]; then
        git clone "$target_repo" .
      else
        echo "Updating fastd keys"
        git pull --quiet
      fi

      new_hash=$(git rev-parse HEAD)
      if [[ "$old_hash" == "$new_hash" ]]; then
        echo "No update found. Exiting"
        exit 0
      fi

      echo "Reloading fastd services"
      # Issue reload, but do not block because on boot it would lead to this
      # unit blocking on a transaction waiting for itself
      systemctl --no-block try-reload-or-restart ${fastdServices} 
    '';
  };
}
