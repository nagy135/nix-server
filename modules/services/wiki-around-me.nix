{pkgs, ...}: {
  # Source is pulled and built on nixpi; deploy.sh switches the compiled release.
  systemd.services.wiki-around-me = {
    description = "Wiki Around Me";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    environment = {
      NODE_ENV = "production";
      NITRO_HOST = "127.0.0.1";
      NITRO_PORT = "13008";
    };
    serviceConfig = {
      User = "infiniter";
      Group = "users";
      WorkingDirectory = "/var/www/wiki/current";
      ExecStart = "${pkgs.nodejs_24}/bin/node /var/www/wiki/current/server/index.mjs";
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      UMask = "0027";
    };
  };

  services.nginx.virtualHosts."wiki.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:13008";
    };
    locations."^~ /assets/" = {
      root = "/var/www/wiki/current/public";
      tryFiles = "$uri =404";
      extraConfig = ''
        add_header Cache-Control "public, max-age=31536000, immutable";
      '';
    };
  };

  services.infiniter.websupportDDNS.records = ["wiki"];

  systemd.tmpfiles.rules = [
    "d /var/www 0755 root root -"
    "d /var/www/wiki 0755 infiniter users -"
    "d /var/www/wiki/releases 0755 infiniter users -"
  ];
}
