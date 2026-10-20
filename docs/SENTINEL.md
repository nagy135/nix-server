# Sentinel and fleet uptime

`https://status.infiniter.tech` serves Sentinel's native system metrics dashboard.
The existing fleet availability dashboard is at `https://uptime.infiniter.tech`.
`https://hetzner-status.infiniter.tech` serves Hetzner's native Sentinel instance.
All three dashboards use nginx, ACME certificates, and the Websupport DDNS updater.

## Sentinel

- Source: `git@github.com:nagy135/sentinel.git`, branch `master`.
- Checkout: `/home/infiniter/services/sentinel`.
- Runtime: native Bun 1.4.2 (ARM64 on nixpi, x86_64 on Hetzner) pinned in `pkgs/sentinel-bun.nix`, `sentinel.service`, user `infiniter`.
- Listener: `127.0.0.1:13333`; nginx terminates HTTPS.
- Data: `/var/lib/sentinel/metrics.sqlite`, with SQLite WAL files, managed by `StateDirectory`.
- Sampling: `SENTINEL_INTERVAL_MS=5000`, retaining all history.

Each native process reads its own host's actual system information. No container
is used for Sentinel. The dashboard and metrics API require login; `/healthz`
reports service health without authentication.

Both hosts load the same login from `/etc/sentinel/credentials.env` (root:root,
mode `0600`), containing `SENTINEL_USERNAME` and `SENTINEL_PASSWORD`. Keep this file
outside Git and the Nix store. Sessions are stored separately on each host in
`/var/lib/sentinel/metrics.sqlite.auth.sqlite`.

The Hetzner hostname is configured through `services.infiniter.sentinel.domain`.
Importing Sentinel also adds its hostname to the local Websupport DNS updater's
records. Both hosts run that updater on boot and every five minutes, using
`/var/lib/websupport-ddns/credentials.env` (root:root, mode `0600`). Hetzner manages
only `hetzner-status`; nixpi continues to manage `status` and its other records.
Each updater sets its records to that machine's public IPv4 address. Credentials
are provisioned privately on each host; Nix contains no API keys or passwords.

Update from a published commit, build on the target host, then restart:

```sh
# As infiniter on nixpi or Hetzner:
cd ~/services/sentinel
git pull --ff-only origin master
bun install --frozen-lockfile
bun run build
bun run typecheck
bun test
# As root on the same host:
systemctl restart sentinel
systemctl status sentinel --no-pager
curl -fsS http://127.0.0.1:13333/healthz
```

After signing in, check the API's `host.hostname`, recent `latest.timestamp`, and growing
`storage.count`. The database is outside the checkout and survives rebuilds and
service restarts. Local development remains `bun run dev`, listening on localhost.

## Fleet uptime migration

The uptime container stays on `127.0.0.1:13332` with its existing persistent data
under `/var/lib/uptime-dashboard`. Only its HTTPS hostname and self-monitor URL
move. The monitor's existing ID is retained so its availability history continues.
The source repository is `nagy135/uptime_dashboard`, branch `main`.

When changing its inventory, build the published application on nixpi, install
`deploy/observers/nixpi.sh` as `/var/lib/fleet-observer/check.sh`, install
`deploy/fleet.json` as `/var/lib/uptime-dashboard/fleet.json`, and restart
`docker-uptime-dashboard`. Observer scripts for unchanged devices stay untouched.

Apply Nix configuration from the published `nix-server` master branch on nixpi:

```sh
cd /etc/nixos
git pull --ff-only origin master
nixos-rebuild switch --flake .#nixpi
systemctl start websupport-ddns
```

For Hetzner, use `nixos-rebuild switch --flake .#hetzner` on that host and start its
`websupport-ddns` service. Verify both Sentinel HTTPS URLs and their `/healthz`
endpoints, authenticated `/api/metrics`, and uptime's `/api/health` and
`/api/status` after DNS/certificate issuance completes.
