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

    # virtualHosts."drive.infiniter.tech" = {
    #   enableACME = true;
    #   forceSSL = true;
    # };
  };
}
