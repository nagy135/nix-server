# Wiki Around Me on nixpi

Production: https://wiki.infiniter.tech

TanStack Start's compiled Node server runs as `wiki-around-me.service` on
`127.0.0.1:13008`, behind Nginx. The NixOS module declares the service, ACME
certificate, Websupport dynamic DNS record, and release directory permissions.
Node 24 comes from the pinned nixpkgs configuration.

- Source: https://github.com/nagy135/wiki-around-me (private)
- Checkout: `/home/infiniter/services/wiki-around-me`, branch `main`
- Compiled releases: `/var/www/wiki/releases/<commit>-<timestamp>`
- Active release: `/var/www/wiki/current`
- Infrastructure: `modules/services/wiki-around-me.nix`, imported by nixpi

For app updates, run `npm run deploy` in its Mac checkout with a clean committed
working tree. The script pushes `main`, pulls it on nixpi using the existing
GitHub SSH access, installs the lockfile, tests and builds on nixpi, copies the
compiled `.output` into a release, atomically switches `current`, and restarts
the service. It uses `infiniter` for source/builds and root only for service
administration. Previous releases are retained for rollback.

The app uses public OpenStreetMap tiles, Wikimedia APIs, and a single-process
Nominatim search limiter/cache. It needs no application secret. Do not add
replicas against the public geocoder without sharing its application-wide
limiter or changing geocoder providers. Map attribution remains visible.

For infrastructure changes, commit and push `master`, pull it in `/etc/nixos`
as root, then run `nixos-rebuild switch --flake /etc/nixos#nixpi` on nixpi without
updating the lockfile. Start `websupport-ddns.service` to publish DNS immediately.
On first deployment, certificate issuance may need a retry after DNS propagates:
`systemctl restart acme-order-renew-wiki.infiniter.tech.service`.

Check status with `systemctl status wiki-around-me nginx` and app logs with
`journalctl -u wiki-around-me`. For rollback, atomically point `current` at a
previous release and restart `wiki-around-me.service`.
