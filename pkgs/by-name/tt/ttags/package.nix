{
  lib,
  fetchFromGitHub,
  rustPlatform,
  testers,
  ttags,
}:
let
  version = "0.4.2";
in
rustPlatform.buildRustPackage {
  pname = "ttags";
  inherit version;

  src = fetchFromGitHub {
    owner = "npezza93";
    repo = "ttags";
    rev = "${version}";
    hash = "sha256-z0IxGdveMtCXmCKD4jp/BEA6mtTl4CitIrVhM6BtHzA=";
  };

  cargoHash = "sha256-XgtBcEVfeR0yYKJkpFfA8pXk1S1fg+2QS8o7n9G1CXU=";

  passthru.tests.version = testers.testVersion {
    package = ttags;
    command = "ttags --version";
    version = version;
  };

  meta = with lib; {
    description = "Generate tags using tree-sitter";
    mainProgram = "ttags";
    longDescription = ''
      ttags generates tags (similar to ctags) for various
      languages, using tree-sitter.

      Can be run as a language server that updates the tags
      for a file when it is saved.

      Supported languages:
      - Haskell
      - JavaScript
      - Nix
      - Ruby
      - Rust
      - Swift
    '';
    homepage = "https://github.com/npezza93/ttags";
    license = licenses.mit;
    maintainers = with maintainers; [ mrcjkb ];
    platforms = platforms.all;
  };
}
