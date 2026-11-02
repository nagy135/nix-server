# Calendar timer on nixpi

Production: https://timer.infiniter.tech

Source: `nagy135/calendar-timer`, branch `main`.
Checkout: `/home/infiniter/services/calendar-timer`.
Static releases: `/var/www/timer/releases/<commit>-<timestamp>`.
Nginx root: `/var/www/timer/current`.

The React/Vite app builds on nixpi using locked npm dependencies. Run `npm run
deploy` in its clean, committed Mac checkout to push, pull, test, build, and
atomically replace the served symlink. No Node process runs in production.
Dates are stored only in the user's browser.

Publish infrastructure changes to `master`, pull them as root in `/etc/nixos`,
and run `nixos-rebuild switch --flake /etc/nixos#nixpi` on nixpi. Do not update
the lockfile. Start `websupport-ddns.service` to publish the timer A record.
If first-time ACME issuance precedes DNS propagation, restart
`acme-order-renew-timer.infiniter.tech.service` after DNS resolves correctly.
Previous releases remain available for rollback by switching `current`.
