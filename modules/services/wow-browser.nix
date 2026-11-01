{pkgs, ...}: {
  systemd.services.wow-api = {
    description = "WoW browser authoritative arena API";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    unitConfig.ConditionPathExists = "/var/www/wow/current/api/server.mjs";
    environment = {
      NODE_ENV = "production";
      HOST = "127.0.0.1";
      PORT = "8787";
      ALLOWED_ORIGINS = "https://wow.infiniter.tech";
    };
    serviceConfig = {
      User = "infiniter";
      Group = "users";
      WorkingDirectory = "/var/www/wow/current";
      ExecStart = "${pkgs.nodejs_24}/bin/node /var/www/wow/current/api/server.mjs";
      Restart = "on-failure";
      RestartSec = 3;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      MemoryMax = "512M";
      UMask = "0027";
    };
  };
  services.nginx.virtualHosts."wow-api.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8787";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_read_timeout 75s;
        client_max_body_size 8k;
      '';
    };
  };
  services.nginx.virtualHosts."wow.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/wow/current";

    # The bundled backend is executed by systemd, not served as a game asset.
    locations."^~ /api/".return = "404";

    locations."/" = {
      tryFiles = "$uri $uri/ =404";
      extraConfig = ''
        add_header Cache-Control "no-cache";
      '';
    };

    # Vite fingerprints these bundles. Native models/icons keep stable names
    # and must revalidate after an atomic release switch.
    locations."^~ /assets/" = {
      tryFiles = "$uri =404";
      extraConfig = ''
        add_header Cache-Control "public, max-age=31536000, immutable";
      '';
    };
  };

  services.infiniter.websupportDDNS.records = ["wow" "wow-api"];
  systemd.tmpfiles.rules = [
    "d /var/www/wow 0755 infiniter users -"
    "d /var/www/wow/releases 0755 infiniter users -"
  ];
}
