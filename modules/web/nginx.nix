{...}: {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

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

    # virtualHosts."drive.infiniter.tech" = {
    #   enableACME = true;
    #   forceSSL = true;
    # };
  };
}
