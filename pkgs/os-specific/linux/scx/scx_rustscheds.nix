{
  lib,
  rustPlatform,
  llvmPackages,
  pkg-config,
  elfutils,
  zlib,
  zstd,
  scx-common,
  scx,
  protobuf,
  libseccomp,
}:
rustPlatform.buildRustPackage {
  pname = "scx_rustscheds";
  inherit (scx-common) version src;

  inherit (scx-common.versionInfo.scx) cargoHash;

  # Copy compiled headers and libs from scx.cscheds
  postPatch = ''
    mkdir libbpf
    cp -r ${scx.cscheds.dev}/libbpf/* libbpf/
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    protobuf
  ];
  buildInputs = [
    elfutils
    zlib
    zstd
    libseccomp
  ];

  env = {
    BPF_CLANG = lib.getExe llvmPackages.clang;
    BPF_EXTRA_CFLAGS_PRE_INCL = lib.concatStringsSep " " [
      "-I${scx.cscheds.dev}/libbpf/src/usr/include"
      "-I${scx.cscheds.dev}/libbpf/include/uapi"
      "-I${scx.cscheds.dev}/libbpf/include/linux"
    ];
    RUSTFLAGS = lib.concatStringsSep " " [
      "-C relocation-model=pic"
      "-C link-args=-lelf"
      "-C link-args=-lz"
      "-C link-args=-lzstd"
      "-L ${scx.cscheds.dev}/libbpf/src"
    ];
  };

  hardeningDisable = [
    "stackprotector"
    "zerocallusedregs"
  ];

  doCheck = true;
  checkFlags = [
    "--skip=compat::tests::test_ksym_exists"
    "--skip=compat::tests::test_read_enum"
    "--skip=compat::tests::test_struct_has_field"
    "--skip=cpumask"
    "--skip=topology"
  ];

  meta = scx-common.meta // {
    description = "Sched-ext Rust userspace schedulers";
    longDescription = ''
      This includes Rust based schedulers such as
      scx_rustland, scx_bpfland, scx_lavd, scx_layered, scx_rlfifo.

      ::: {.note}
      Sched-ext schedulers are only available on kernels version 6.12 or later.
      It is recommended to use the latest kernel for the best compatibility.
      :::
    '';
  };
}
