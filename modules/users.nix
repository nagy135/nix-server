{
  inputs,
  pkgs,
  ...
}: let
  sshKeys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7XoDHd8Pi5tylzVnjKvKoM+5GzT7Pcuk2PfWOsGEu7''
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnmNqABy0voX/rDdThGadpR5ZSF6NWJ2oWaGJvRJWF4H1PZHVJr/BSl/s7zQM5Tp4PH34+g8CNZAaFFP5aThGDv22cIAlZneM5t5HL0iHiN9/L9e9W3U7ySLDYdRls0QBnURUInNh8pK6IqqJTg8LDx6kfxOBhJyPtlLFhxqWtJSYTjm17B/tU8bvtslbg97Q1ck89VVX1g++2YCjOGhZv0HKp7X3F6RvTlJolYxUwvZ4qPdx2eXSWgSLAYJc7aDlJLdqEqPqA1senvcIYam+cWkxqnmEobIhmc4oDSnLO/Yf5vRANP/tw7VPgf9kxnXa7OEhbEt++Uts+FidZZC/xFnT9x2Rp8I/5MGLn52y5QPmSm3KTPSxBkFuzLA93opjOIiijov5EECZhtsWWN4z97rSeBu11OMXcbTKPTPCjOWxylDW83xFx6gl6/lmu5UirbRGqoOlzOoV2hrLy/MlOXX9lDU5LtlZShId4hbzt/lkctv7AcnE9QTSU/8651d8= infiniter@infiniter''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGB6YkzqRa0xmB3kS9mN6E9beWBsBVHduOgDM51BtR4 Viktor@Viktor-Mac.local''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGm0dwd4tY0KSWNZ05glOkJ7Qu8SxLVF4wiBY+9xjuSb nix-on-droid@localhost''
  ];
in {
  programs.ssh.startAgent = true;

  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  users.users.infiniter = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "docker" "video" "podman" "jellyfin"];
    openssh.authorizedKeys.keys = sshKeys;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "infiniter" = import ../home.nix;
    };
  };
}
