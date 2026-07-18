{...}: {
  boot.initrd.systemd.tpm2.enable = false;

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
