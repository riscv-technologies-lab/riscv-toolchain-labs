{
  description = "Practical riscv toolchains and cross-compilation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    lint-nix.url = "github:xc-jp/lint.nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib.extend (_: _: import ./lib {inherit inputs outputs;});
    systems = ["x86_64-linux" "aarch64-linux"];
  in
    flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      lints = lib.lints pkgs ./.;
    in {
      legacyPackages = {
        inherit lints;
      };

      formatter = pkgs.alejandra;

      devShells = {
        default = import ./shell.nix {inherit pkgs;};
      };
    })
    // {
    };
}
