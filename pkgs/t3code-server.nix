{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  git,
  gh,
  openssh,
}:
stdenv.mkDerivation rec {
  pname = "t3code-server";
  version = "0.0.42";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-arm64.tar.gz";
    sha256 = "7de47e66793c91b01ee3fb304d9d2dc9a7019aaa8f85c55b535d6d8ca3e14013";
  };

  nativeBuildInputs = [autoPatchelfHook makeWrapper];
  buildInputs = [stdenv.cc.cc.lib];
  dontBuild = true;
  # The standalone executable contains the bundled application payload.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/t3code $out/bin
    cp -r . $out/libexec/t3code/
    # NixOS uses the bundled glibc build, not these optional musl addons.
    rm -f $out/libexec/t3code/node_modules/@msgpackr-extract/msgpackr-extract-linux-arm64/*.musl.node
    makeWrapper $out/libexec/t3code/t3 $out/bin/t3 \
      --prefix PATH : ${lib.makeBinPath [git gh openssh]}
    runHook postInstall
  '';

  meta = {
    description = "T3 Code standalone server";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    platforms = ["aarch64-linux"];
    mainProgram = "t3";
  };
}
