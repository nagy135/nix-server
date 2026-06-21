{pkgs, ...}: {
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
}
