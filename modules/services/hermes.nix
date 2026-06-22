{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.hermes-agent;
  hermesPackage = cfg.package.override {
    inherit (cfg) extraDependencyGroups extraPythonPackages;
  };
  ssl = {
    enableACME = true;
    forceSSL = true;
  };
in {
  services.hermes-agent = {
    enable = true;

    # Run Hermes directly as the dedicated `hermes` system user instead of
    # inside Docker, so it can reach host services/files normally.

    # Install the Hermes CLI into the system PATH.
    addToSystemPackages = true;

    # Enable Discord / messaging adapter dependencies.
    extraDependencyGroups = ["messaging" "web"];

    environmentFiles = [
      "/var/lib/hermes/env"
    ];

    settings = {
      model = {
        provider = "openai-codex";
        default = "gpt-5.5";
      };

      agent.reasoning_effort = "low";
      dashboard = {
        public_url = "https://agent.infiniter.tech";
        basic_auth.username = "infiniter";
      };
      toolsets = ["all"];

      terminal = {
        backend = "local";
        timeout = 180;
      };
    };
  };

  # Native Hermes is still sandboxed by systemd's ProtectSystem=strict in the
  # upstream module. Explicitly allow writes to the user's home.
  systemd.services.hermes-agent.serviceConfig.ReadWritePaths = [
    "/home/infiniter"
  ];

  # Give the dedicated `hermes` user POSIX ACL access to /home/infiniter.
  # The recursive ACL migration is expensive, so run it once. After that,
  # default ACLs on directories make newly-created files editable by both users.
  system.activationScripts.hermes-home-access = lib.stringAfter ["users"] ''
    if [ -d /home/infiniter ]; then
      mkdir -p ${cfg.stateDir}
      if [ ! -e ${cfg.stateDir}/.home-acls-initialized ]; then
        ${pkgs.acl}/bin/setfacl -R -m u:${cfg.user}:rwx /home/infiniter
        ${pkgs.findutils}/bin/find /home/infiniter -type d -exec ${pkgs.acl}/bin/setfacl -m d:u:${cfg.user}:rwx,d:u:infiniter:rwx {} +
        touch ${cfg.stateDir}/.home-acls-initialized
      else
        ${pkgs.acl}/bin/setfacl -m u:${cfg.user}:rwx,d:u:${cfg.user}:rwx,d:u:infiniter:rwx /home/infiniter
      fi
    fi
  '';

  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Dashboard";
    wantedBy = ["multi-user.target"];
    after = ["hermes-agent.service" "network-online.target"];
    wants = ["network-online.target"];
    requires = ["hermes-agent.service"];

    environment = {
      HOME = cfg.stateDir;
      HERMES_HOME = "${cfg.stateDir}/.hermes";
      HERMES_MANAGED = "true";
      MESSAGING_CWD = cfg.workingDirectory;
    };

    script = ''
      exec ${hermesPackage}/bin/hermes dashboard --host 0.0.0.0 --port 9119 --no-open
    '';

    serviceConfig = {
      Type = "simple";
      User = cfg.user;
      Group = cfg.group;
      WorkingDirectory = cfg.workingDirectory;
      UMask = "0007";
      Restart = "always";
      RestartSec = 5;
    };
  };

  services.nginx.virtualHosts."agent.infiniter.tech" =
    ssl
    // {
      locations."/" = {
        proxyPass = "http://127.0.0.1:9119";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
      serverAliases = [
        "www.agent.infiniter.tech"
      ];
    };
}
