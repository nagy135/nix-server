{bun, fetchurl, ...}:
# The project's Bun 1.4 lockfile cannot be read by the older nixpkgs Bun.
# Reuse nixpkgs' native Linux packaging and patching for the official ARM64 binary.
bun.overrideAttrs (old: {
  version = "1.4.2";
  src = fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v1.4.2/bun-linux-aarch64.zip";
    hash = "sha256-VDKLvC2cjgyfiSxUTWbFeoO4QTnjSQnl7oF1jxrI/ac=";
  };
  meta = old.meta // {platforms = ["aarch64-linux"];};
})
