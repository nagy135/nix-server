{
  projectPaths,
  domain ? "infiniter.tech",
  authDomain ? "auth.${domain}",
  basePort ? 4096,
  opencodePkg,
  githubClientIDFile ? ../secrets/opencode-github-client-id,
  githubClientSecretFile ? ../secrets/opencode-github-client-secret,
  cookieSecretFile ? ../secrets/opencode-oauth2-cookie-secret,
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
  readSecret = path: lib.removeSuffix "\n" (builtins.readFile path);
  githubClientID = readSecret githubClientIDFile;
  githubClientSecret = readSecret githubClientSecretFile;
  cookieSecret = readSecret cookieSecretFile;
  oauth2ProxyAddress = "http://127.0.0.1:4180";
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
          proxy_set_header X-Auth-Request-Redirect $scheme://$host$escaped_request_uri;
        '';
      };

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          auth_request /oauth2/auth;
          error_page 401 =302 https://${authDomain}/oauth2/start?rd=$scheme://$host$escaped_request_uri;

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
          setXauthrequest = true;
          httpAddress = oauth2ProxyAddress;
          redirectURL = "https://${authDomain}/oauth2/callback";
          clientID = githubClientID;
          clientSecret = githubClientSecret;
          cookie.secret = cookieSecret;
          email.domains = ["*"];
          extraConfig = {
            upstreams = ["static://202"];
            "cookie-domain" = ".${domain}";
            "whitelist-domain" = ".${domain}";
          };
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
