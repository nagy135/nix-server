# Run from firmware before USB/EFI scanning. Each checkpoint is durable on FAT.
setenv nz_stage script-started
setenv nz_error none
run nz_log

if load mmc 0:2 ${kernel_addr_r} ${nz_kernel}; then
  setenv nz_stage kernel-loaded
  run nz_log
else
  setenv nz_stage failed
  setenv nz_error kernel-load
  run nz_log
  exit
fi

if load mmc 0:1 ${ramdisk_addr_r} nixzero-initrd; then
  setenv nz_initrd_size ${filesize}
  setenv nz_stage initrd-loaded
  run nz_log
else
  setenv nz_stage failed
  setenv nz_error initrd-load
  run nz_log
  exit
fi

if load mmc 0:2 ${fdt_addr_r} ${nz_dtbs}/${fdtfile}; then
  setenv nz_stage devicetree-loaded
  run nz_log
else
  setenv nz_stage failed
  setenv nz_error devicetree-load
  run nz_log
  exit
fi

setenv bootargs ${nz_bootargs}
setenv nz_stage kernel-handoff
run nz_log
booti ${kernel_addr_r} ${ramdisk_addr_r}:${nz_initrd_size} ${fdt_addr_r}
setenv nz_stage failed
setenv nz_error kernel-returned
run nz_log
