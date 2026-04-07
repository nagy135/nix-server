{ pkgs, inputs, config, lib, ... }:
let 
  sshKeys = [
  ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7XoDHd8Pi5tylzVnjKvKoM+5GzT7Pcuk2PfWOsGEu7''
  ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnmNqABy0voX/rDdThGadpR5ZSF6NWJ2oWaGJvRJWF4H1PZHVJr/BSl/s7zQM5Tp4PH34+g8CNZAaFFP5aThGDv22cIAlZneM5t5HL0iHiN9/L9e9W3U7ySLDYdRls0QBnURUInNh8pK6IqqJTg8LDx6kfxOBhJyPtlLFhxqWtJSYTjm17B/tU8bvtslbg97Q1ck89VVX1g++2YCjOGhZv0HKp7X3F6RvTlJolYxUwvZ4qPdx2eXSWgSLAYJc7aDlJLdqEqPqA1senvcIYam+cWkxqnmEobIhmc4oDSnLO/Yf5vRANP/tw7VPgf9kxnXa7OEhbEt++Uts+FidZZC/xFnT9x2Rp8I/5MGLn52y5QPmSm3KTPSxBkFuzLA93opjOIiijov5EECZhtsWWN4z97rSeBu11OMXcbTKPTPCjOWxylDW83xFx6gl6/lmu5UirbRGqoOlzOoV2hrLy/MlOXX9lDU5LtlZShId4hbzt/lkctv7AcnE9QTSU/8651d8= infiniter@infiniter''
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    (import ./modules/opencode-projects.nix {
      projectPaths = [
        "/home/infiniter/services/vite-portfolio"
      ];
      opencodePkg = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.opencode;
    })
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops

  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # without this is starts eating all CPU for some reason, nscd is something with cache that should not matter
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];


  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = sshKeys;
  users.users.infiniter.openssh.authorizedKeys.keys = sshKeys;

# environment.etc."nextcloud-admin-pass".text = "INFIdag5a5al6";
# services.nextcloud = {
#   enable = true;
#   package = pkgs.nextcloud30;
#   hostName = "localhost";
#   config.adminpassFile = "/etc/nextcloud-admin-pass";
#   config.dbtype = "sqlite";
# };


  environment.etc."paperless-admin-pass".text = "dag5a5al6";
  services = {
    immich = {
      host = "0.0.0.0";
      enable = false;
      port = 2283;
    };
    microbin = {
      enable = false;
      settings = {
        MICROBIN_BIND = "0.0.0.0";
        MICROBIN_PORT = 2284;
      };
    };
    jellyfin = {
      enable = false;
      openFirewall = true;
    };

    paperless = {
      enable = false;
      consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
        PAPERLESS_URL = "https://paper.infiniter.tech";
      };
      passwordFile = "/etc/paperless-admin-pass";
    };



    vaultwarden = {
      enable = false;
      dbBackend = "sqlite";
      environmentFile = config.sops.secrets.pass.path;

      config = {
        DATA_FOLDER = "/var/lib/vaultwarden";
        DOMAIN = "https://pass.infiniter.tech";
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
        SIGNUPS_ALLOWED = false;
        WEB_VAULT_ENABLED = true;
      };
    };

    #    firefly-iii = {
    #      enable = true;
    #      virtualHost = "0.0.0.0";
    #      enableNginx = true;
    #
    #      settings = {
    # APP_KEY_FILE = config.sops.secrets.pass.path;
    # DB_CONNECTION = "pgsql";
    # DB_DATABASE = "firefly";
    # DB_HOST = "localhost";
    # DB_USERNAME = "firefly-iii";
    # APP_URL = "tax.infiniter.tech";
    # TZ = "Europe/Zurich";
    # TRUSTED_PROXIES = "**";
    #      };
    #    };
  };
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "firefly" ];
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #type database  DBuser  auth-method
  #     local all       all     trust
  #   '';
  #
  # };

  # Copy secrets/keys.yaml.example to secrets/keys.yaml on each machine.
  sops.defaultSopsFile = ./secrets/keys.yaml;
  sops.age.sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.age.generateKey = true;
  # sops.secrets.pass = {
  #   owner = "firefly-iii";
  #   group = "firefly-iii";
  #   mode = "0400";
  # };
  sops.secrets.pass = {
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };
  sops.secrets.opencode-server-password = {
    owner = "opencode";
    group = "opencode";
    mode = "0400";
  };
  # Optional later if OpenCode needs git-over-SSH access:
  # sops.secrets.opencode-deploy-key = {
  #   owner = "opencode";
  #   group = "opencode";
  #   mode = "0400";
  # };

  nixpkgs.overlays = [
    (self: super: {
      paperless-ngx = super.paperless-ngx.overrideAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
      });
    })];


  programs.ssh.startAgent = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };


  users.users.infiniter = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" "video" "podman" "jellyfin" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "infiniter" = import ./home.nix;
    };
  };


    environment.systemPackages = with pkgs;
    [
      gcc
      lsd
      ripgrep
      sops
      lua
      lazygit
      z-lua
      bun
      nodejs
      docker-compose
      git
      # postgresql
      docker-client
      neovim
      python3
    ];
# Arion works with Docker, but for NixOS-based containers, you need Podman
# since NixOS 21.05.
virtualisation.docker.enable = true;
#  virtualisation.podman.enable = true;
#  virtualisation.podman.dockerSocket.enable = true;
#
#  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

# services.postgresql = {
#   enable = true;
#   authentication = ''
#   local   all             all                                     trust
#   host    all             all             0.0.0.0/0               trust
#   host    all             all             ::1/128                 trust
#   '';
#
#   enableTCPIP = true;
#   ensureDatabases = [ "3dprints" "dano" ];
#   ensureUsers = [
#     {
#       name = "3dprints";
#       ensureDBOwnership = true;
#     }
#     {
#       name = "dano";
#       ensureDBOwnership = true;
#     }
#   ];
# };

  networking.firewall.allowedTCPPorts = [
    25   # SMTP
    80   # ACME / web
    143  # IMAP
    443  # webmail
    587  # submission
    993  # IMAPS
    4190 # ManageSieve
  ];

swapDevices = [{
  device = "/var/lib/swapfile";
  size = 8 * 1024;
}];


security.acme = {
  acceptTerms = true;

  defaults.email = "viktor.nagy1995@gmail.com";
};


    networking.enableIPv6 = false;


  services.nginx.enable = true;

services.nginx.virtualHosts =
  let
    SSL = {
      enableACME = true;
      forceSSL = true;
    }; in
    {
      "photo.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:2283";
        serverAliases = [
          "www.photo.infiniter.tech"
        ];
      });

      "paste.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:2284";
        serverAliases = [
          "www.paste.infiniter.tech"
        ];
      });
# 
      "drive.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13001";
        serverAliases = [
          "www.drive.infiniter.tech"
        ];
        extraConfig = ''
        client_max_body_size 1024M;
        client_body_timeout 60s;
        proxy_read_timeout 600s;
        proxy_connect_timeout 60s;
        proxy_send_timeout 600s;
        send_timeout 600s;
        '';

      });
      "netflix.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:8096";
        serverAliases = [
          "www.netflix.infiniter.tech"
        ];
      });
      # "tax.infiniter.tech" = (SSL // {
      #   locations."/".proxyPass = "http://127.0.0.1:9080";
      #   serverAliases = [
      #     "www.tax.infiniter.tech"
      #   ];
      # });
      # "pass.infiniter.tech" = (SSL // {
      #   locations."/".proxyPass = "http://127.0.0.1:8222";
      #   serverAliases = [
      #     "www.pass.infiniter.tech"
      #   ];
      # });
	#      "paper.infiniter.tech" = (SSL // {
	#        locations."/".proxyPass = "http://127.0.0.1:28981";
	#        serverAliases = [
	#          "www.paper.infiniter.tech"
	#        ];
	# locations = {
	# 	"~ \"^/([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3})$\"" = {
	# 		proxyPass = "http://$1:port/your/location";
	# 		proxyWebsockets = true;
	# 	};
	# };
	#      });

      "fit.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:3000";
        serverAliases = [
          "www.fit.infiniter.tech"
        ];
      });
      "fit-api.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:8080";
        serverAliases = [
          "www.fit-api.infiniter.tech"
        ];
      });
      "shift.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:3069";
        serverAliases = [
          "www.shift.infiniter.tech"
        ];
      });
      # "word.infiniter.tech" = (SSL // {
      #   locations."/".proxyPass = "http://127.0.0.1:13002";
      #   serverAliases = [
      #     "www.word.infiniter.tech"
      #   ];
      # });
      "portfolio.infiniter.tech" = (SSL // {
        root = "/var/www/portfolio/";
        locations."/" = { tryFiles = "$uri /index.html"; };
        serverAliases = [ "www.portfolio.infiniter.tech" "infiniter.tech" "www.infiniter.tech" ];
      });
      "gol.infiniter.tech" = (SSL // {
        root = "/var/www/gol/";
        locations."/" = { tryFiles = "$uri /index.html"; };
        serverAliases = [ "www.gol.infiniter.tech" "gol.infiniter.tech" ];
      });

      "car.infiniter.tech" = (SSL // {
        root = "/var/www/car/";
        locations."/" = { tryFiles = "$uri /index.html"; };
        serverAliases = [ "www.car.infiniter.tech" "car.infiniter.tech" ];
      });

      "chat.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13013";
        serverAliases = [
          "www.chat.infiniter.tech"
        ];
      });
      "uptime.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13331";
        serverAliases = [
          "www.uptime.infiniter.tech"
        ];
      });

      "ntfy.infiniter.tech" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13888";
        serverAliases = [
          "www.ntfy.infiniter.tech"
        ];
      });
      "addyart.eu" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13777";
        serverAliases = [
          "www.addyart.eu"
        ];
      });
      "mongo.addyart.eu" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:9000";
        serverAliases = [
          "www.mongo.eu"
        ];
      });
      "version2.addyart.eu" = (SSL // {
		      serverAliases = [ "www.version2.addyart.eu" ];
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
		      });
"car-socket.infiniter.tech" = (SSL // {
  locations."/" = {
    proxyPass = "http://127.0.0.1:13331";
    proxyWebsockets = true;
  };
});

# "car-socket.infiniter.tech" = (SSL // {
#   serverAliases = [
#     "www.car-socket.infiniter.tech"
#   ];
#   locations."/" = {
#     proxyPass = "http://127.0.0.1:13331";
#     proxyWebsockets = true;
#     extraConfig = ''
#       proxy_http_version 1.1;
#       proxy_set_header Upgrade $http_upgrade;
#       proxy_set_header Connection "upgrade";
#       proxy_set_header Host $host;
#       proxy_set_header X-Forwarded-Proto $scheme;
#       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#       proxy_read_timeout 60s;
#       proxy_send_timeout 60s;
#     '';
#   };
# });

      "clerk.infiniter.tech" = (SSL // {
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
      
      # Pass cookies back from upstream
      proxy_cookie_domain 4qkmi9pm8ib2.clerk.accounts.dev clerk.infiniter.tech;
      proxy_cookie_path / /;
      
      # Hide upstream CORS headers
      proxy_hide_header 'Access-Control-Allow-Origin';
      proxy_hide_header 'Access-Control-Allow-Credentials';
      
      # Handle CORS preflight
      if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '$http_origin' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, X-Requested-With, Clerk-Proxy-Url, Cookie' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Max-Age' 86400;
        return 204;
      }
      
      # Add CORS headers to all responses
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
      
      # Hide upstream CORS headers
      proxy_hide_header 'Access-Control-Allow-Origin';
      proxy_hide_header 'Access-Control-Allow-Credentials';
      
      # Add our own
      add_header 'Access-Control-Allow-Origin' '*' always;
    '';
  };
  
  serverAliases = [
    "www.clerk.infiniter.tech"
  ];
});

      "db-gol.infiniter.tech" = (SSL // {
		      locations."/" = {
		      proxyPass = "http://127.0.0.1:3210";
		      extraConfig = ''
		      proxy_http_version 1.1;

		      proxy_set_header Upgrade $http_upgrade;
		      proxy_set_header Connection "upgrade";

		      proxy_set_header Host $host;
		      proxy_set_header X-Forwarded-Proto $scheme;
		      proxy_set_header X-Forwarded-For $remote_addr;
		      '';
		      };

		      serverAliases = [
		      "www.db-gol.infiniter.tech"
		      ];
		      });

# edit {{{
	# ai_image_edit-backend-1     ghcr.io/get-convex/convex-backend:latest     "./run_backend.sh"   backend     About a minute ago   Up About a minute (healthy)   0.0.0.0:3212->3210/tcp, 0.0.0.0:3213->3211/tcp
	# ai_image_edit-dashboard-1   ghcr.io/get-convex/convex-dashboard:latest   "node ./server.js"   dashboard   About a minute ago   Up About a minute             0.0.0.0:6792->6791/tcp
      "edit.infiniter.tech" = (SSL // {
        root = "/var/www/edit/";
        locations."/" = { tryFiles = "$uri /index.html"; };
        serverAliases = [ "www.edit.infiniter.tech" "edit.infiniter.tech" ];
      });

      "convex-edit.infiniter.tech" = (SSL // {
		      locations."/" = {
		      proxyPass = "http://127.0.0.1:3212";
		      extraConfig = ''
		      proxy_http_version 1.1;

		      proxy_set_header Upgrade $http_upgrade;
		      proxy_set_header Connection "upgrade";

		      proxy_set_header Host $host;
		      proxy_set_header X-Forwarded-Proto $scheme;
		      proxy_set_header X-Forwarded-For $remote_addr;
		      '';
		      };

		      serverAliases = [
		      "www.convex-edit.infiniter.tech"
		      ];
		      });
      "convex-site-edit.infiniter.tech" = (SSL // {
		      locations."/" = {
		      proxyPass = "http://127.0.0.1:3213";
		      extraConfig = ''
		      proxy_http_version 1.1;

		      proxy_set_header Upgrade $http_upgrade;
		      proxy_set_header Connection "upgrade";

		      proxy_set_header Host $host;
		      proxy_set_header X-Forwarded-Proto $scheme;
		      proxy_set_header X-Forwarded-For $remote_addr;
		      '';
		      };

		      serverAliases = [
		      "www.convex-site-edit.infiniter.tech"
		      ];
		      });
      "dashboard-edit.infiniter.tech" = (SSL // {
		      locations."/" = {
		      proxyPass = "http://127.0.0.1:6792";
		      extraConfig = ''
		      proxy_http_version 1.1;

		      proxy_set_header Upgrade $http_upgrade;
		      proxy_set_header Connection "upgrade";

		      proxy_set_header Host $host;
		      proxy_set_header X-Forwarded-Proto $scheme;
		      proxy_set_header X-Forwarded-For $remote_addr;
		      '';
		      };

		      serverAliases = [
		      "www.dashboard-edit.infiniter.tech"
		      ];
		      });

# }}}


      # "addyart.eu" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   listen = [
      #     { addr = "0.0.0.0"; port = 80; }
      #     { addr = "[::]"; port = 80; }
      #     { addr = "0.0.0.0"; port = 443; ssl = true; }
      #     { addr = "[::]"; port = 443; ssl = true; }
      #   ];
      #   locations."/".return = "301 https://app.addyart.eu$request_uri";
      #   serverAliases = [ "www.addyart.eu" ];
      # };








      "n8n.infiniter.tech" = (SSL // {
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
      });
    };

 fileSystems."/var/www/portfolio" = {
    device = "/home/infiniter/services/vite-portfolio/dist";
    options = [ "bind" "ro" ];
  };
 fileSystems."/var/www/gol" = {
    device = "/home/infiniter/services/convex_game_of_life/apps/web/dist";
    options = [ "bind" "ro" ];
  };
 fileSystems."/var/www/car" = {
    device = "/home/infiniter/services/browser-car/dist";
    options = [ "bind" "ro" ];
  };
 fileSystems."/var/www/edit" = {
    device = "/home/infiniter/services/ai_image_edit/apps/web/dist";
    options = [ "bind" "ro" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/www 0755 root root -"
    "d /var/www/portfolio 0755 nginx nginx -"
    "d /var/www/gol 0755 nginx nginx -"
    "d /var/www/car 0755 nginx nginx -"
    "d /var/www/edit 0755 nginx nginx -"
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
	  stdenv.cc.cc
	  openssl
  ];

  services.cron.enable = true;
  services.cron.systemCronJobs = [
	  "0 * * * * root mkdir -p /home/infiniter/services/shift-distributor/data/backups && cp /home/infiniter/services/shift-distributor/data/sqlite.db /home/infiniter/services/shift-distributor/data/backups/sqlite-$(date +\\%F-\\%R).db &> /tmp/heh.log"
  ];

  system.stateVersion = "24.11";
  }
