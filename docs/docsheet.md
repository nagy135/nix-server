# Docsheet on nixpi

Production: https://docsheet.infiniter.tech

The React application is served as static files by Nginx, using the same release
layout as `fish.infiniter.tech`. The virtual host, ACME certificate, Websupport
dynamic DNS record, and directory permissions are declared in the nixpi modules.

- Source checkout: `/home/infiniter/services/medical-cheatsheet`
- Release directories: `/var/www/docsheet/releases/<commit>-<timestamp>`
- Served symlink: `/var/www/docsheet/current`
- Application repository: https://github.com/nagy135/medical-cheatsheet

After committing application changes, run `npm run deploy` in its Mac checkout.
The deployment script tests and builds the application, pushes committed source
over SSH, uploads `dist`, and atomically switches the served release. The Pi's
checkout uses `receive.denyCurrentBranch=updateInstead` and retains its GitHub
origin. No Node.js service or Vite server is needed in production.

Nginx revalidates HTML and caches hashed assets for one year. Existing releases
remain available for rollback by atomically changing the `current` symlink.

For infrastructure changes, rebuild `.#nixpi` without updating `flake.lock`.
Run `systemctl start websupport-ddns.service` to update DNS immediately. On a first
deployment, allow DNS to resolve to nixpi before retrying
`acme-order-renew-docsheet.infiniter.tech.service` if certificate issuance fails.
