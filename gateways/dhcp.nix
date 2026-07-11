{ config, ... }:
let
  cfg = config.services.meshGateway;

  mkKeaSubnet = domain: {
    id = domain.id;
    subnet = domain.subnet4.subnetCidr;
    pools = [ { pool = "${domain.subnet4.dhcpStart} - ${domain.subnet4.dhcpEnd}"; } ];
    option-data = [
      {
        name = "routers";
        data = domain.subnet4.gatewayAddress;
      }
      {
        name = "domain-name-servers";
        data = "10.${toString (domain.id * 10)}.0.254";
      }
      {
        name = "interface-mtu";
        data = "1280";
      }
    ];
  };
in
{
  services.meshGateway.allowedUDPPorts = [ 67 ];

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      valid-lifetime = 600;
      renew-timer = 300;
      rebind-timer = 420;
      control-socket = {
        socket-type = "unix";
        socket-name = "/run/kea/kea-ctrl.socket";
      };

      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };

      interfaces-config = {
        dhcp-socket-type = "raw";
        interfaces = map (domain: domain.batInterface) cfg.domains;
      };

      subnet4 = map mkKeaSubnet cfg.domains;
    };
  };

  systemd.services.kea-dhcp4-server =
    let
      waitUnits = map (dom: "systemd-networkd-wait-online@${dom.batInterface}.service") cfg.domains;
    in
    {
      after = waitUnits;
      requires = waitUnits;
    };

  services.prometheus.exporters.kea = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9547;
    targets = [ "/run/kea/kea-ctrl.socket" ];
  };

  services.opentelemetry-collector.settings = {
    receivers.prometheus.config.scrape_configs = [
      {
        job_name = "kea";
        scrape_interval = "60s";
        static_configs = [ { targets = [ "127.0.0.1:9547" ]; } ];
      }
    ];

    service.pipelines."metrics".receivers = [ "prometheus" ];
  };
}
