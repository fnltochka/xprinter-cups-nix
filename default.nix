{
  lib,
  stdenv,
  fetchurl,
  cups,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "printer-driver-xprinter";
  version = "3.13.14";

  src = ./printer-driver-xprinter_3.13.14_all.deb;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    cups.lib
    cups
  ];

  # Don't unpack directly to $out
  unpackPhase = ''
    runHook preUnpack

    mkdir -p $TMPDIR/unpacked
    dpkg-deb -x $src $TMPDIR/unpacked

    runHook postUnpack
  '';

  # No separate build phase
  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';

  # Create the structure in $out and copy files there
  installPhase = ''
    runHook preInstall

    # Determine architecture
    ARCH=""
    case ${stdenv.hostPlatform.system} in
      x86_64-*) ARCH="-x64" ;;
      i686-*) ARCH="-x86" ;;
      aarch64-*) ARCH="-aarch64" ;;
      arm-*) ARCH="-armv7l" ;;
      *) echo "Unsupported architecture: ${stdenv.hostPlatform.system}" ; exit 1 ;;
    esac

    # Create proper directory structure
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model/xprinter

    # Copy binary driver files for the correct architecture
    # Use names with the -xprinter suffix as expected in PPD files
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/rastertosnailep$ARCH $out/lib/cups/filter/rastertosnailep-xprinter
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/rastertosnailep2$ARCH $out/lib/cups/filter/rastertosnailep2-xprinter
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/rastertosnailppli$ARCH $out/lib/cups/filter/rastertosnailppli-xprinter
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/rastertosnailtspl$ARCH $out/lib/cups/filter/rastertosnailtspl-xprinter
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/rastertosnailxpl$ARCH $out/lib/cups/filter/rastertosnailxpl-xprinter
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/rastertosnailzpl$ARCH $out/lib/cups/filter/rastertosnailzpl-xprinter
    cp -v $TMPDIR/unpacked/opt/xprinter/printer-driver-xprinter/bin/mvimg.sh $out/lib/cups/filter/
    chmod +x $out/lib/cups/filter/*

    # Copy printer PPD files
    cp -v $TMPDIR/unpacked/usr/share/cups/model/xprinter/* $out/share/cups/model/xprinter/

    # Make sure paths in PPD files are correct, without changing filter file names
    for file in $out/share/cups/model/xprinter/*.ppd; do
      sed -i "s|/opt/xprinter/printer-driver-xprinter/bin/|$out/lib/cups/filter/|g" "$file"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Printer driver for Xprinter printers";
    homepage = "https://www.xprinter.net/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ maintainers.fnltochka ];
  };
}
