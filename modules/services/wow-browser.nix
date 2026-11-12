{
  config,
  pkgs,
  ...
}: {
  assertions = [
    {
      assertion = config.networking.hostName == "hetzner";
      message = "WoW runtime and DNS belong on Hetzner; import wow-browser.nix only on hetzner.";
    }
  ];

  systemd.services.wow-api = {
    description = "WoW browser authoritative arena API";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    unitConfig.ConditionPathExists = "/var/www/wow/current/api/server.mjs";
    environment = {
      NODE_ENV = "production";
      WOW_DATABASE_PATH = "/var/lib/wow-api/leaderboard.sqlite";
      HOST = "127.0.0.1";
      PORT = "8787";
      ALLOWED_ORIGINS = "https://wow.infiniter.tech";
      TURN_SECRET_FILE = "/run/credentials/wow-api.service/turn-secret";
      TURN_URLS = "stun:wow-api.infiniter.tech:3478,turn:wow-api.infiniter.tech:3478?transport=udp,turn:wow-api.infiniter.tech:3478?transport=tcp";
    };
    serviceConfig = {
      User = "infiniter";
      Group = "users";
      WorkingDirectory = "/var/www/wow/current";
      # The manager reads this before ProtectHome is applied to the API.
      EnvironmentFile = "/home/infiniter/services/wow-browser/.env";
      ExecStart = "${pkgs.nodejs_24}/bin/node /var/www/wow/current/api/server.mjs";
      Restart = "on-failure";
      RestartSec = 3;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      MemoryMax = "512M";
      StateDirectory = "wow-api";
      StateDirectoryMode = "0700";
      ReadWritePaths = ["/var/lib/wow-api"];
      UMask = "0077";
      LoadCredential = "turn-secret:/var/lib/wow-voice/turn-secret";
    };
  };

  # WebRTC relay for lobby voice when the two players cannot connect directly.
  # The root-owned secret is provisioned on the host, never stored in Git/Nix.
  services.coturn = {
    enable = true;
    realm = "wow-api.infiniter.tech";
    listening-ips = ["91.99.204.136"];
    relay-ips = ["91.99.204.136"];
    use-auth-secret = true;
    static-auth-secret-file = "/run/credentials/coturn.service/turn-secret";
    no-cli = true;
    no-tls = true;
    no-dtls = true;
    no-tcp-relay = true;
    min-port = 49160;
    max-port = 49559;
    extraConfig = ''
      fingerprint
      no-multicast-peers
      user-quota=4
      total-quota=400
      max-bps=128000
      max-allocate-lifetime=3600
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=::1
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };
  systemd.services.coturn.serviceConfig.LoadCredential = "turn-secret:/var/lib/wow-voice/turn-secret";
  networking.firewall = {
    allowedTCPPorts = [3478];
    allowedUDPPorts = [3478];
    allowedUDPPortRanges = [
      {
        from = 49160;
        to = 49559;
      }
    ];
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
