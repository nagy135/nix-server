{pkgs, t3code, codex, ...}: {
  imports = [./modules/services/websupport-ddns.nix];

  # Use the existing OpenSSH service over Tailscale; enroll interactively once
  # with `sudo tailscale up --netfilter-mode=off`. No auth keys belong here.
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "none";
    # Keep NixOS in charge of filtering; SSH is already allowed. Tailscale's
    # default netfilter mode otherwise accepts all traffic on tailscale0.
    extraSetFlags = ["--netfilter-mode=off" "--ssh=false" "--accept-routes=false"];
  };

  environment.systemPackages = [t3code codex];

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
      # The Mac connects through an SSH forward over Tailscale.
      ExecStart = "${t3code}/bin/t3 serve --host 127.0.0.1 --port 3773";
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
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
