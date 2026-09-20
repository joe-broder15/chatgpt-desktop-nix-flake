{
  stdenv,
  lib,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libnotify,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libGL,
  openssl,
  tpm2-tss,
  libusb1,
  qt5,
  qt6,
  xdg-utils,
}:

stdenv.mkDerivation {
  pname = "chatgpt-desktop";
  version = "26.915.31945";

  src = ./chatgpt_amd64.deb;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libnotify
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libGL
    openssl
    tpm2-tss
    libusb1
    stdenv.cc.cc.lib
    (lib.getLib qt5.qtbase)
    (lib.getLib qt6.qtbase)
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;
  dontConfigure = true;
  dontBuild = true;
  runtimeDependencies = [ (lib.getLib systemd) ];
  # The archive also ships optional musl Node prebuilds; on NixOS the
  # corresponding glibc prebuilds are selected instead.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a usr/. "$out/"
    test -x "$out/lib/chatgpt/ChatGPT"
    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt-desktop %U"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/lib/chatgpt/ChatGPT" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix XDG_DATA_DIRS : "$out/share"
    ln -s ../lib/chatgpt/ChatGPT "$out/bin/chatgpt-desktop"
  '';

  meta = {
    description = "ChatGPT desktop application";
    homepage = "https://chatgpt.com/";
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt-desktop";
    license = lib.licenses.unfree;
  };
}
