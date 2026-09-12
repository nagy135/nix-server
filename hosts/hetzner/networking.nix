{lib, ...}: {
  # Hetzner routes the public /32 through an off-subnet gateway. Associate it
  # with eth0 explicitly so the interface service installs the default route.
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = {
      address = "172.31.1.1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "91.99.204.136";
            prefixLength = 32;
          }
        ];
        ipv4.routes = [
          {
            address = "172.31.1.1";
            prefixLength = 32;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="92:00:06:df:ae:47", NAME="eth0"

  '';
}
