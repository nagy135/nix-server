{pkgs, ...}: let
  apiDomain = "fitness-ai.infiniter.tech";
  authDomain = "fitness-ai-auth.infiniter.tech";
  stateDir = "/var/lib/fitness-ai";
in {
  # Generate the instance secret on the server, outside Git and the Nix store.
  systemd.services.fitness-ai-secrets = {
    description = "Initialize Fitness AI Convex instance credentials";
    before = ["docker-fitness-ai-convex.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "fitness-ai";
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
    script = ''
      if [ ! -f ${stateDir}/backend.env ]; then
        printf 'INSTANCE_NAME=fitness-ai\nINSTANCE_SECRET=%s\n' \
          "$(${pkgs.openssl}/bin/openssl rand -hex 32)" > ${stateDir}/backend.env.tmp
        mv ${stateDir}/backend.env.tmp ${stateDir}/backend.env
      fi
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.fitness-ai-convex = {
      # ARM64 image pinned for reproducible nixpi deployments.
      image = "ghcr.io/get-convex/convex-backend@sha256:ca2c9a62465f259ff55448ef246fa30bd9148fbce76c545131dbb44a943f5356";
      ports = ["127.0.0.1:13210:3210" "127.0.0.1:13211:3211"];
      volumes = ["fitness-ai-convex-data:/convex/data"];
      environmentFiles = ["${stateDir}/backend.env"];
      environment = {
        CONVEX_CLOUD_ORIGIN = "https://${apiDomain}";
        CONVEX_SITE_ORIGIN = "https://${authDomain}";
        DISABLE_METRICS_ENDPOINT = "true";
        APPLICATION_MAX_CONCURRENT_MUTATIONS = "16";
        APPLICATION_MAX_CONCURRENT_NODE_ACTIONS = "16";
        APPLICATION_MAX_CONCURRENT_QUERIES = "16";
        APPLICATION_MAX_CONCURRENT_V8_ACTIONS = "16";
        RUST_LOG = "info";
      };
      extraOptions = [
        "--stop-signal=SIGINT"
        "--stop-timeout=10"
        "--health-cmd=curl -fsS http://localhost:3210/version || exit 1"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-start-period=30s"
        "--health-retries=5"
      ];
    };
  };

  systemd.services.docker-fitness-ai-convex = {
    requires = ["fitness-ai-secrets.service"];
    after = ["fitness-ai-secrets.service"];
  };

  services.nginx.virtualHosts = {
    ${apiDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:13210";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
          client_max_body_size 128m;
        '';
      };
    };
    ${authDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:13211";
        extraConfig = "proxy_read_timeout 120s;";
      };
    };
  };

  services.infiniter.websupportDDNS.records = ["fitness-ai" "fitness-ai-auth"];
}
