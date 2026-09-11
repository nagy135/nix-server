{pkgs, t3code, codex, ...}: let
  # Public T3 Connect configuration shipped by the official t3 0.0.40 release.
  t3ConnectEnvironment = {
    T3CODE_RELAY_URL = "https://relay.t3.codes";
    T3CODE_CLERK_PUBLISHABLE_KEY = "pk_live_Y2xlcmsudDMuY29kZXMk";
    T3CODE_CLERK_CLI_OAUTH_CLIENT_ID = "hzxSgY2cH10sDU2r";
    T3CODE_CLOUDFLARED_PATH = "${pkgs.cloudflared}/bin/cloudflared";
  };
in {
  imports = [./modules/services/websupport-ddns.nix];

  environment.systemPackages = [t3code codex];
  environment.variables = t3ConnectEnvironment;

  systemd.services.t3code = {
    description = "T3 Code server";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    environment = t3ConnectEnvironment // {HOME = "/home/infiniter";};
    path = [pkgs.openssh "/run/current-system/sw" "/etc/profiles/per-user/infiniter"];
    serviceConfig = {
      User = "infiniter";
      WorkingDirectory = "/home/infiniter";
      ExecStart = "${t3code}/bin/t3 serve --host 127.0.0.1 --port 3773";
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
  };

  services.nginx.virtualHosts."t3code.infiniter.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3773";
      proxyWebsockets = true;
    };
  };

  boot.initrd.systemd.tpm2.enable = false;

  services.infiniter.systemStatus.enable = true;

  services.infiniter.websupportDDNS = {
    enable = true;
    zone = "infiniter.tech";
    records = [
      "bread"
      "fit"
      "fit-api"
      "pi-status"
      "t3code"
    ];
  };

  hardware.deviceTree.overlays = [
    {
      name = "nixpi-active-cooler";
      filter = "rpi-5-b.dtb";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "raspberrypi,5-model-b";

          fragment@0 {
            target = <&fan>;
            __overlay__ {
              status = "okay";
            };
          };

          fragment@1 {
            target = <&rp1_pwm1>;
            __overlay__ {
              status = "okay";
            };
          };
        };
      '';
    }
  ];
}
