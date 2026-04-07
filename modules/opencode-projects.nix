{ projectPaths
, domain ? "infiniter.tech"
, basePort ? 4096
, opencodePkg
, serverPasswordFile
, createUser ? true
, user ? "opencode"
, group ? "opencode"
, home ? "/var/lib/opencode"
, gitUserName ? "OpenCode"
, gitUserEmail ? "opencode@infiniter.tech"
}:
{ lib, pkgs, ... }:

let
  mkProject = index: path:
    let
      normalizedPath = lib.removeSuffix "/" path;
      name = lib.last (lib.splitString "/" normalizedPath);
      port = basePort + index;
      serviceName = "opencode-${name}";
      host = "${name}.${domain}";
    in
    {
      systemd.services.${serviceName} = {
        description = "OpenCode for ${normalizedPath}";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

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

        serviceConfig = {
          Type = "simple";
          User = user;
          WorkingDirectory = normalizedPath;
          Restart = "on-failure";
          RestartSec = 5;
          StateDirectory = serviceName;
        } // lib.optionalAttrs (group != null) {
          Group = group;
        };

        script = ''
          export OPENCODE_SERVER_PASSWORD="$(< ${serverPasswordFile})"

          # Optional future deploy key wiring:
          # export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /run/secrets/opencode-deploy-key -o IdentitiesOnly=yes"

          exec ${opencodePkg}/bin/opencode web \
            --hostname 127.0.0.1 \
            --port ${toString port}
        '';
      };

      services.nginx.virtualHosts.${host} = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
          '';
        };
      };
    };

  generated = lib.imap0 mkProject projectPaths;
in
lib.mkMerge (
  [
    {
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
