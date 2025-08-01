{
  stdenv,
  lib,
  fetchFromGitea,
  pkg-config,
  meson,
  ninja,
  pixman,
  tllist,
  wayland,
  wayland-scanner,
  wayland-protocols,
  enablePNG ? true,
  enableJPEG ? true,
  enableWebp ? true,
  # Optional dependencies
  libpng,
  libjpeg,
  libwebp,
}:

stdenv.mkDerivation rec {
  pname = "wbg";
  version = "1.2.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "dnkl";
    repo = "wbg";
    rev = version;
    hash = "sha256-zd5OWC0r/75IaeKy5xjV+pQefRy48IcFTxx93iy0a0Q=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wayland-scanner
  ];

  buildInputs = [
    pixman
    tllist
    wayland
    wayland-protocols
  ]
  ++ lib.optional enablePNG libpng
  ++ lib.optional enableJPEG libjpeg
  ++ lib.optional enableWebp libwebp;

  mesonBuildType = "release";

  mesonFlags = [
    (lib.mesonEnable "png" enablePNG)
    (lib.mesonEnable "jpeg" enableJPEG)
    (lib.mesonEnable "webp" enableWebp)
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=maybe-uninitialized"
  ];

  meta = {
    description = "Wallpaper application for Wayland compositors";
    homepage = "https://codeberg.org/dnkl/wbg";
    changelog = "https://codeberg.org/dnkl/wbg/releases/tag/${version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "wbg";
  };
}
