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
  version = "0.0.43-nightly.20260922.2110";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-arm64.tar.gz";
    sha256 = "5ccabbf39e2407ef40cf6a07de996a429387a6f9d7b050da8f8c4b419222e296";
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
