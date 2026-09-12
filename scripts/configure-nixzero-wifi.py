#!/usr/bin/env python3
"""Place a Wi-Fi profile on an already-flashed nixzero SD card from macOS."""

import argparse
import getpass
import hashlib
import os
from pathlib import Path
import uuid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("firmware", type=Path, help="Mounted FAT partition, e.g. /Volumes/FIRMWARE")
    parser.add_argument("--credentials", type=Path, default=Path(__file__).resolve().parent.parent / "wifi_credentials",
                        help="Local two-line file: SSID, then password (defaults to repository wifi_credentials)")
    parser.add_argument("--replace", action="store_true", help="Replace an existing prepared Wi-Fi profile")
    args = parser.parse_args()
    firmware = args.firmware.resolve()
    if not (firmware / "u-boot.bin").is_file() or not (firmware / "config.txt").is_file():
        parser.error("This is not a mounted NixOS Raspberry Pi firmware partition.")

    if args.credentials.is_file():
        lines = args.credentials.read_text().splitlines()
        if len(lines) != 2:
            parser.error("The credentials file must contain exactly two lines: SSID, then password.")
        ssid, password = lines
        print(f"Reading Wi-Fi credentials from {args.credentials}; credentials will only be written to the card.")
    else:
        ssid = input("Home Wi-Fi name (SSID, with 2.4 GHz enabled): ")
        password = getpass.getpass("Wi-Fi password (hidden): ")
        if password != getpass.getpass("Repeat Wi-Fi password: "):
            parser.error("Passwords do not match.")
    ssid_bytes = ssid.encode("utf-8")
    if not 1 <= len(ssid_bytes) <= 32:
        parser.error("The SSID must be 1–32 bytes.")
    if not 8 <= len(password) <= 63 or not password.isascii():
        parser.error("Use a WPA2-Personal passphrase of 8–63 ASCII characters.")

    # A byte list avoids keyfile escaping issues in SSIDs. The derived WPA2 PSK
    # still grants network access; it is kept only on the card, never in Git.
    psk = hashlib.pbkdf2_hmac("sha1", password.encode(), ssid_bytes, 4096, 32).hex()
    profile = f"""[connection]
id=nixzero-home
uuid={uuid.uuid4()}
type=wifi
autoconnect=true
autoconnect-priority=100

[wifi]
mode=infrastructure
ssid={';'.join(str(byte) for byte in ssid_bytes)};

[wifi-security]
key-mgmt=wpa-psk
psk={psk}

[ipv4]
method=auto

[ipv6]
method=auto
"""
    target = firmware / "nixzero.nmconnection"
    os.umask(0o077)
    if target.exists() and not args.replace:
        parser.error("A profile already exists; use --replace to update it.")
    temporary = firmware / ".nixzero.nmconnection.tmp"
    fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "w") as stream:
        stream.write(profile)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, target)
    print(f"Wi-Fi profile saved to {target}. Eject the card before removing it.")


if __name__ == "__main__":
    main()
