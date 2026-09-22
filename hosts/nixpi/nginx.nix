{...}: {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Started manually with Docker Compose in ~/services/file-relay.
    virtualHosts."relay.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:13006";
        extraConfig = ''
          # The app enforces 200 MB per file; allow multipart overhead here.
          client_max_body_size 201m;
          client_body_timeout 1800s;
          proxy_request_buffering off;
          proxy_read_timeout 1800s;
          proxy_send_timeout 1800s;
        '';
      };
    };

    virtualHosts."conversation.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:13005";
      };
    };

    virtualHosts."speech.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:13004";
      };
    };

    virtualHosts."bread.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:16001";
        proxyWebsockets = true;
      };
    };

    virtualHosts."fit.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:13003";
        proxyWebsockets = true;
      };

      locations."/api/" = {
        proxyPass = "http://127.0.0.1:18080/";
      };
    };

    virtualHosts."fit-api.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:18080";
      };
    };

    # virtualHosts."drive.infiniter.tech" = {
    #   enableACME = true;
    #   forceSSL = true;
    # };
  };
}
