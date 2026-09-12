{...}: let
  SSL = {
    enableACME = true;
    forceSSL = true;
  };

  proxyHost = host: port:
    SSL
    // {
      locations."/".proxyPass = "http://127.0.0.1:${toString port}";
      serverAliases = ["www.${host}"];
    };

  staticHost = root: aliases:
    SSL
    // {
      inherit root;
      locations."/" = {tryFiles = "$uri /index.html";};
      serverAliases = aliases;
    };

  websocketExtraConfig = ''
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $remote_addr;
  '';
in {
  services.nginx.enable = true;

  services.nginx.virtualHosts = {
    "photo.infiniter.tech" = proxyHost "photo.infiniter.tech" 2283;
    "paste.infiniter.tech" = proxyHost "paste.infiniter.tech" 2284;

    "drive.infiniter.tech" =
      proxyHost "drive.infiniter.tech" 13001
      // {
        extraConfig = ''
          client_max_body_size 1024M;
          client_body_timeout 60s;
          proxy_read_timeout 600s;
          proxy_connect_timeout 60s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
      };

    "netflix.infiniter.tech" = proxyHost "netflix.infiniter.tech" 8096;

    "fit.infiniter.tech" = proxyHost "fit.infiniter.tech" 3000;
    "fit-api.infiniter.tech" = proxyHost "fit-api.infiniter.tech" 8080;
    "shift.infiniter.tech" = proxyHost "shift.infiniter.tech" 3069;

    "portfolio.infiniter.tech" = staticHost "/var/www/portfolio/" [
      "www.portfolio.infiniter.tech"
      "infiniter.tech"
      "www.infiniter.tech"
    ];

    "gol.infiniter.tech" = staticHost "/var/www/gol/" [
      "www.gol.infiniter.tech"
      "gol.infiniter.tech"
    ];

    "car.infiniter.tech" = staticHost "/var/www/car/" [
      "www.car.infiniter.tech"
      "car.infiniter.tech"
    ];

    "chat.infiniter.tech" = proxyHost "chat.infiniter.tech" 13013;
    "uptime.infiniter.tech" = proxyHost "uptime.infiniter.tech" 13331;
    "ntfy.infiniter.tech" = proxyHost "ntfy.infiniter.tech" 13888;
    "addyart.eu" = proxyHost "addyart.eu" 13777;

    "mongo.addyart.eu" =
      SSL
      // {
        locations."/".proxyPass = "http://127.0.0.1:9000";
        serverAliases = [
          "www.mongo.eu"
        ];
      };

    "version2.addyart.eu" =
      SSL
      // {
        serverAliases = ["www.version2.addyart.eu"];
        locations."/" = {
          proxyPass = "http://127.0.0.1:13005";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
        extraConfig = ''
          client_max_body_size 50M;
        '';
      };

    "car-socket.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:13331";
          proxyWebsockets = true;
        };
      };

    "clerk.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "https://4qkmi9pm8ib2.clerk.accounts.dev";
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_set_header Host 4qkmi9pm8ib2.clerk.accounts.dev;
            proxy_set_header X-Forwarded-Host clerk.infiniter.tech;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Origin $http_origin;
            proxy_set_header Cookie $http_cookie;
            proxy_http_version 1.1;
            proxy_pass_request_body on;
            proxy_pass_request_headers on;

            proxy_cookie_domain 4qkmi9pm8ib2.clerk.accounts.dev clerk.infiniter.tech;
            proxy_cookie_path / /;

            proxy_hide_header 'Access-Control-Allow-Origin';
            proxy_hide_header 'Access-Control-Allow-Credentials';

            if ($request_method = 'OPTIONS') {
              add_header 'Access-Control-Allow-Origin' '$http_origin' always;
              add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
              add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, X-Requested-With, Clerk-Proxy-Url, Cookie' always;
              add_header 'Access-Control-Allow-Credentials' 'true' always;
              add_header 'Access-Control-Max-Age' 86400;
              return 204;
            }

            add_header 'Access-Control-Allow-Origin' '$http_origin' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
          '';
        };

        locations."/npm/" = {
          proxyPass = "https://4qkmi9pm8ib2.clerk.accounts.dev";
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_set_header Host 4qkmi9pm8ib2.clerk.accounts.dev;
            proxy_http_version 1.1;

            proxy_hide_header 'Access-Control-Allow-Origin';
            proxy_hide_header 'Access-Control-Allow-Credentials';

            add_header 'Access-Control-Allow-Origin' '*' always;
          '';
        };

        serverAliases = [
          "www.clerk.infiniter.tech"
        ];
      };

    "db-gol.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3210";
          extraConfig = websocketExtraConfig;
        };

        serverAliases = [
          "www.db-gol.infiniter.tech"
        ];
      };

    "edit.infiniter.tech" = staticHost "/var/www/edit/" [
      "www.edit.infiniter.tech"
      "edit.infiniter.tech"
    ];

    "convex-edit.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3212";
          extraConfig = websocketExtraConfig;
        };

        serverAliases = [
          "www.convex-edit.infiniter.tech"
        ];
      };

    "convex-site-edit.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3213";
          extraConfig = websocketExtraConfig;
        };

        serverAliases = [
          "www.convex-site-edit.infiniter.tech"
        ];
      };

    "dashboard-edit.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:6792";
          extraConfig = websocketExtraConfig;
        };

        serverAliases = [
          "www.dashboard-edit.infiniter.tech"
        ];
      };

    "n8n.infiniter.tech" =
      SSL
      // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:5678";
          extraConfig = ''
            proxy_http_version 1.1;

            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };

        serverAliases = [
          "www.n8n.infiniter.tech"
        ];
      };

    "share.infiniter.tech" =
      SSL
      // {
        root = "/var/www/share";
        locations."/" = {
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
            try_files $uri $uri/ =404;
          '';
        };
        serverAliases = [
          "www.share.infiniter.tech"
        ];
        extraConfig = ''
          client_max_body_size 2048M;
        '';
      };
  };

  fileSystems."/var/www/portfolio" = {
    device = "/home/infiniter/services/vite-portfolio/dist";
    fsType = "none";
    options = ["bind" "ro"];
  };
  fileSystems."/var/www/gol" = {
    device = "/home/infiniter/services/convex_game_of_life/apps/web/dist";
    fsType = "none";
    options = ["bind" "ro"];
  };
  fileSystems."/var/www/car" = {
    device = "/home/infiniter/services/browser-car/dist";
    fsType = "none";
    options = ["bind" "ro"];
  };
  fileSystems."/var/www/edit" = {
    device = "/home/infiniter/services/ai_image_edit/apps/web/dist";
    fsType = "none";
    options = ["bind" "ro"];
  };

  systemd.tmpfiles.rules = [
    "d /var/www 0755 root root -"
    "d /var/www/portfolio 0755 nginx nginx -"
    "d /var/www/gol 0755 nginx nginx -"
    "d /var/www/car 0755 nginx nginx -"
    "d /var/www/edit 0755 nginx nginx -"
  ];
}
