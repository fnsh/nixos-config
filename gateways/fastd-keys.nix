{
  pkgs,
  lib,
  config,
  ...
}:
let
  fastdServices = lib.concatMapStringsSep " " (
    domain: "fastd-dom${toString domain.id}.service"
  ) config.services.meshGateway.domains;
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
      pkgs.ouch
      pkgs.curl
      pkgs.systemdMinimal
    ];
    script = ''
      set -euf

      cd "$STATE_DIRECTORY"

      old_etag=$(cat ./etag || echo)

      echo "Updating fastd keys"
      curl \
        --etag-compare ./etag \
        --etag-save ./etag \
        -o ./keys.tar.gz \
        https://git.darmstadt.ccc.de/ffda/fastd-keys/-/archive/master/fastd-keys-master.tar.gz?ref_type=heads

      new_etag=$(cat ./etag)
      if [[ "$old_etag" == "$new_etag" ]]; then
        echo "No update found. Exiting"
        exit 0
      fi

      ouch decompress --quiet ./keys.tar.gz --dir .
      echo "Updated fastd keys"

      echo "Reloading fastd services"
      # Issue reload, but do not block because on boot it would lead to this
      # unit blocking on a transaction waiting for itself
      systemctl --no-block try-reload-or-restart ${fastdServices} 
    '';
  };
}
