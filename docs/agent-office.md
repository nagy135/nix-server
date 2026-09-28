# Agent Office on nixpi

Production: https://office.infiniter.tech

`modules/services/agent-office.nix` runs the app as `infiniter` on
`127.0.0.1:4600`, using the existing Claude Code and Codex authentication.
Nginx handles HTTPS and WebSockets; Websupport DDNS maintains the `office`
record. The service starts at boot.

The source checkout is `/home/infiniter/services/agent-office`, from
https://github.com/AgentSystemLabs/agent-office. The initial deployment uses
commit `b05fa4f`. Dependencies and frontend/server assets are built on nixpi
with `npm ci`. Runtime state is separate in `/home/infiniter/agent-office`.
The shared password is stored as a scrypt hash in the private
`.agent-office/config.json` there; no password belongs in this repository.

GitHub CLI is installed. Run `gh auth login` as `infiniter` on nixpi before
selecting GitHub projects in the office. The initial office has no projects.

For an update, inspect the checkout, fetch and select the intended commit,
run `npm ci` and `npm run typecheck`, then restart `agent-office.service`
as root. Restarting also stops its workers, so coordinate updates with active
office sessions. To roll back, select the previous commit, rebuild, and restart.

After adding this route, start `websupport-ddns.service`, wait for DNS to
resolve, and start `acme-order-renew-office.infiniter.tech.service` if the
first certificate request ran before the DNS record existed.

The uptime dashboard checks the HTTPS route and `agent-office.service`.
Its inventory and restricted observer script are maintained in
`~/Code/uptime_dashboard` on the Mac and `~/services/uptime_dashboard` on nixpi.
