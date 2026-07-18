{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.infiniter.systemStatus;
  domain = "pi-status.infiniter.tech";
  adminPasswordFile = "/var/lib/grafana/admin-password";
  secretKeyFile = "/var/lib/grafana/secret-key";
  nodeExporterPort = config.services.prometheus.exporters.node.port;

  dashboard = pkgs.writeText "pi-status-dashboard.json" (builtins.toJSON {
    uid = "pi-status";
    title = "Pi Status";
    tags = ["nixos" "system"];
    timezone = "browser";
    schemaVersion = 39;
    version = 1;
    refresh = "10s";
    time = {
      from = "now-6h";
      to = "now";
    };
    panels = [
      {
        id = 1;
        title = "CPU Usage";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 12;
          x = 0;
          y = 0;
        };
        fieldConfig.defaults.unit = "percent";
        targets = [
          {
            datasource.uid = "prometheus";
            expr = ''100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'';
            legendFormat = "CPU";
          }
        ];
      }
      {
        id = 2;
        title = "Memory Usage";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 12;
          x = 12;
          y = 0;
        };
        fieldConfig.defaults.unit = "percent";
        targets = [
          {
            datasource.uid = "prometheus";
            expr = ''(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100'';
            legendFormat = "RAM";
          }
        ];
      }
      {
        id = 3;
        title = "System Load";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 8;
          x = 0;
          y = 8;
        };
        targets = [
          {
            datasource.uid = "prometheus";
            expr = "node_load1";
            legendFormat = "1m";
          }
          {
            datasource.uid = "prometheus";
            expr = "node_load5";
            legendFormat = "5m";
          }
          {
            datasource.uid = "prometheus";
            expr = "node_load15";
            legendFormat = "15m";
          }
        ];
      }
      {
        id = 4;
        title = "Root Disk Usage";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 8;
          x = 8;
          y = 8;
        };
        fieldConfig.defaults.unit = "percent";
        targets = [
          {
            datasource.uid = "prometheus";
            expr = ''100 - (node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|ramfs|overlay"} / node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|ramfs|overlay"} * 100)'';
            legendFormat = "/";
          }
        ];
      }
      {
        id = 5;
        title = "Temperature";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 8;
          x = 16;
          y = 8;
        };
        fieldConfig.defaults.unit = "celsius";
        targets = [
          {
            datasource.uid = "prometheus";
            expr = "node_hwmon_temp_celsius";
            legendFormat = "{{chip}} {{sensor}}";
          }
          {
            datasource.uid = "prometheus";
            expr = "node_thermal_zone_temp";
            legendFormat = "{{type}}";
          }
        ];
      }
      {
        id = 6;
        title = "Disk I/O";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 12;
          x = 0;
          y = 16;
        };
        fieldConfig.defaults.unit = "Bps";
        targets = [
          {
            datasource.uid = "prometheus";
            expr = "sum(rate(node_disk_read_bytes_total[5m]))";
            legendFormat = "read";
          }
          {
            datasource.uid = "prometheus";
            expr = "sum(rate(node_disk_written_bytes_total[5m]))";
            legendFormat = "write";
          }
        ];
      }
      {
        id = 7;
        title = "Network";
        type = "timeseries";
        gridPos = {
          h = 8;
          w = 12;
          x = 12;
          y = 16;
        };
        fieldConfig.defaults.unit = "Bps";
        targets = [
          {
            datasource.uid = "prometheus";
            expr = ''sum(rate(node_network_receive_bytes_total{device!~"lo|veth.*|br.*|docker.*"}[5m]))'';
            legendFormat = "receive";
          }
          {
            datasource.uid = "prometheus";
            expr = ''sum(rate(node_network_transmit_bytes_total{device!~"lo|veth.*|br.*|docker.*"}[5m]))'';
            legendFormat = "transmit";
          }
        ];
      }
    ];
  });
in {
  options.services.infiniter.systemStatus.enable = lib.mkEnableOption "system status dashboard";

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      retentionTime = "15d";
      globalConfig.scrape_interval = "15s";

      exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = ["systemd" "processes"];
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {targets = ["127.0.0.1:${toString nodeExporterPort}"];}
          ];
        }
      ];
    };

    services.grafana = {
      enable = true;

      settings = {
        server = {
          domain = domain;
          http_addr = "127.0.0.1";
          http_port = 3000;
          root_url = "https://${domain}/";
        };

        security = {
          admin_user = "admin";
          admin_password = "$__file{${adminPasswordFile}}";
          secret_key = "$__file{${secretKeyFile}}";
        };

        users.allow_sign_up = false;
      };

      provision = {
        enable = true;

        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              uid = "prometheus";
              url = "http://127.0.0.1:9090";
              isDefault = true;
            }
          ];
        };

        dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "System";
              options.path = dashboard;
            }
          ];
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };

    systemd.services.grafana-admin-password = {
      description = "Generate the Grafana administrator password";
      requiredBy = ["grafana.service"];
      before = ["grafana.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.coreutils}/bin/install -d -m 0750 -o grafana -g grafana /var/lib/grafana
        if [[ ! -s ${adminPasswordFile} ]]; then
          umask 077
          ${pkgs.openssl}/bin/openssl rand -base64 32 > ${adminPasswordFile}
          ${pkgs.coreutils}/bin/chown grafana:grafana ${adminPasswordFile}
        fi
        if [[ ! -s ${secretKeyFile} ]]; then
          umask 077
          ${pkgs.openssl}/bin/openssl rand -base64 32 > ${secretKeyFile}
          ${pkgs.coreutils}/bin/chown grafana:grafana ${secretKeyFile}
        fi
      '';
    };
  };
}
