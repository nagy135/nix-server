# WoW arena on Hetzner

Production: https://wow.infiniter.tech

## Ownership and nixpi retirement

Hetzner (`91.99.204.136`, flake target `.#hetzner`) is the canonical runtime
and DNS owner. The 2026-11-11 audit found both already correct; no runtime,
database or DNS migration was needed or performed.

| Responsibility | Hetzner | nixpi |
| --- | --- | --- |
| Runtime | Nginx static releases, native `wow-api.service` (Node 24), coturn | None; no WoW container or system/user unit found in the audit |
| DNS | Websupport DDNS owns `wow` and `wow-api` | Owns neither record |
| Source | Deploy checkout `/home/infiniter/services/wow-browser` | Source-only checkout target `/home/infiniter/Code/wow-browser` |
| Durable data | `/var/lib/wow-api/leaderboard.sqlite` (profiles and leaderboard) | None |

At audit time the nixpi source directory existed but was empty, not a Git
checkout. Populate it from `https://github.com/nagy135/wow-browser` (`main`)
for source access only; cloning is separate from this infrastructure patch.
Do not run the deployment command, API, a container or a WoW unit from that
checkout. The requested container retirement was already satisfied by absence;
no container was stopped during this audit.

The authoritative Websupport A records for both names were `91.99.204.136`
with TTL 600; `wow` had no AAAA record. Keep both names out of nixpi's DDNS
record list. The host module asserts the configured hostname is `hetzner`
to prevent accidental import on another host.

## Deployment

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
Per-lobby reconnect tokens are ephemeral. Lobby voice uses the existing
host-provisioned `/var/lib/wow-voice/turn-secret`, shared with coturn through
systemd credentials. Preserve that secret and the SQLite database; neither
belongs in Git or a release directory. Existing releases are retained for
rollback.

Publish infrastructure changes to `nix-server`'s `master`, then pull the
published commit on each affected host and build there. For this ownership
documentation/assertion change, build without activation:

```sh
# In a clean checkout of the published commit on Hetzner:
sudo nixos-rebuild build --flake .#hetzner --no-write-lock-file
# On nixpi, after pulling master (including any source-only checkout work):
sudo nixos-rebuild build --flake .#nixpi --no-write-lock-file
```

Record the delivered commit and successful builds. Preserve unrelated local
changes; if a host checkout is dirty, build an exact clean committed checkout
on that host instead. Do not switch unrelated local configuration or secrets.
This patch needs no service restart, DDNS update or activation. For future
runtime configuration changes, activate the reviewed host configuration with
`nixos-rebuild switch` only when intended.

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
Inactive rooms expire. Profiles and leaderboard records persist in SQLite at
`/var/lib/wow-api/leaderboard.sqlite`, managed by systemd's `StateDirectory`.
Restarting the API or switching releases must retain that directory; a release
rollback does not roll back the database.

Health and release identity: `https://wow-api.infiniter.tech/health`. A first
infrastructure rollout skips API startup until the app release contains its
bundle; the subsequent app deployment starts it. For rollback, switch the static
release symlink and restart `wow-api.service` so API and client stay aligned.

## Verify ownership

After delivery, confirm the exact published commit with `git rev-parse HEAD`
in each host's infrastructure checkout and record the build result. On Hetzner,
check `systemctl is-active nginx wow-api coturn`, the
`/var/www/wow/current` symlink, and the API listener on `127.0.0.1:8787`.
Verify `https://wow.infiniter.tech/version.json` and
`https://wow-api.infiniter.tech/health` identify the expected game release,
then smoke-test the normal public HTTPS client/API flow.

Query Websupport's authoritative nameservers for both A records and check for
conflicting AAAA records; compare with the audited address above. Inspect the
evaluated DDNS record lists for both hosts to confirm Hetzner alone owns these
names. On nixpi, verify the source checkout's remote and branch, inspect
`docker ps -a` and system/user unit inventories for any WoW runtime, and keep
that checkout source-only. Do not read or print credential or database contents
as part of these checks.

## Administrator credentials

The gitignored `/home/infiniter/services/wow-browser/.env` in the game source
checkout holds `ADMIN_USERNAME` and `ADMIN_PASSWORD`. Keep it owned by
`infiniter:users`, mode `0600`. The service manager loads it through
`EnvironmentFile` before applying `ProtectHome`, so no home access exemption is
needed and secrets never enter immutable releases or the Nix store. Edit with
`vim ~/services/wow-browser/.env` as infiniter, then restart `wow-api.service`.
Do not replace it during deployment. Runtime session hashes and the leaderboard
stay in `/var/lib/wow-api`.
