{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "206.189.48.1";
    defaultGateway6 = {
      address = "";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="206.189.62.232"; prefixLength=20; }
{ address="10.19.0.5"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="fe80::c887:44ff:feb9:1a80"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "206.189.48.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = ""; prefixLength = 128; } ];
      };
            eth1 = {
        ipv4.addresses = [
          { address="10.114.0.2"; prefixLength=20; }
        ];
        ipv6.addresses = [
          { address="fe80::9079:4aff:fe8f:f585"; prefixLength=64; }
        ];
        };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="ca:87:44:b9:1a:80", NAME="eth0"
    ATTR{address}=="92:79:4a:8f:f5:85", NAME="eth1"
  '';
}
