{config, ...}: {
  # PAM displays the host's banner after a successful interactive login.
  users.motd = builtins.readFile (../../assets/motd + "/${config.networking.hostName}.txt");
}
