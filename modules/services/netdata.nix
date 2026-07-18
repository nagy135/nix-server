{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.infiniter.netdata;
in {
  options.services.infiniter.netdata.enable = lib.mkEnableOption "Netdata system metrics dashboard";

  config = lib.mkIf cfg.enable {
    services.netdata = {
      enable = true;
      package = pkgs.netdata.override {withCloudUi = true;};
    };

    services.nginx.virtualHosts."pi-status.infiniter.tech" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:19999";
        proxyWebsockets = true;
      };
    };
  };
}
