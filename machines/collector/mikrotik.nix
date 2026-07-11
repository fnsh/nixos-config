{ ... }:
{
  services.opentelemetry-collector = {
    settings = {
      service.pipelines."metrics/switch" = {
        receivers = [ "snmp" ];
        exporters = [ "otlp_http/victoriametrics" ];
      };

      receivers.snmp = {
        collection_interval = "60s";

        endpoint = "udp://switch.vlan200.cfg.ix.fra.infra.as62028.de:161";
        version = "v3";
        user = "public";
        security_level = "no_auth_no_priv";

        resource_attributes = {
          "mikrotik.sys_name" = {
            description = "Device name";
            scalar_oid = "1.3.6.1.2.1.1.5.0";
          };
        };

        attributes = {
          "fan_id".enum = [
            "1"
            "2"
          ];
          "psu_id".enum = [
            "1"
            "2"
          ];
          "cpu_id".enum = [
            "1"
            "2"
          ];
          "direction".enum = [
            "rx"
            "tx"
          ];

          "sfp.name" = {
            description = "SFP interface names";
            oid = "1.3.6.1.4.1.14988.1.1.19.1.1.2";
          };
          "interface.name" = {
            description = "IF-MIB interface names";
            oid = "1.3.6.1.2.1.2.2.1.2";
          };
        };

        metrics = {
          "mikrotik.uptime" = {
            unit = "cs";
            gauge.value_type = "int";
            scalar_oids = [ { oid = ".1.3.6.1.2.1.1.3.0"; } ];
          };

          "mikrotik.health.sfp_temperature" = {
            description = "SFP cage temperature (row 50)";
            unit = "Cel";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.50.0"; } ];
          };

          # CPU
          "mikrotik.cpu.temp" = {
            unit = "Cel";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.17.0"; } ];
          };
          "mikrotik.cpu.load" = {
            description = "hrProcessorLoad — per-core CPU load in percent";
            unit = "%";
            gauge.value_type = "int";
            scalar_oids = [
              {
                oid = "1.3.6.1.2.1.25.3.3.1.2.1";
                attributes = [
                  {
                    name = "cpu_id";
                    value = "1";
                  }
                ];
              }
              {
                oid = "1.3.6.1.2.1.25.3.3.1.2.2";
                attributes = [
                  {
                    name = "cpu_id";
                    value = "2";
                  }
                ];
              }
            ];
          };

          # Fans
          "mikrotik.fan.state" = {
            unit = "1";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.54.0"; } ];
          };

          "mikrotik.fan.speed" = {
            unit = "{RPM}";
            gauge.value_type = "int";
            scalar_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.7001.0";
                attributes = [
                  {
                    name = "fan_id";
                    value = "1";
                  }
                ];
              }
              {
                oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.7002.0";
                attributes = [
                  {
                    name = "fan_id";
                    value = "2";
                  }
                ];
              }
            ];
          };

          # PSU
          "mikrotik.psu.state" = {
            unit = "1";
            gauge.value_type = "int";
            scalar_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.7401.0";
                attributes = [
                  {
                    name = "psu_id";
                    value = "1";
                  }
                ];
              }
              {
                oid = "1.3.6.1.4.1.14988.1.1.3.100.1.3.7402.0";
                attributes = [
                  {
                    name = "psu_id";
                    value = "2";
                  }
                ];
              }
            ];
          };

          # Memory
          "mikrotik.memory.total" = {
            unit = "kBy";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.2.1.25.2.3.1.5.65536"; } ];
          };

          "mikrotik.memory.used" = {
            unit = "kBy";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.2.1.25.2.3.1.6.65536"; } ];
          };

          # Storage
          "mikrotik.storage.total" = {
            unit = "kBy";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.2.1.25.2.3.1.5.131073"; } ];
          };

          "mikrotik.storage.used" = {
            unit = "kBy";
            gauge.value_type = "int";
            scalar_oids = [ { oid = "1.3.6.1.2.1.25.2.3.1.6.131073"; } ];
          };

          # Interface rates
          "mikrotik.interface.octets" = {
            unit = "By";
            sum = {
              aggregation = "cumulative";
              monotonic = true;
              value_type = "int";
            };
            column_oids = [
              {
                oid = "1.3.6.1.2.1.31.1.1.1.6";
                attributes = [
                  { name = "interface.name"; }
                  {
                    name = "direction";
                    value = "rx";
                  }
                ];
              }
              {
                oid = "1.3.6.1.2.1.31.1.1.1.10";
                attributes = [
                  { name = "interface.name"; }
                  {
                    name = "direction";
                    value = "tx";
                  }
                ];
              }
            ];
          };
          "mikrotik.interface.last_change" = {
            unit = "cs";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.2.1.2.2.1.9";
                attributes = [ { name = "interface.name"; } ];
              }
            ];
          };
          "mikrotik.interface.link_changes" = {
            unit = "1";
            sum = {
              aggregation = "cumulative";
              monotonic = true;
              value_type = "int";
            };
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.14.1.1.90";
                attributes = [ { name = "interface.name"; } ];
              }
            ];
          };
          "mikrotik.interface.oper_status" = {
            unit = "1";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = ".1.3.6.1.2.1.2.2.1.8";
                attributes = [ { name = "interface.name"; } ];
              }
            ];
          };
          "mikrotik.interface.admin_status" = {
            unit = "1";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = ".1.3.6.1.2.1.2.2.1.7";
                attributes = [ { name = "interface.name"; } ];
              }
            ];
          };

          # SFP
          "mikrotik.sfp.rx_loss" = {
            unit = "1";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.19.1.1.3";
                attributes = [ { name = "sfp.name"; } ];
              }
            ];
          };

          "mikrotik.sfp.tx_fault" = {
            unit = "1";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.19.1.1.4";
                attributes = [ { name = "sfp.name"; } ];
              }
            ];
          };
          "mikrotik.sfp.temperature" = {
            unit = "Cel";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.19.1.1.6";
                attributes = [ { name = "sfp.name"; } ];
              }
            ];
          };

          "mikrotik.sfp.supply_voltage" = {
            unit = "mV";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.19.1.1.7";
                attributes = [ { name = "sfp.name"; } ];
              }
            ];
          };

          "mikrotik.sfp.tx_power" = {
            unit = "dBm * 1000";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.19.1.1.9";
                attributes = [ { name = "sfp.name"; } ];
              }
            ];
          };

          "mikrotik.sfp.rx_power" = {
            unit = "dBm * 1000";
            gauge.value_type = "int";
            column_oids = [
              {
                oid = "1.3.6.1.4.1.14988.1.1.19.1.1.10";
                attributes = [ { name = "sfp.name"; } ];
              }
            ];
          };
        };
      };
    };
  };
}
