# WoW arena on Hetzner

Production: https://wow.infiniter.tech

This Vite/Three.js game is served as static files by Nginx. The host module
`modules/services/wow-browser.nix` declares its HTTPS virtual host, ACME
certificate, Websupport A record and release-directory ownership. It is imported
only by `hosts/hetzner/default.nix`.

- Source: https://github.com/nagy135/wow-browser, branch `main`
- Checkout: `/home/infiniter/services/wow-browser`
- Releases: `/var/www/wow/releases/<commit>-<timestamp>`
- Served symlink: `/var/www/wow/current`
- Release identity: `https://wow.infiniter.tech/version.json`

Run `npm run deploy` in a clean, committed Mac game checkout. Its deployment
script pushes `main`, pulls that exact revision on Hetzner as `infiniter`, runs
`npm ci`, native-model validation, logic tests and the production build there,
then switches the release atomically. Node is needed for builds only. The game
has no backend or application secret. Existing releases are retained so rollback
requires only replacing the served symlink.

Publish infrastructure changes to `nix-server`'s `master`, pull them in
`/etc/nixos` on Hetzner and run:

```sh
nixos-rebuild switch --flake /etc/nixos#hetzner
systemctl start websupport-ddns.service
```

If the first ACME order runs before DNS propagates, retry
`acme-order-renew-wow.infiniter.tech.service` after the A record resolves to
`91.99.204.136`. Do not update the flake lockfile just to deploy the game.

Only fingerprinted `/assets/` bundles have immutable caching. Other assets,
including models, icons, HTML and release metadata, revalidate on subsequent
requests. Missing paths return 404 instead of the application HTML.
