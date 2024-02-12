{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib stdenv mdbook;
in
  stdenv.mkDerivation {
    pname = "riscv-toolchain-labs-book";
    version = "0.1";
    src = lib.cleanSource ./.;

    buildInputs = [mdbook];

    buildPhase = ''
      mdbook build -d build/
    '';

    installPhase = ''
      mkdir -p $out/share/public
      cp -R build/. $out/share/public
    '';
  }
