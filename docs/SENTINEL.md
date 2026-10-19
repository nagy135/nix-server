# Sentinel and fleet uptime on nixpi

`https://status.infiniter.tech` serves Sentinel's native system metrics dashboard.
The existing fleet availability dashboard is at `https://uptime.infiniter.tech`.
Both use nginx, ACME certificates, and the existing Websupport DDNS updater.

## Sentinel

- Source: `git@github.com:nagy135/sentinel.git`, branch `master`.
- Checkout: `/home/infiniter/services/sentinel`.
- Runtime: native Bun 1.4.2 pinned in `pkgs/sentinel-bun.nix`, `sentinel.service`, user `infiniter`.
- Listener: `127.0.0.1:13333`; nginx terminates HTTPS.
- Data: `/var/lib/sentinel/metrics.sqlite`, with SQLite WAL files, managed by `StateDirectory`.
- Sampling: `SENTINEL_INTERVAL_MS=5000`, retaining all history.

The native process reads nixpi's actual system information. No container is used
for Sentinel. Authentication is deferred for this first deployment.

Update from a published commit, build on nixpi, then restart:

```sh
# As infiniter on nixpi:
cd ~/services/sentinel
git pull --ff-only origin master
bun install --frozen-lockfile
bun run build
bun run typecheck
bun test
# As root on nixpi:
systemctl restart sentinel
systemctl status sentinel --no-pager
curl -fsS http://127.0.0.1:13333/api/metrics
```

Check the API's `host.hostname`, recent `latest.timestamp`, and growing
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

Verify both public HTTPS URLs, Sentinel's `/api/metrics`, and uptime's
`/api/health` and `/api/status` after DNS/certificate issuance completes.
