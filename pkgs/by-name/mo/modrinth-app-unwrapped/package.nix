{
  lib,
  stdenv,
  cacert,
  cargo-tauri,
  desktop-file-utils,
  fetchFromGitHub,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpm_9,
  rustPlatform,
  turbo,
  webkitgtk_4_1,
}:

let
  pnpm = pnpm_9;
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "modrinth-app-unwrapped";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "modrinth";
    repo = "code";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1+Fmc8qyU3hCZmRNgp90nuvFgaB/GOH6SNc9AyWZYn0=";
  };

  cargoHash = "sha256-6hEnXzaL6PnME9s+T+MtmoTQmaux/0m/6xaQ99lwM2I=";

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 1;
    hash = "sha256-Q6e942R+3+511qFe4oehxdquw1TgaWMyOGOmP3me54o=";
  };

  nativeBuildInputs = [
    cacert # Required for turbo
    cargo-tauri.hook
    desktop-file-utils
    nodejs
    pkg-config
    pnpm.configHook
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin makeBinaryWrapper;

  buildInputs = [ openssl ] ++ lib.optional stdenv.hostPlatform.isLinux webkitgtk_4_1;

  # Tests fail on other, unrelated packages in the monorepo
  cargoTestFlags = [
    "--package"
    "theseus_gui"
  ];

  env = {
    TURBO_BINARY_PATH = lib.getExe turbo;
  };

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      makeBinaryWrapper "$out"/Applications/Modrinth\ App.app/Contents/MacOS/Modrinth\ App "$out"/bin/ModrinthApp
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      desktop-file-edit \
        --set-comment "Modrinth's game launcher" \
        --set-key="StartupNotify" --set-value="true" \
        --set-key="Categories" --set-value="Game;ActionGame;AdventureGame;Simulation;" \
        --set-key="Keywords" --set-value="game;minecraft;mc;" \
        --set-key="StartupWMClass" --set-value="ModrinthApp" \
        $out/share/applications/Modrinth\ App.desktop
    '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Modrinth's game launcher";
    longDescription = ''
      A unique, open source launcher that allows you to play your favorite mods,
      and keep them up to date, all in one neat little package
    '';
    homepage = "https://modrinth.com";
    license = with lib.licenses; [
      gpl3Plus
      unfreeRedistributable
    ];
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "ModrinthApp";
    platforms = with lib; platforms.linux ++ platforms.darwin;
    # This builds on architectures like aarch64, but the launcher itself does not support them yet.
    # Darwin is the only exception
    # See https://github.com/modrinth/code/issues/776#issuecomment-1742495678
    broken = !stdenv.hostPlatform.isx86_64 && !stdenv.hostPlatform.isDarwin;
  };
})
