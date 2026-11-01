{...}: {
  services.nginx.virtualHosts."wow.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/wow/current";

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

  services.infiniter.websupportDDNS.records = ["wow"];
  systemd.tmpfiles.rules = [
    "d /var/www/wow 0755 infiniter users -"
    "d /var/www/wow/releases 0755 infiniter users -"
  ];
}
