{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fsspec,
  indexed-gzip,
  indexed-zstd,
  libarchive-c,
  pytestCheckHook,
  python-xz,
  pythonOlder,
  writableTmpDirAsHomeHook,
  rapidgzip,
  rarfile,
  setuptools,
  zstandard, # Python bindings
  zstd, # System tool
}:

buildPythonPackage rec {
  pname = "ratarmountcore";
  version = "1.0.0";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "mxmlnkn";
    repo = "ratarmount";
    tag = "v${version}";
    hash = "sha256-nTKbwZoD7nf3cKFJOR5p6ZRFHsKVeJXboOAhPjvnQAM=";
    fetchSubmodules = true;
  };

  sourceRoot = "${src.name}/core";

  build-system = [ setuptools ];

  optional-dependencies = {
    full = [
      indexed-gzip
      indexed-zstd
      python-xz
      rapidgzip
      rarfile
    ];
    _7z = [ libarchive-c ];
    bzip2 = [ rapidgzip ];
    gzip = [ indexed-gzip ];
    rar = [ rarfile ];
    xz = [ python-xz ];
    zstd = [ indexed-zstd ];
  };

  nativeCheckInputs = [
    pytestCheckHook
    zstandard
    zstd
    fsspec
    writableTmpDirAsHomeHook
  ]
  ++ lib.flatten (builtins.attrValues optional-dependencies);

  pythonImportsCheck = [ "ratarmountcore" ];

  disabledTestPaths = [
    # Disable this test because for arcane reasons running pytest with nix-build uses 10-100x
    # more virtual memory than running the test directly or inside a local development nix-shell.
    # This virtual memory usage caused os.fork called by Python multiprocessing to fail with
    # "OSError: [Errno 12] Cannot allocate memory" on a test system with 16 GB RAM. It worked fine
    # on a system with 96 GB RAM. In order to avoid build errors on "low"-memory systems, this
    # test is disabled for now.
    "tests/test_BlockParallelReaders.py"
  ];

  disabledTests = [
    # Tests with issues
    "test_file_versions"
    "test_stream_compressed"
    "test_chimera_file"
    "test_URLContextManager"
    "test_URL"
  ];

  meta = with lib; {
    description = "Library for accessing archives by way of indexing";
    homepage = "https://github.com/mxmlnkn/ratarmount/tree/master/core";
    changelog = "https://github.com/mxmlnkn/ratarmount/blob/core-${src.tag}/core/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ mxmlnkn ];
  };
}
