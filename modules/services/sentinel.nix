{
  config,
  lib,
  pkgs,
  ...
}: let
  sentinelBun = pkgs.callPackage ../../pkgs/sentinel-bun.nix {};
  cfg = config.services.infiniter.sentinel;
in {
  options.services.infiniter.sentinel.domain = lib.mkOption {
    type = lib.types.str;
    default = "status.infiniter.tech";
    description = "Public HTTPS hostname for this host's Sentinel dashboard.";
  };

  config = {
    # Build the committed checkout on the host with bun install --frozen-lockfile
    # and bun run build before starting/restarting this service.
    systemd.services.sentinel = {
      description = "Sentinel system metrics dashboard";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      environment = {
        NODE_ENV = "production";
        PORT = "13333";
        SENTINEL_INTERVAL_MS = "5000";
        SENTINEL_DB_PATH = "/var/lib/sentinel/metrics.sqlite";
        SENTINEL_HOST = "127.0.0.1";
        SENTINEL_PUBLIC_URL = "https://${cfg.domain}";
      };
      path = with pkgs; [sentinelBun coreutils procps util-linux iproute2 gnugrep gnused gawk];
      serviceConfig = {
        User = "infiniter";
        WorkingDirectory = "/home/infiniter/services/sentinel";
        ExecStart = "${sentinelBun}/bin/bun run scripts/start.ts";
        # Created privately on each host (root:root, 0600); never put credentials in Nix.
        EnvironmentFile = "/etc/sentinel/credentials.env";
        Restart = "on-failure";
        RestartSec = 5;
        StateDirectory = "sentinel";
        StateDirectoryMode = "0700";
        UMask = "0077";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
      };
    };

    environment.systemPackages = [sentinelBun];
    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:13333";
    };
    services.infiniter.websupportDDNS.records = [(lib.removeSuffix ".${config.services.infiniter.websupportDDNS.zone}" cfg.domain)];
  };
}
