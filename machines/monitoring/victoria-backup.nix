{ config, pkgs, ... }:
let
  vm = config.services.victoriametrics;
  storageDataPath = "/var/lib/private/${vm.stateDir}";

  # OVH Object Storage (S3 compatible), de region.
  s3Endpoint = "https://s3.de.io.cloud.ovh.net";
  s3Dst = "s3://fnsh-htz-monitoring-backup/victoriametrics";

  backupScript = pkgs.writeShellScript "victoriametrics-backup" ''
    set -euo pipefail

    pass="$(<"$CREDENTIALS_DIRECTORY/vm_auth_pass")"
    base="http://${vm.basicAuthUsername}:''${pass}@127.0.0.1${vm.listenAddress}"

    exec ${vm.package}/bin/vmbackup \
      -storageDataPath=${storageDataPath} \
      -snapshot.createURL="''${base}/snapshot/create" \
      -dst=${s3Dst} \
      -customS3Endpoint=${s3Endpoint} \
      -credsFilePath=${config.age.secrets.ovh_backup_creds.path}
  '';
in
{
  config = {
    age.secrets.ovh_backup_creds.file = ../../secrets/ovh_backup_creds.age;

    systemd.services.victoriametrics-backup = {
      description = "Back up VictoriaMetrics to OVH S3";
      after = [ "victoriametrics.service" ];
      requires = [ "victoriametrics.service" ];

      serviceConfig = {
        Type = "oneshot";
        # vmbackup runs as root so it can read the DynamicUser-owned (0700)
        # storage data path and snapshots.
        Environment = [ "AWS_REGION=de" ];
        LoadCredential = [ "vm_auth_pass:${vm.basicAuthPasswordFile}" ];
        ExecStart = backupScript;
      };
    };

    systemd.timers.victoriametrics-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
