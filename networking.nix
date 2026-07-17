{...}: {
  networking = {
    useDHCP = true;
    firewall.allowedTCPPorts = [80 443];
  };
}
