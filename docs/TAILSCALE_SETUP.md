# SSH to nixpi through Tailscale

This repository uses `.#nixpi` for the Raspberry Pi 5 and `.#hetzner` for the
Hetzner server; `.#nixzero` selects the Zero 2 W. Tailscale is enabled on both
Pis. On nixpi, OpenSSH and the existing
authorized keys come from `modules/system/base.nix` and `modules/users.nix`.
Use the normal `infiniter` account for SSH.

## Configuration and enrollment

The Pi's configuration enables `tailscaled` at boot, leaves
`services.tailscale.openFirewall = false`, and sets `useRoutingFeatures = "none"`.
The `extraSetFlags` keep `--netfilter-mode=off`, `--ssh=false`, and
`--accept-routes=false` persistent. NixOS retains control of packet filtering;
its existing TCP 22 allowance already permits OpenSSH through the tunnel.
No router forwarding, DDNS, exit node, or subnet route is needed. Dynamic public
addresses and CGNAT are supported through NAT traversal and encrypted relay
fallback: https://tailscale.com/docs/reference/faq/firewall-ports

Existing firewall allowances (TCP 22, 80, 443), SSH settings, and other web services
are preserved. T3 Code was subsequently made private as described below.
This setup does not make the other pre-existing services private or
change existing router rules. No new public service is added. Tailscale's access
policy controls which peers can reach services over the tunnel; a default new
tailnet allows communication between its devices. In a shared tailnet, restrict
access with a grant allowing the notebook to the Pi on TCP 22, preserving other
needed policy rules. OpenSSH still requires an authorized SSH key.

To apply this repository on the **Pi**:

```sh
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixpi --no-write-lock-file
sudo tailscale up --netfilter-mode=off --ssh=false --accept-routes=false
```

Open the enrollment URL printed by the last command on your Mac, and choose the
same Tailscale account/tailnet used by the Mac. Authenticate only in the browser;
do not put passwords or auth keys in this repository or share them in chat.
If the tailnet requires device approval, approve the Pi in the Machines page.
The `--ssh=false` flag leaves the existing OpenSSH server in charge of SSH.

On the **Mac**, install the standalone Tailscale application (already downloaded
and opened during setup). To install it again if needed:

```sh
brew install --cask tailscale-app
open -a Tailscale
```

Finish macOS authorization and Tailscale browser sign-in. On macOS 26, if the
extension is blocked, open System Settings > General > Login Items & Extensions
> Network Extensions and enable Tailscale; allow the VPN configuration when
prompted. Enable launch at login in Tailscale's settings. Do not install a second
Tailscale variant alongside this app.

The app includes the CLI; these commands work without editing your shell files:

```sh
export TAILSCALE_BE_CLI=1
TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
"$TS" set --accept-routes=false
"$TS" status
```

## Verified setup (2026-09-11)

- Mac: `100.103.11.44`, `viktor-mac.tail6650cb.ts.net`.
- Pi: `100.86.114.37`, `nixpi.tail6650cb.ts.net`.
- Both clients reported the same tailnet with MagicDNS enabled and each other online.
- SSH over both the Pi's Tailscale IPv4 and full MagicDNS name succeeded as `infiniter` with the trusted host key.
- The final `.#nixpi` configuration built and activated successfully; `tailscaled` and `sshd` are enabled and active.
- The boot-time preferences service completed successfully; the active IPv4/IPv6 input chains use only the existing NixOS firewall.
- At verification time, local and deployed configurations matched; `flake.lock` was unchanged.
- No failed systemd units remained after activation.
- The successful SSH connection was from `100.103.11.44` to `100.86.114.37:22`.
- Encrypted connectivity worked through the Frankfurt DERP relay and later established a direct connection; either is valid.
- The Mac UI confirmed launch at login enabled, subnet routes disabled, and exit-node service disabled.
- The Pi host key was reused from trusted LAN SSH for both Tailscale addresses in the Mac’s `~/.ssh/known_hosts`.
- Outside-home test passed: the user connected the Mac to a cellular hotspot
  and confirmed SSH worked. Independently, the Mac's physical network address
  changed from `192.168.178.28` to `10.235.0.125`, Tailscale ping reached the Pi
  through the Nuremberg DERP relay, and SSH by MagicDNS returned `nixpi`,
  `infiniter`, and `100.103.11.44 ... 100.86.114.37 22`. Both Pi services were active.
- Reboot tests still require user action.
- Device key expiry was enabled on both devices, with expiry on 2027-03-10.

The exact remote command, using the Pi's previously trusted host key, is:

```sh
ssh infiniter@nixpi.tail6650cb.ts.net
```

The numeric fallback is:

```sh
ssh infiniter@100.86.114.37
```

## Verify before travelling

On the **Pi**:

```sh
systemctl is-enabled tailscaled sshd
systemctl is-active tailscaled sshd
tailscale status
tailscale ip -4
tailscale status --json | jq -r '.Self.DNSName'
```

On the **Mac**, inspect `"$TS" status`: both the Mac and `nixpi` should appear.
In https://login.tailscale.com/admin/machines, confirm both are connected in the
same tailnet. Copy the Pi's actual Tailscale IPv4 address into `PI_TS_IP` below;
the following command obtains it automatically while home LAN access is present:

```sh
PI_TS_IP=$(ssh infiniter@nixpi.local tailscale ip -4)
"$TS" ping --c 3 "$PI_TS_IP"
ssh -o HostKeyAlias=nixpi.local -o StrictHostKeyChecking=yes "infiniter@$PI_TS_IP" \
  'hostname; whoami; printf "%s\n" "$SSH_CONNECTION"'
```

`HostKeyAlias` reuses the Pi's already trusted LAN host key. The identity verified
over LAN during setup was ED25519
`SHA256:6SDtrYbDQS/PMiloW6dUqFT99tzJArUBPmB3fVwgjSk`.
If SSH reports a different key, investigate; do not disable host-key checks.
A successful check prints `nixpi`, `infiniter`, and the tunnel connection addresses.
Use the full `.ts.net` DNS name from the Pi's status if MagicDNS is enabled;
`nixpi.local` is for home LAN access, not remote access.

If Tailscale ping succeeds but SSH fails, check device approval, the tailnet
policy's TCP 22 permission, and `systemctl status sshd` on the Pi. For
`Permission denied (publickey)`, check the Mac's loaded key with `ssh-add -l`.
A DERP relay result is valid and encrypted; direct connectivity is optional.

## Outside-home test (requires you to change networks)

1. Leave the Pi powered on and connected to the home router.
2. Disconnect the Mac from home Wi-Fi and any Ethernet connection.
3. Turn off Wi-Fi on the phone so it uses cellular data, enable its hotspot,
   and connect the Mac to that hotspot. Keep Tailscale connected on the Mac.
4. In the same Mac Terminal session, run:

   ```sh
   "$TS" status
   "$TS" ping --c 3 "$PI_TS_IP"
   ssh -o HostKeyAlias=nixpi.local -o StrictHostKeyChecking=yes "infiniter@$PI_TS_IP" \
     'hostname; whoami; printf "%s\n" "$SSH_CONNECTION"'
   ```

5. Confirm the Pi's name and username. This is the actual outside-home test;
   a successful tunnel connection while both devices are home is not equivalent.

## Reboots, expiry, and maintenance

The NixOS service starts at boot and keeps enrollment in `/var/lib/tailscale`.
Do not delete that state or run `tailscale logout` on the Pi. Enrollment is
persistent, so no reusable auth key or boot-time sign-in script is necessary.
OpenSSH also starts at boot. The Mac needs Tailscale connected after login, and
the Pi needs power and working internet. Keep the Mac's SSH key available.

Device keys expire after 180 days by default, subject to your tailnet's policy.
For unattended access, open the Machines page, find **nixpi**, open its menu, and
select **Disable key expiry**. Do this only for the trusted Pi; keeping expiry
enabled on the notebook is sensible. Disabling expiry trades periodic
reauthentication for availability, so remove a lost/compromised device from the
tailnet promptly. Alternatively, keep expiry enabled and reauthenticate while
you still have LAN access. Do not force reauthentication through your only
remote session. See https://tailscale.com/docs/features/access-control/key-expiry

Before a trip, reboot the Pi at a convenient time and repeat SSH over Tailscale;
also verify the Mac reconnects after logout/reboot. A reboot test requires user
action and is separate from checking that the services are enabled.

Update the Pi through the existing NixOS flake workflow, preserving this change;
use the standalone app's update mechanism on the Mac. The original Pi file was
backed up to `/etc/nixos/nixpi.nix.before-tailscale` during setup. If rollback is
needed, use LAN SSH or the Pi console and run `sudo nixos-rebuild switch --rollback`;
then reconcile the source configuration before a future rebuild.

## T3 Code: Pi remote access

### T3 Connect for Android

T3 Connect was enabled for the existing **nixpi** environment on 2026-10-16
using its saved account authorization. In the Android app, sign in to the
same T3 Connect account and select **nixpi**. This route works over the
internet without a manual server URL, pairing code, or Tailscale connection.

`t3code.service` remains managed by NixOS and listens on `127.0.0.1:3773`.
`hosts/nixpi/default.nix` includes `pkgs.cloudflared` in the system packages,
so the service uses the Nix-managed tunnel client from `PATH`. T3 Code manages
the authenticated tunnel as a child of that service. Credentials and the
desired link state stay in the user's existing T3 data directory, outside Git.
There is no additional `t3 service install` service.

Setup used `t3 connect link --headless` as `infiniter`, then restarted the
existing system service after `nixos-rebuild switch`. The saved authorization
was reused without another sign-in. Verified that `t3 connect status --json`
reports enabled, authenticated, linked, and not revoked, with relay client
source `path` (cloudflared 2026.6.1). The service registered four tunnel
connections, completed managed tunnel registration, and its environment
discovery endpoint returns HTTP 200. Agent activity publishing retains its
existing disabled setting.

### Direct connections over Tailscale

The Mac's T3 Code app is paired with the existing **nixpi** environment over
**SSH `infiniter@nixpi.tail6650cb.ts.net:22`**. It manages the SSH port forward
automatically. Keep Tailscale connected, open T3 Code, and select nixpi when
working on the Pi. Projects and agent execution for that environment stay on
the Pi. The local Mac environment is separate.

To add the connection again: **Settings > Connections > Add environment > SSH**,
host `nixpi.tail6650cb.ts.net`, username `infiniter`, port `22`. The app reuses
the existing server on the Pi.

A separate existing Tailscale Serve mapping exposes the same backend at
`https://nixpi.tail6650cb.ts.net:8443`. Use this address for direct pairing
while Tailscale is connected. Port `3773` is the loopback HTTP backend;
`https://nixpi.tail6650cb.ts.net:3773` is not a reachable HTTPS endpoint.
Verified the `:8443/.well-known/t3/environment` endpoint returns HTTP 200
with a valid TLS certificate.

### Previous public route removal

The Pi's `t3code.service` remains enabled at boot and binds only to
`127.0.0.1:3773`. Its public nginx virtual host and previous T3 Connect environment
variables were removed from `hosts/nixpi/default.nix`; its previous T3 Connect link was disabled
with `t3 connect unlink`, which also revoked the relay-side environment record.
The service was restarted and the Pi's cloudflared process stopped. The Mac's
own T3 Connect setting was not changed.

The `t3code` record was removed from the DDNS updater and its explicit public
A record was deleted through Websupport; the API confirmed no explicit records
remain for that name. Its backup is on the Pi under
`/var/lib/websupport-ddns/t3code-before-removal.json`.
Other DNS records and nginx sites are unchanged. The existing wildcard
`*.infiniter.tech` still resolves that name to `49.13.139.140` (the other server),
not the Pi. Cached answers may also persist briefly. Neither changes the fact
that the Pi's public nginx route to T3 Code has been removed.

Verified: the desktop shows **nixpi Connected** over SSH; its local SSH forward
returns the existing `nixpi` Linux/ARM64 environment (T3 Code 0.0.42).
The Pi listens only on loopback port 3773 and its active nginx configuration
contains no T3 Code proxy. At that time, no extra firewall ports, Tailscale
Serve, or Funnel were enabled. The current T3 Connect and Tailscale HTTPS
routes are described above.

### T3 Code 0.0.42 upgrade

The service uses the checksum-pinned ARM64 standalone release in
`pkgs/t3code-server.nix` while nixpkgs still packages 0.0.40. Nix patches its
ELF loader and native library paths. The desktop also downloads its own helper
to `~/.t3/runtime/versions`; `programs.nix-ld.enable` lets that unpatched release
run on NixOS. Without it, SSH setup fails with "The t3 0.0.42 executable does not
run on this host" before it can connect to the existing service.

Deployed with `nixos-rebuild switch --flake /etc/nixos#nixpi` on 2026-09-20.
Verified the packaged server and downloaded helper report 0.0.42, database
migrations succeed, the original environment ID is retained, and the Mac
shows **nixpi Connected**. The service remains enabled at boot and bound to
loopback. A backup made while the service was stopped is stored on the Pi at
`/var/backups/t3code/userdata-before-0.0.42-20260920.tar.gz`.

### T3 Code 0.0.45 upgrade

The Nix-managed service was upgraded from 0.0.42 to 0.0.45 on 2026-10-05
with `nixos-rebuild switch --flake /etc/nixos#nixpi --no-write-lock-file`.
`pkgs/t3code-server.nix` pins the official Linux/ARM64 release and its SHA-256;
the flake inputs were unchanged. The system closure differs only in the
T3 Code package.

Verified the packaged server reports 0.0.45, `t3code.service` is active and
enabled at boot, HTTP returns 200, and the service still listens only on
`127.0.0.1:3773`. The existing desktop-downloaded SSH helper at
`~/.t3/runtime/versions/0.0.45/t3` also reports 0.0.45. No `npx` installation
is needed to update the managed service.

A full userdata backup, made while the service was stopped, is stored at
`/var/backups/t3code/userdata-before-0.0.45-20261005-110534.tar.gz`.
Both the backup and live SQLite database pass `PRAGMA quick_check`, and the
environment ID is unchanged. All host derivations, the Zero SD image, and
`nix flake check --all-systems --no-build --no-write-lock-file` passed.

### T3 Code 0.1.0 upgrade

The Nix-managed service was upgraded from 0.0.45 to 0.1.0 on 2026-10-16
with `nixos-rebuild switch --flake /etc/nixos#nixpi --no-write-lock-file`.
The package pins the official Linux/ARM64 release and its published SHA-256;
the flake inputs were unchanged. The system closure differs only in the
T3 Code package. The system build and
`nix flake check --all-systems --no-build --no-write-lock-file` passed.

A full userdata backup, made while the service was stopped, is stored at
`/var/backups/t3code/userdata-before-0.1.0-20261016-210308.tar.gz`.
Both databases in the extracted backup pass `PRAGMA quick_check`.
The previous system path, environment-ID checksum, and original project and
thread IDs are also recorded under `/var/backups/t3code`.

The V2 migration imported all 26 threads and their transcripts, with all
9 project IDs and 26 thread IDs preserved. The original `state.sqlite` remains
in place; V2 uses `statev2.sqlite`. Both live databases pass `PRAGMA quick_check`,
and the environment ID is unchanged. The packaged server and desktop-downloaded
SSH helper both report 0.1.0. The service is active and enabled at boot, HTTP
returns 200, and it still listens only on `127.0.0.1:3773`.

Clients connecting to this server must support V2 (desktop 0.1.0 or newer,
mobile 2.0 or newer). V1 and V2 database changes do not synchronize after
the migration; see the [upstream migration notes](https://github.com/pingdotgg/t3code/issues/14871).

For a temporary browser connection, run this on the Mac and leave it running:

```sh
ssh -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 \
  -L 127.0.0.1:13773:127.0.0.1:3773 infiniter@nixpi.tail6650cb.ts.net
```

Then open `http://127.0.0.1:13773`. The regular desktop connection does not need
this manual tunnel. Stop the temporary tunnel with Ctrl-C when finished.

### T3 Code 0.1.1 upgrade

The Nix-managed service was upgraded from 0.1.0 to 0.1.1 on 2026-10-21
using the official Linux/ARM64 release and its published SHA-256.
The flake inputs were unchanged, and the system closure differs only in
the T3 Code package. The system build, all host and Zero SD image derivation
evaluations, and `nix flake check --all-systems --no-build --no-write-lock-file`
passed.

A full userdata backup, made while the service was stopped, is stored at
`/var/backups/t3code/userdata-before-0.1.1-20261021-223415.tar.gz`.
The previous system path, environment-ID checksum, and original project and
thread IDs are also recorded under `/var/backups/t3code`.

The packaged server reports 0.1.1, the service is active and enabled at boot,
HTTP returns 200, and it listens only on `127.0.0.1:3773`. Both live databases
pass `PRAGMA quick_check`; the environment ID, 9 project IDs, and 26 thread IDs
are preserved.

During activation, the desktop's SSH reconnect started the downloaded 0.1.1
helper while the system service was stopped. Its userdata ownership lock
prevented the system service from starting. Stopping that helper and starting
`t3code.service` restored the Nix-managed server. For future upgrades, keep the
desktop connection disconnected during the backup and service switch.

### T3 Code 0.1.2 upgrade

The Nix-managed service was upgraded to 0.1.2 on 2026-10-23 using the
official Linux/ARM64 archive and its published SHA-256. Flake inputs are
unchanged. The release executable initially segfaulted on nixpi's 16 KiB-page
kernel because Node 26.12.1's SEA injector produced incompatible ELF metadata
segments ([upstream issue](https://github.com/pingdotgg/t3code/issues/23433)).
The package now relocates those read-only metadata mappings, validates LOAD
alignment and page separation at 64 KiB, and checks the packaged version and
help commands during the build. Remove the workaround once the release uses
a compatible injector; the proposed upstream fix is
[PR 23443](https://github.com/pingdotgg/t3code/pull/23443).

A stopped-service userdata backup and checksum, previous system path,
environment-ID checksum, and project/thread ID snapshots are stored in
`/var/backups/t3code/before-0.1.2-20261023-103439`.
All host and Zero SD image derivation evaluations, the flake check, and the
native system build passed. An isolated server returned HTTP 200 before
activation. After activation, the packaged server reports 0.1.2, the service
is active and enabled, and HTTP returns 200 on `127.0.0.1:3773`.
Both databases pass `PRAGMA quick_check`; the environment ID, 9 project IDs,
and 26 thread IDs are preserved. T3 Connect reports a connected QUIC tunnel.
