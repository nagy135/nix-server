{
  projectPaths,
  domain ? "infiniter.tech",
  authDomain ? "auth.${domain}",
  basePort ? 4096,
  opencodePkg,
  githubClientIDFile ? "/etc/nixos/secrets/opencode-github-client-id",
  githubClientSecretFile ? "/etc/nixos/secrets/opencode-github-client-secret",
  cookieSecretFile ? "/etc/nixos/secrets/opencode-oauth2-cookie-secret",
  createUser ? true,
  user ? "opencode",
  group ? "opencode",
  home ? "/var/lib/opencode",
  gitUserName ? "OpenCode",
  gitUserEmail ? "opencode@infiniter.tech",
}: {
  lib,
  pkgs,
  ...
}: let
  normalizedCookieSecretFile = "/run/oauth2-proxy/cookie-secret";
  clientEnvironmentFile = "/run/oauth2-proxy/client-id.env";
  oauth2ProxyAddress = "http://127.0.0.1:4180";
  opencodeInstructionsPath = "/etc/opencode-service-instructions.md";
  opencodeConfigPath = "/etc/opencode-service-config.json";
  mkProject = index: path: let
    normalizedPath = lib.removeSuffix "/" path;
    name = lib.last (lib.splitString "/" normalizedPath);
    port = basePort + index;
    serviceName = "opencode-${name}";
    host = "edit-${name}.${domain}";
  in {
    systemd.services.${serviceName} = {
      description = "OpenCode for ${normalizedPath}";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        HOME = home;
        GIT_CONFIG_GLOBAL = "/etc/opencode-gitconfig";
        OPENCODE_CONFIG = opencodeConfigPath;
      };

      path = with pkgs; [
        git
        openssh
        bash
        coreutils
        ripgrep
        fd
        fzf
      ];

      serviceConfig =
        {
          Type = "simple";
          User = user;
          WorkingDirectory = normalizedPath;
          Restart = "on-failure";
          RestartSec = 5;
          StateDirectory = serviceName;
        }
        // lib.optionalAttrs (group != null) {
          Group = group;
        };

      script = ''
        # Optional future deploy key wiring:
        # export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /run/secrets/opencode-deploy-key -o IdentitiesOnly=yes"

        exec ${opencodePkg}/bin/opencode web \
          --hostname 0.0.0.0 \
          --port ${toString port}
      '';
    };

    services.nginx.virtualHosts.${host} = {
      enableACME = true;
      forceSSL = true;

      locations."= /oauth2/auth" = {
        proxyPass = "${oauth2ProxyAddress}/oauth2/auth";
        extraConfig = ''
          internal;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
        '';
      };

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          auth_request /oauth2/auth;
          error_page 401 =302 https://${authDomain}/oauth2/start?rd=$scheme://$host$request_uri;

          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Port $server_port;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  generated = lib.imap0 mkProject projectPaths;
in
  lib.mkMerge (
    [
      {
        services.oauth2-proxy = {
          enable = true;
          provider = "github";
          reverseProxy = true;
          trustedProxyIP = ["127.0.0.1" "::1"];
          setXauthrequest = true;
          httpAddress = oauth2ProxyAddress;
          redirectURL = "https://${authDomain}/oauth2/callback";
          keyFile = clientEnvironmentFile;
          clientSecretFile = githubClientSecretFile;
          email.domains = ["*"];
          extraConfig = {
            upstream = ["static://202"];
            "cookie-domain" = ".${domain}";
            "whitelist-domain" = ".${domain}";
            "github-user" = "nagy135";
            "cookie-secret-file" = normalizedCookieSecretFile;
          };
        };

        # NixOS now loads OAuth secrets at runtime. Keep the existing URL-safe
        # base64 normalization without embedding secrets in the generated service configuration.
        systemd.services.oauth2-proxy = {
          serviceConfig = {
            RuntimeDirectory = "oauth2-proxy";
            RuntimeDirectoryMode = "0700";
            LoadCredential = [
              "client-id:${githubClientIDFile}"
              "cookie-secret-raw:${cookieSecretFile}"
            ];
            # The file is created by ExecStartPre and loaded for ExecStart.
            EnvironmentFile = lib.mkForce ["-${clientEnvironmentFile}"];
          };
          preStart = ''
            umask 077
            ${pkgs.coreutils}/bin/tr '+/' '-_' < "$CREDENTIALS_DIRECTORY/cookie-secret-raw" \
              | ${pkgs.coreutils}/bin/tr -d '=\r\n' > ${normalizedCookieSecretFile}
            client_id=$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/client-id")
            [[ "$client_id" =~ ^[a-zA-Z0-9._-]+$ ]] || { echo "Invalid GitHub OAuth client ID" >&2; exit 1; }
            printf 'OAUTH2_PROXY_CLIENT_ID=%s\n' "$client_id" > ${clientEnvironmentFile}
          '';
        };

        services.nginx.virtualHosts.${authDomain} = {
          enableACME = true;
          forceSSL = true;

          locations."/oauth2/" = {
            proxyPass = oauth2ProxyAddress;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };

          locations."/".extraConfig = ''
            return 404;
          '';
        };

        environment.etc."opencode-gitconfig".text = ''
          [user]
            name = ${gitUserName}
            email = ${gitUserEmail}
        '';

        environment.etc."opencode-service-instructions.md".text = ''
          You are editing a live deployed codebase on a NixOS machine.

          After you make code changes, deploy them so the result can be checked in the browser.

          Do not create git commits or push changes unless explicitly asked.

          When asked to commit, create the commit and push it.
        '';

        environment.etc."opencode-service-config.json".text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";
          instructions = [opencodeInstructionsPath];
        };
      }
      (lib.mkIf createUser {
        users.groups.${group} = {};

        users.users.${user} = {
          isSystemUser = true;
          group = group;
          home = home;
          createHome = true;
        };
      })
    ]
    ++ generated
  )
