#!/usr/bin/env python3
"""Prepare a reversible U-Boot diagnostic bundle for an existing nixzero image."""
import argparse
import pathlib
import posixpath
import re
import shutil
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--extlinux', type=pathlib.Path, required=True)
    p.add_argument('--initrd', type=pathlib.Path, required=True)
    p.add_argument('--output', type=pathlib.Path, required=True)
    p.add_argument('--script', type=pathlib.Path, default=pathlib.Path(__file__).with_name('nixzero-boot.cmd'))
    args = p.parse_args()
    entries = {}
    default = None
    current = None
    for line in args.extlinux.read_text().splitlines():
        fields = line.strip().split(None, 1)
        if len(fields) != 2:
            continue
        name, value = fields
        if name == 'DEFAULT':
            default = value
        elif name == 'LABEL':
            current = value
            if current in entries:
                p.error('Duplicate boot entry label.')
            entries[current] = {}
        elif current is not None and name in ('LINUX', 'FDTDIR', 'APPEND'):
            if name in entries[current]:
                p.error('Duplicate field in boot entry.')
            entries[current][name] = value
    if default is None and len(entries) == 1:
        default = next(iter(entries))
    if default not in entries:
        p.error('Cannot identify the default extlinux boot entry.')
    values = entries[default]
    if set(values) != {'LINUX', 'FDTDIR', 'APPEND'}:
        p.error('Missing LINUX, FDTDIR or APPEND in extlinux configuration.')
    for name in ('LINUX', 'FDTDIR'):
        if not re.fullmatch(r'[A-Za-z0-9/_.-]+', values[name]):
            p.error('Unexpected boot path.')
        values[name] = posixpath.normpath(posixpath.join('/boot/extlinux', values[name]))
    if not re.fullmatch(r'[A-Za-z0-9/_.=,:+ -]+', values['APPEND']):
        p.error('Unexpected kernel command line characters.')
    if not args.initrd.is_file():
        p.error('Diagnostic initrd does not exist.')
    if args.output.exists():
        p.error('Output directory already exists; use a new directory.')
    args.output.mkdir(parents=True)
    log = ('env export -t ${nz_logaddr} nz_stage nz_error board_name board_revision fdtfile; '
           'fatwrite mmc 0:1 ${nz_logaddr} nixzero-uboot.txt ${filesize}')
    env = {
        'bootdelay': '-2',
        'baudrate': '115200',
        'stdin': 'serial',
        'stdout': 'serial',
        'stderr': 'serial',
        'kernel_addr_r': '0x00080000',
        'fdt_addr_r': '0x05600000',
        'ramdisk_addr_r': '0x05700000',
        # Both must be above the loaded kernel + initrd, so neither is overwritten.
        'scriptaddr': '0x07f00000',
        'nz_logaddr': '0x08000000',
        'nz_kernel': values['LINUX'],
        'nz_dtbs': values['FDTDIR'],
        'nz_bootargs': values['APPEND'] + ' module_blacklist=vc4,v3d',
        'nz_log': log,
        'preboot': 'setenv nz_stage uboot-entered; setenv nz_error none; run nz_log',
        'bootcmd': ('if load mmc 0:1 ${scriptaddr} nixzero-boot.scr; '
                    'then source ${scriptaddr}; else setenv nz_stage failed; '
                    'setenv nz_error script-load; run nz_log; fi'),
    }
    source = args.output / 'uboot-env.txt'
    source.write_text(''.join(f'{key}={value}\n' for key, value in env.items()))
    subprocess.run(['mkenvimage', '-s', '0x4000', '-o', str(args.output / 'uboot.env'), str(source)], check=True)
    subprocess.run(['mkimage', '-A', 'arm64', '-O', 'linux', '-T', 'script', '-C', 'none',
                    '-n', 'nixzero headless diagnostics', '-d', str(args.script), str(args.output / 'nixzero-boot.scr')], check=True)
    shutil.copyfile(args.initrd, args.output / 'nixzero-initrd')
    print(f'Diagnostic bundle prepared in {args.output}; no SD card was modified.')


if __name__ == '__main__':
    main()
