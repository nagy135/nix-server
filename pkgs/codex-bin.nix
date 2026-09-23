{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.156.1";

  # Official ARM64 release, including the code-mode host and runtime resources.
  src = fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}-linux-arm64.tgz";
    hash = "sha512-sTEHk31C12dqzJdjZ2u9KLFCXKL04KyCM+QheSjdQI8uzmVJS7aEF2/qAqFxXwk/jwMzC9u7IihfoIlAGR6YsA==";
  };

  dontBuild = true;
  # Keep the upstream binaries and their relative resource layout intact.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r vendor/aarch64-unknown-linux-musl/. $out/
    runHook postInstall
  '';

  meta = {
    description = "OpenAI Codex CLI, official ARM64 release";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    platforms = ["aarch64-linux"];
    mainProgram = "codex";
  };
}
