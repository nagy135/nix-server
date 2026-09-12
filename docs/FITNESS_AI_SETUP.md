# Fitness AI on nixpi

`modules/services/fitness-ai.nix`, imported only by `hosts/nixpi/default.nix`, runs the
Fitness AI Convex backend with a pinned ARM64 Docker image.

- API/WebSocket endpoint: `https://fitness-ai.infiniter.tech`
- HTTP actions and Better Auth: `https://fitness-ai-auth.infiniter.tech`
- Container: `fitness-ai-convex`
- Persistent Docker volume: `fitness-ai-convex-data`
- Instance credentials: `/var/lib/fitness-ai/backend.env` (root-only,
  generated on first start, never in Git or the Nix store)

The existing Websupport DDNS service publishes both DNS records. nginx handles
HTTPS with ACME and proxies to loopback ports 13210 and 13211. No dashboard or
raw Docker port is exposed publicly.

## Apply and check

```sh
cd /etc/nixos
git pull --ff-only
nixos-rebuild switch --flake .#nixpi --no-write-lock-file
systemctl start websupport-ddns
systemctl status docker-fitness-ai-convex
curl -fsS https://fitness-ai.infiniter.tech/version
```

On the first deployment, DNS must resolve to the Pi before ACME can issue the
certificates. Retry the two `acme-fitness-ai*.infiniter.tech` services if DNS
propagation delayed initial issuance.

## Deploy application functions

Infrastructure activation starts Convex; application functions are deployed
separately from the Fitness AI repository using `scripts/convex-self-hosted.sh`.
Generate an admin key with `docker exec fitness-ai-convex ./generate_admin_key.sh`
and save it in that repository's ignored `.env.production.local` alongside
`CONVEX_SELF_HOSTED_URL=https://fitness-ai.infiniter.tech`. Treat it as a secret.

```sh
CONVEX_ENV_FILE=.env.production.local nix develop -c ./scripts/convex-self-hosted.sh deploy
```

Configure server-side `BETTER_AUTH_SECRET`, `AI_PROVIDER`, `AI_MODEL`, and
`OPENROUTER_API_KEY` through that same wrapper. Convex supplies `CONVEX_SITE_URL`
from the container's `CONVEX_SITE_ORIGIN` automatically.
The APK uses the two public endpoints through its EAS preview environment.

Back up the Convex data and instance credentials together before upgrades. Do
not remove the volume or rotate the instance secret during routine deployments.
Existing development data on the Mac is separate from this deployment.
