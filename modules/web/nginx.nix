{...}: {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."drive.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
