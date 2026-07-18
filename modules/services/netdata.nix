{
  config,
  lib,
  ...
}: let
  cfg = config.services.infiniter.netdata;
in {
  options.services.infiniter.netdata.enable = lib.mkEnableOption "Netdata system metrics dashboard";

  config = lib.mkIf cfg.enable {
    services.netdata.enable = true;

    networking.firewall.allowedTCPPorts = [19999];
  };
}
