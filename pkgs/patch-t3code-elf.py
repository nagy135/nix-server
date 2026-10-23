"""Repair the ARM64 metadata LOAD segments emitted by Node's SEA injector.

Keep code, data, file offsets and the embedded application untouched. Only
relocate read-only metadata in virtual memory, preserving its file alignment.
Validate all LOAD mappings for 64 KiB pages (also covering 4 and 16 KiB).
Remove this workaround when the upstream release uses a compatible injector:
https://github.com/pingdotgg/t3code/pull/23443
"""

import pathlib
import struct
import sys


path = pathlib.Path(sys.argv[1])
data = bytearray(path.read_bytes())
assert data[:6] == b"\x7fELF\x02\x01", "Expected little-endian ELF64"
assert struct.unpack_from("<H", data, 18)[0] == 183, "Expected ARM64"
phoff, shoff = struct.unpack_from("<QQ", data, 32)
phsize, phnum, shsize, shnum = struct.unpack_from("<HHHH", data, 54)
assert phsize == 56 and shsize == 64
headers = [
    list(struct.unpack_from("<IIQQQQQQ", data, phoff + i * phsize))
    for i in range(phnum)
]
sections = [
    list(struct.unpack_from("<IIQQQQIIQQ", data, shoff + i * shsize))
    for i in range(shnum)
]
page = 65536
for segment in [h.copy() for h in headers if h[0] == 1 and h[7] == 4096]:
    assert segment[1] == 4, "Only read-only metadata may be relocated"
    start, end = segment[3], segment[3] + segment[6]
    address = ((start + page - 1) // page) * page + segment[2] % page
    delta = address - start
    for section in sections:
        if start <= section[3] < end:
            assert section[1] == 7, "Only NOTE sections may be relocated"
            section[3] += delta
    for header in headers:
        if start <= header[3] and header[3] + header[6] <= end:
            assert header[0] in (1, 4, 6), "Unexpected metadata program header"
            header[3] += delta
            header[4] += delta
            if header[0] == 1:
                header[7] = page
    print(f"Relocated ARM64 SEA metadata: {start:#x} -> {address:#x}")

ranges = []
for header in headers:
    if header[0] != 1:
        continue
    offset, address, size = header[2], header[3], header[6]
    assert offset % page == address % page, "Incompatible ARM64 LOAD alignment"
    if size:
        start, end = address // page, (address + size + page - 1) // page
        assert all(end <= lo or start >= hi for lo, hi in ranges), "Overlapping LOAD pages"
        ranges.append((start, end))
assert ranges, "Missing LOAD segments"
for i, header in enumerate(headers):
    struct.pack_into("<IIQQQQQQ", data, phoff + i * phsize, *header)
for i, section in enumerate(sections):
    struct.pack_into("<IIQQQQIIQQ", data, shoff + i * shsize, *section)
path.write_bytes(data)
