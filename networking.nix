{...}: {
  networking = {
    hostName = "nextcloud-pi";
    useDHCP = true;
    firewall.allowedTCPPorts = [80 443];
  };
}
