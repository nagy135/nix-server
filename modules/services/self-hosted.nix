{pkgs, ...}: let
  adminPasswordFile = "/var/lib/nextcloud-admin-pass";
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "drive.infiniter.tech";
    https = true;
    maxUploadSize = "10G";
    database.createLocally = true;
    configureRedis = true;

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = adminPasswordFile;
    };

    settings = {
      default_phone_region = "CH";
      maintenance_window_start = 2;
    };
  };

  # Generate the one-time initial admin password on the host, never in the Nix store.
  systemd.services.nextcloud-admin-password = {
    description = "Generate the initial Nextcloud administrator password";
    requiredBy = ["nextcloud-setup.service"];
    before = ["nextcloud-setup.service"];
    serviceConfig.Type = "oneshot";
    script = ''
      if [[ ! -s ${adminPasswordFile} ]]; then
        umask 077
        ${pkgs.openssl}/bin/openssl rand -base64 32 > ${adminPasswordFile}
      fi
    '';
  };
}
