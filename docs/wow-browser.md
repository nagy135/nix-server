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
then switches the release atomically. The bundled Node API runs as `wow-api.service`, bound to loopback port 8787 and
proxied with WebSocket upgrades at https://wow-api.infiniter.tech. The deploy
script restarts it after switching releases and verifies both release identities.
No persistent application secret is required: each player receives a random
per-lobby reconnect token. Existing releases are retained for rollback.

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

## Private multiplayer arenas

The same host module declares `wow-api.infiniter.tech`, its ACME certificate and
Websupport A record. `wow-api.service` runs Node 24 as `infiniter`, using the
bundled `/var/www/wow/current/api/server.mjs`. The API is not exposed directly
through the firewall. Production browser origins are restricted to
`https://wow.infiniter.tech`. HTTP writes and WebSocket messages have payload,
connection and rate limits. WebSocket ping/pong runs every 15 seconds.

The game creates invite-only two-player lobbies via the API. Both players confirm
after choosing their class and eight abilities, then a server-controlled
three-second countdown starts combat. The server runs the same combat engine at
50 Hz, without rival AI, and broadcasts state at 20 Hz. First to two round wins;
both players continue and pick again between rounds.

Lobbies and matches live in process memory. Restarting or deploying the API ends
current sessions; clients return to the lobby with an explanation. A disconnected
player has 30 seconds to reconnect while combat pauses, then forfeits the round.
Reconnect credentials stay in sessionStorage and never enter the invite URL.
Inactive rooms expire; this is a single-process service without account storage.

Health and release identity: `https://wow-api.infiniter.tech/health`. A first
infrastructure rollout skips API startup until the app release contains its
bundle; the subsequent app deployment starts it. For rollback, switch the static
release symlink and restart `wow-api.service` so API and client stay aligned.
