{pkgs, ...}: {
  # Build the pinned application checkout in ~/services/agent-office with npm ci.
  # Runtime state (including the password hash) stays in ~/agent-office.
  systemd.services.agent-office = {
    description = "Agent Office";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    environment = {
      HOME = "/home/infiniter";
      SHELL = "/run/current-system/sw/bin/zsh";
    };
    path = [pkgs.nodejs_24 pkgs.git pkgs.gh pkgs.openssh pkgs.bash pkgs.coreutils "/run/current-system/sw" "/etc/profiles/per-user/infiniter"];
    serviceConfig = {
      User = "infiniter";
      WorkingDirectory = "/home/infiniter";
      ExecStart = "${pkgs.nodejs_24}/bin/node /home/infiniter/services/agent-office/bin/agent-office.js --home /home/infiniter/agent-office --host 127.0.0.1 --port 4600 --trust-proxy";
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
  };

  environment.systemPackages = [pkgs.gh];
  services.nginx.virtualHosts."office.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:4600";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
      '';
    };
  };
  services.infiniter.websupportDDNS.records = ["office"];
}
