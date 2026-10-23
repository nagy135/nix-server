{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  git,
  gh,
  openssh,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "t3code-server";
  version = "0.1.2";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-arm64.tar.gz";
    sha256 = "df112e1f19772b4055a28c97b032eb6d038d5d7182015f1cafd3254ad6fabd0f";
  };

  nativeBuildInputs = [autoPatchelfHook makeWrapper python3];
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

  # Node 26.12.1's SEA injector places metadata on 4 KiB boundaries.
  # Repair the metadata so nixpi's 16 KiB kernel can load the server.
  # Upstream: https://github.com/pingdotgg/t3code/issues/23433
  postFixup = ''
    python3 ${./patch-t3code-elf.py} $out/libexec/t3code/t3
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$("$out/bin/t3" --version)" = "t3 v${version}"
    "$out/bin/t3" --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "T3 Code standalone server";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    platforms = ["aarch64-linux"];
    mainProgram = "t3";
  };
}
