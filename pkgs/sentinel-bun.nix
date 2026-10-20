{
  bun,
  fetchurl,
  stdenv,
  ...
}: let
  sources = {
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-VDKLvC2cjgyfiSxUTWbFeoO4QTnjSQnl7oF1jxrI/ac=";
    };
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-NjaPrvdSeHXV/6UuU81IAhdB8qg+tiCKjdZAaNQiqRM=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
  # The project's Bun 1.4 lockfile cannot be read by the older nixpkgs Bun.
  # Reuse nixpkgs' native Linux packaging and patching for the official binary.
  bun.overrideAttrs (old: {
    version = "1.4.2";
    src = fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.4.2/bun-linux-${source.arch}.zip";
      inherit (source) hash;
    };
    meta = old.meta // {platforms = builtins.attrNames sources;};
  })
