# Guitar scales on nixpi

Production: https://guitar.infiniter.tech

The React/Vite application is served as static files by Nginx. The nixpi modules
declare the virtual host, ACME certificate, Websupport dynamic DNS record, and
release directory ownership.

- Source: https://github.com/nagy135/guitar-scales, branch `main`
- Checkout: `/home/infiniter/services/guitar-scales`
- Releases: `/var/www/guitar/releases/<commit>-<timestamp>`
- Served symlink: `/var/www/guitar/current`

Run `npm run deploy` in a clean, committed Mac checkout. The deployment pushes
`main` to GitHub, pulls that commit on nixpi, installs locked dependencies, tests,
builds there, and atomically switches the static release. Source and builds are
owned by `infiniter`; no Node or Vite process runs in production. Previous
releases remain available for rollback by replacing the `current` symlink.

After publishing infrastructure changes to `master`, pull them in `/etc/nixos`
and run `nixos-rebuild switch --flake /etc/nixos#nixpi` on nixpi without updating
the lockfile. Start `websupport-ddns.service` to publish DNS immediately. On a
first deployment, wait for DNS to resolve to nixpi before retrying
`acme-order-renew-guitar.infiniter.tech.service` if certificate issuance fails.
