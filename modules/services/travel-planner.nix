{pkgs, codex, ...}: let
  python = pkgs.python3.withPackages (p: [p.jinja2 p.jsonschema]);
in {
  users.groups.travel = {};
  users.users.travel = {
    isSystemUser = true;
    group = "travel";
    home = "/var/lib/travel";
  };

  systemd.services.travel-planner = {
    description = "SQLite vacation planner with guarded Codex edits";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    path = [codex pkgs.coreutils];
    environment = {
      HOME = "/var/lib/travel";
      CODEX_HOME = "/var/lib/travel/codex";
      TRAVEL_DB = "/var/lib/travel/travel.sqlite";
      TRAVEL_BIND = "127.0.0.1:13009";
      TRAVEL_ORIGIN = "https://travel.infiniter.tech";
      TRAVEL_PYTHON = "${python}/bin/python";
      TRAVEL_CODEX = "${codex}/bin/codex";
      PYTHONDONTWRITEBYTECODE = "1";
    };
    serviceConfig = {
      User = "travel";
      Group = "travel";
      WorkingDirectory = "/var/www/travel/current";
      ExecStart = "/var/www/travel/current/target/release/travel-server serve";
      EnvironmentFile = "/var/lib/travel/editor.env";
      StateDirectory = "travel";
      StateDirectoryMode = "0700";
      Restart = "on-failure";
      RestartSec = 5;
      KillMode = "control-group";
      TimeoutStopSec = 15;
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/travel"];
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      MemoryMax = "1536M";
      TasksMax = 128;
      LimitNOFILE = 1024;
    };
  };

  systemd.services.travel-backup = {
    description = "Online SQLite vacation planner backup";
    serviceConfig = {
      Type = "oneshot";
      User = "travel";
      Group = "travel";
      WorkingDirectory = "/var/www/travel/current";
      UMask = "0077";
    };
    environment.TRAVEL_DB = "/var/lib/travel/travel.sqlite";
    path = [pkgs.coreutils pkgs.findutils];
    script = ''
      mkdir -p /var/lib/travel/backups
      target="/var/lib/travel/backups/$(date -u +%Y%m%dT%H%M%SZ).sqlite"
      /var/www/travel/current/target/release/travel-server backup "$target"
      find /var/lib/travel/backups -name '*.sqlite' -mtime +7 -delete
    '';
  };
  systemd.timers.travel-backup = {
    wantedBy = ["timers.target"];
    timerConfig = { OnCalendar = "daily"; Persistent = true; };
  };

  services.nginx.virtualHosts."travel.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:13009";
      extraConfig = ''
        client_max_body_size 12k;
        client_body_timeout 10s;
        proxy_read_timeout 30s;
      '';
    };
  };
  services.infiniter.websupportDDNS.records = ["travel"];
  systemd.tmpfiles.rules = [
    "d /var/www/travel 0755 infiniter users -"
    "d /var/www/travel/releases 0755 infiniter users -"
    "L+ /var/www/travel/python - - - - ${python}/bin/python"
  ];
}
