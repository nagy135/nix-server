{pkgs, ...}: let
  ssl = {
    enableACME = true;
    forceSSL = true;
  };
in {
  services.hermes-agent = {
    enable = true;

    # Run Hermes inside its managed container.
    container.enable = true;

    # Allow the normal server user to access the shared Hermes state.
    container.hostUsers = ["infiniter"];

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

  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Dashboard";
    wantedBy = ["multi-user.target"];
    after = ["hermes-agent.service" "docker.service" "network-online.target"];
    wants = ["network-online.target"];
    requires = ["hermes-agent.service" "docker.service"];

    script = ''
      set -euo pipefail

      for _ in $(${pkgs.coreutils}/bin/seq 1 60); do
        if ${pkgs.docker}/bin/docker inspect -f '{{.State.Running}}' hermes-agent 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q true; then
          break
        fi
        sleep 1
      done

      if ! ${pkgs.docker}/bin/docker inspect -f '{{.State.Running}}' hermes-agent 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q true; then
        echo "hermes-agent container is not running" >&2
        exit 1
      fi

      exec ${pkgs.docker}/bin/docker exec -i \
        --user "$(${pkgs.coreutils}/bin/id -u hermes):$(${pkgs.coreutils}/bin/id -g hermes)" \
        --env HERMES_HOME=/data/.hermes \
        --env HERMES_MANAGED=true \
        --env HOME=/home/hermes \
        --env MESSAGING_CWD=/data/workspace \
        hermes-agent \
        /data/current-package/bin/hermes dashboard --host 0.0.0.0 --port 9119 --no-open
    '';

    serviceConfig = {
      Type = "simple";
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
