{lib, ...}: {
  # Headless diagnostics for the legacy initrd used by the AArch64 SD image.
  boot.initrd.systemd.enable = false;
  boot.initrd.availableKernelModules = ["vfat" "nls_cp437" "nls_iso8859-1"];
  boot.blacklistedKernelModules = ["vc4" "v3d"];

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /run/nixzero-firmware
    for attempt in 1 2 3 4 5; do
      if mount -t vfat -o sync,umask=0077 /dev/disk/by-label/FIRMWARE /run/nixzero-firmware; then
        echo initrd-devices-ready > /run/nixzero-firmware/nixzero-linux-stage.txt
        dmesg > /run/nixzero-firmware/nixzero-kernel.txt
        if [ -f /run/nixzero-firmware/nixzero-initrd.txt ]; then
          cp /run/nixzero-firmware/nixzero-initrd.txt /run/nixzero-firmware/nixzero-initrd.previous.txt
        fi
        exec > /run/nixzero-firmware/nixzero-initrd.txt 2>&1
        echo "nixzero: first-stage devices ready"
        cat /proc/cmdline
        sync
        break
      fi
      sleep 1
    done
  '';

  boot.initrd.preFailCommands = lib.mkAfter ''
    if mountpoint -q /run/nixzero-firmware; then
      echo initrd-failed > /run/nixzero-firmware/nixzero-linux-stage.txt
      dmesg > /run/nixzero-firmware/nixzero-kernel.txt
      sync
    fi
  '';

  boot.initrd.postMountCommands = lib.mkAfter ''
    # A system built with a systemd initrd exposes systemd itself as /init.
    # Its prepare-root performs activation and execs systemd when called from
    # a legacy initrd. This also lets this initrd boot an already-flashed image.
    prepareRoot="''${stage2Init%/init}/prepare-root"
    if [ -x "$targetRoot/$prepareRoot" ]; then
      stage2Init="$prepareRoot"
    fi

    if mountpoint -q /run/nixzero-firmware; then
      echo root-mounted > /run/nixzero-firmware/nixzero-linux-stage.txt
      dmesg > /run/nixzero-firmware/nixzero-kernel.txt
      sync
    fi

    # /run is moved into the real root by stage 1. This transient unit also
    # works when testing the diagnostic initrd with the existing SD system.
    mkdir -p /run/systemd/system/multi-user.target.wants
    cat > /run/systemd/system/nixzero-boot-log.service <<'UNIT'
    [Unit]
    Description=Save headless boot diagnostics to the SD card
    After=local-fs.target NetworkManager.service
    RequiresMountsFor=/boot/firmware

    [Service]
    Type=simple
    ExecStart=/run/current-system/sw/bin/bash /run/nixzero-save-logs.sh
    TimeoutStopSec=5
    UNIT
    ln -sf ../nixzero-boot-log.service /run/systemd/system/multi-user.target.wants/nixzero-boot-log.service
    cat > /run/nixzero-save-logs.sh <<'SCRIPT'
    export PATH=/run/current-system/sw/bin
    echo userspace-started > /boot/firmware/nixzero-linux-stage.txt
    for attempt in $(seq 1 18); do
      journalctl -b --no-pager -o short-monotonic > /boot/firmware/nixzero-journal.txt.tmp
      mv /boot/firmware/nixzero-journal.txt.tmp /boot/firmware/nixzero-journal.txt
      systemctl --failed --no-pager > /boot/firmware/nixzero-services.txt
      { ip -brief address; nmcli device status; } > /boot/firmware/nixzero-network.txt 2>&1
      sync
      sleep 10
    done
    SCRIPT
  '';
}
