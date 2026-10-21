{lib, ...}: {
  options.services.infiniter.fleet.disabledVirtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = {};
    description = ''
      Retained nginx virtual host definitions for intentionally disabled applications.
      These are listed as Disabled by the fleet dashboard and are not installed in nginx.
    '';
  };
}
