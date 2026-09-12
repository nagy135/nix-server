# nixzero — Raspberry Pi Zero 2 W

This host uses the repository's pinned Nixpkgs AArch64 SD image support, including
the Zero 2 W firmware and U-Boot. It is a persistent NixOS installation, with root
filesystem expansion on first boot. It has NetworkManager, SSH, Tailscale, mDNS,
zram, and a small set of administration tools for its 512 MB RAM.

The login is `infiniter`, with the shared public keys in `modules/ssh-keys.nix`
(including the current Mac key). SSH passwords are disabled. `infiniter` has
passwordless sudo; root also accepts the shared SSH keys for remote deployment.
The Pi 5's web services, containers, editors and agent services are not imported.

## Build on nixpi from the Mac

Run from this repository with Nix installed and Tailscale connected:

```sh
bash scripts/build-nixzero.sh
```

The script evaluates the local working tree, builds on the existing ARM64 Pi 5,
and downloads `artifacts/nixos-nixzero-aarch64-linux.img` plus its SHA-256 file.
It uses `root@nixpi.tail6650cb.ts.net` because the Pi's Nix daemon trusts only
root for importing locally evaluated derivations. It does not change nixpi's
running configuration. Set `NIXZERO_BUILDER` to use another ARM64 SSH builder.
New source files must be known to Git (`git add -N <file>` suffices for a local
build); uncommitted tracked changes are included.

On an AArch64 Linux machine, the native build command is:

```sh
nix build .#nixosConfigurations.nixzero.config.system.build.sdImage -o result-nixzero
```

## Flash on the Mac

The following write erases the entire selected card. Identify it again immediately
before flashing; `/dev/disk5` was the 15.5 GB `PHSD16G` SD card during inspection.
macOS reports the built-in SD reader as **internal**, so an external-only disk
listing will miss it. Do not select the Mac's system disk.

```sh
diskutil list
diskutil info /dev/disk5
shasum -a 256 -c artifacts/nixos-nixzero-aarch64-linux.img.sha256
```

Once you have confirmed `/dev/disk5` is still that SD card:

```sh
diskutil unmountDisk /dev/disk5 && \
sudo dd if="$PWD/artifacts/nixos-nixzero-aarch64-linux.img" of=/dev/rdisk5 bs=4m && \
sync && \
diskutil eject /dev/disk5
```

Press **Ctrl-T** for progress while macOS `dd` runs. Remove and reinsert the card
into the Mac so the new `FIRMWARE` partition mounts. Dismiss any macOS message
about the Linux partition; do not initialize it.

## Add home Wi-Fi before the first boot

Use a 2.4 GHz network with WPA2-Personal or WPA2/WPA3 mixed mode. Run:

```sh
python3 scripts/configure-nixzero-wifi.py /Volumes/FIRMWARE
```

The helper reads the repository's ignored `wifi_credentials` file if present:
the first line is the SSID and the second is the password. You can select another
file with `--credentials /path/to/file`. Without that file, it prompts for the
SSID and password without echoing the password. It
writes `nixzero.nmconnection` to the card, not into Git or the Nix store. On boot,
NixOS copies it into root-only NetworkManager storage before Wi-Fi starts and
removes the copy from the FAT partition. The derived PSK in that file is still
a network credential. Use `--replace` when updating an existing prepared profile.
Keep `wifi_credentials` local; it is excluded from Git and the flake source.
The same mechanism also works on later boots.

## Headless boot diagnostics

The image includes a U-Boot script that writes `nixzero-uboot.txt` to the FAT
partition at each boot checkpoint, then loads Linux directly. It skips USB/EFI
scanning and disables the VC4/V3D graphics drivers for this headless host.
The initrd writes `nixzero-linux-stage.txt`, `nixzero-kernel.txt`, and
`nixzero-initrd.txt`. Once userspace starts, a temporary service saves the boot
journal, failed services, and network status every ten seconds for three minutes.
These files are readable from macOS on the `FIRMWARE` volume after shutting down
or, if the device is stuck, removing power and returning the card to the Mac.
Checkpoints start at U-Boot; firmware failure before U-Boot cannot create them.

For an already-flashed image, `scripts/prepare-nixzero-diagnostics.py` can generate
a bundle from that image's single-entry `extlinux.conf` and a newly built
`system.build.initialRamdisk`. Copy its `uboot.env`, `nixzero-boot.scr`, and
`nixzero-initrd` onto `FIRMWARE`. Removing `uboot.env` restores the stock extlinux
boot path. This method preserves the Linux partition and Wi-Fi profile.
Normal NixOS rebuilds refresh the diagnostic environment and initrd for the
selected generation. The installer reads the default entry from extlinux, even
when older generations are also present.

Eject the card using Finder, put it into the Zero 2 W, and power it on. Allow a
few minutes for the first boot and store registration, then connect from the Mac:

```sh
ssh infiniter@nixzero.local
```

If mDNS is unavailable, use the `nixzero` DHCP lease address from your router.

## Join Tailscale

Tailscale is installed and enabled; the image intentionally contains no reusable
enrollment key. On nixzero:

```sh
sudo tailscale up --hostname=nixzero --netfilter-mode=off --ssh=false --accept-routes=false
```

Open the printed sign-in URL to enroll it in the existing tailnet. This keeps
ordinary OpenSSH authentication and NixOS-managed firewall rules, as on nixpi.
Then, from the Mac:

```sh
ssh infiniter@nixzero.tail6650cb.ts.net
```

## Update from nixzero

Use a checkout of `master` at `/etc/nixos` (see the branch migration in the
[root README](../README.md)). From a root shell (`sudo -i`):

```sh
cd /etc/nixos
git pull --ff-only
nixos-rebuild switch --flake .#nixzero
```

The explicit `#nixzero` selects this host configuration. Evaluation and
activation run on the Zero; Nix sends builds to `nixpi` over Tailscale. The Zero
has a 2 GiB swap file for evaluation alongside its zram. `nixpi` must be online.
The rebuild also updates the SD boot files, so the next reboot uses the selected
generation. Wi-Fi and Tailscale state are retained. No reflashing is needed.

The builder identity is `/root/.ssh/nixzero-builder` on the Zero. Its public key
is authorized in `hosts/nixpi/default.nix` with a forced Nix daemon command and SSH forwarding
disabled. The private key stays on the Zero. A fresh installation needs a new
key generated there and its public key enrolled on nixpi before remote builds
can run. The verified nixpi SSH host key is pinned in `hosts/nixzero/default.nix`.

Upstream references: [NixOS Raspberry Pi support](https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi),
[NetworkManager keyfiles](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/nm-settings-keyfile.html),
[Tailscale CLI](https://tailscale.com/kb/1080/cli).
