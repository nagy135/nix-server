{
  config,
  lib,
  ...
}: let
  cfg = config.services.infiniter.htmlSharing;
in {
  options.services.infiniter.htmlSharing = {
    enable = lib.mkEnableOption "public sharing of uploaded HTML files";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "html.infiniter.tech";
      description = "Public hostname for shared HTML pages.";
    };

    directory = lib.mkOption {
      type = lib.types.path;
      default = "/var/www/html-sharing";
      description = "Writable upload directory, outside the Nix store. Files remain available until removed.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0755 infiniter users -"
    ];

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      root = cfg.directory;

      # Pages are shared by their name; there is no directory listing.
      locations."= /".return = "404";
      locations."~ (^|/)\\.".return = "404";

      locations."/" = {
        tryFiles = "$uri $uri.html =404";
        extraConfig = ''
          autoindex off;
          disable_symlinks on;
          add_header Cache-Control "no-store" always;
          add_header X-Robots-Tag "noindex, nofollow, noarchive" always;
          add_header X-Content-Type-Options "nosniff" always;
        '';
      };
    };
  };
}
