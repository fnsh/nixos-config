{ lib, config, ... }:
let
  cfg = config.services.meshGateway;
  dhcpDomains = lib.filter (dom: dom.subnet4 != null) (
    builtins.attrValues config.fnsh.sites.fnsh.domains
  );

  mkKeaSubnet =
    domain:
    let
      dhcpNet = "${domain.subnet4}.${toString cfg.gwId}";
      subnetCidr = "${domain.subnet4}.0.0/20";
      gatewayAddress = "${domain.subnet4}.0.${toString cfg.gwId}";
      dhcpStart = "${dhcpNet}.0";
      dhcpEnd = "${dhcpNet}.255";

    in
    {
      id = domain.id;
      subnet = subnetCidr;
      pools = [ { pool = "${dhcpStart} - ${dhcpEnd}"; } ];
      option-data = [
        {
          name = "routers";
          data = gatewayAddress;
        }
        {
          name = "domain-name-servers";
          data = domain.nextnode.v4;
        }
        {
          name = "domain-name";
          data = "ffda.io";
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
        persist = false;
      };

      interfaces-config = {
        dhcp-socket-type = "raw";
        interfaces = map (domain: domain.batInterface) dhcpDomains;
      };

      subnet4 = map mkKeaSubnet dhcpDomains;
    };
  };

  systemd.services.kea-dhcp4-server =
    let
      waitUnits = map (dom: "systemd-networkd-wait-online@${dom.batInterface}.service") dhcpDomains;
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
