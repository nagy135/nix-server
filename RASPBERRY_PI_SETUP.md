# Raspberry Pi Nextcloud setup

This configuration targets a Raspberry Pi 5 running NixOS. It serves Nextcloud
at `https://drive.infiniter.tech` and stores Nextcloud files on the Pi's internal
NixOS storage under `/var/lib/nextcloud`.

## 1. Prepare the network

1. Connect the Pi to the router with Ethernet.
2. In the router, reserve a fixed DHCP address for the Pi's Ethernet MAC
   address.
3. Point the DNS `A` record for `drive.infiniter.tech` to the router's public
   IPv4 address.
4. Forward TCP ports 80 and 443 from the router to the Pi's reserved address.

Both ports are required: port 80 is used for ACME certificate issuance and
redirects, while Nextcloud is served over port 443. This requires a public IP;
inbound forwarding will not work behind carrier-grade NAT.

## 2. Activate the configuration

The standard NixOS SD image labels its root partition `NIXOS_SD`. Confirm that
the running installation uses that label:

```console
findmnt -no LABEL /
```

From this repository on the Pi, activate the flake:

```console
sudo nixos-rebuild switch --flake .#raspberry-pi
```

The first activation creates the PostgreSQL database, Redis instance, TLS
certificate, and a random Nextcloud administrator password. Read it with:

```console
sudo cat /var/lib/nextcloud-admin-pass
```

Log in at `https://drive.infiniter.tech` with user `admin` and that password,
then change the password in Nextcloud.

## 3. Verify the services

```console
systemctl status nextcloud-setup.service php-fpm-nextcloud.service nginx.service
sudo nextcloud-occ status
```

Internal storage is not a backup. Back up `/var/lib/nextcloud` and the PostgreSQL
database to a separate device or remote system before relying on the service for
important files.
