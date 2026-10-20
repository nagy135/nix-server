{pkgs, ...}: let
  sentinelBun = pkgs.callPackage ../../pkgs/sentinel-bun.nix {};
in {
  # Build the committed checkout on nixpi with bun install --frozen-lockfile
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
      SENTINEL_PUBLIC_URL = "https://status.infiniter.tech";
    };
    path = with pkgs; [sentinelBun coreutils procps util-linux iproute2 gnugrep gnused gawk];
    serviceConfig = {
      User = "infiniter";
      WorkingDirectory = "/home/infiniter/services/sentinel";
      ExecStart = "${sentinelBun}/bin/bun run scripts/start.ts";
      # Created privately on nixpi (root:root, 0600); never put credentials in Nix.
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
  services.nginx.virtualHosts."status.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:13333";
  };
  services.infiniter.websupportDDNS.records = ["status"];
}
