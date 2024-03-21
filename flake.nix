{
  description = "Practical RISC-V toolchains and cross-compilation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    lint-nix.url = "github:xc-jp/lint.nix";
    lf-dotfiles = {
      url = "github:lf-/dotfiles";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    lf-dotfiles,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib.extend (_: _: import ./lib {inherit inputs outputs;});
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {inherit system;};

        lints = lib.lints pkgs ./.;
      in {
        legacyPackages = {
          inherit lints;
        };

        formatter = pkgs.alejandra;

        devShells = {
          default = import ./shell.nix {inherit pkgs;};
        };

        packages = rec {
          riscv-toolchain-labs-book = pkgs.callPackage ./default.nix {};
          default = riscv-toolchain-labs-book;

          nix-closure-graph = pkgs.callPackage (
            {
              pkgs,
              lib,
              stdenv,
              jq,
              graphviz,
              makeWrapper,
              coreutils,
              nix,
              git,
              ...
            }:
              stdenv.mkDerivation {
                pname = "nix-closure-graph";
                version = "0";
                src = "${lf-dotfiles}/programs/nix-closure-graph";
                nativeBuildInputs = [makeWrapper];
                postPatch = ''
                  patchShebangs nix-closure-graph
                '';
                installPhase = ''
                  runHook preInstall
                  install -Dm755 -T nix-closure-graph $out/bin/nix-closure-graph
                  install -Dm644 -T nix-path-info-graphviz.jq $out/bin/nix-path-info-graphviz.jq
                  install -Dm644 -T nix-path-info-lg.jq $out/bin/nix-path-info-lg.jq
                  install -Dm644 -T lib.jq $out/bin/lib.jq
                  runHook postInstall
                '';
                postFixup = ''
                  wrapProgram $out/bin/nix-closure-graph --set PATH ${
                    lib.makeBinPath [
                      coreutils
                      jq
                      graphviz
                      nix
                      git
                    ]
                  }
                '';
              }
          ) {};
        };
      }
    )
    // {};
}
