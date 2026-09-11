{pkgs, ...}: {
  imports = [./modules/services/websupport-ddns.nix];

  environment.systemPackages = [pkgs.t3code];

  systemd.services.t3code = {
    description = "T3 Code server";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    environment.HOME = "/home/infiniter";
    path = [pkgs.openssh "/run/current-system/sw" "/etc/profiles/per-user/infiniter"];
    serviceConfig = {
      User = "infiniter";
      WorkingDirectory = "/home/infiniter";
      ExecStart = "${pkgs.t3code}/bin/t3 serve --host 127.0.0.1 --port 3773";
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
