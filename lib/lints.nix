{inputs, ...}: let
  inherit (inputs) lint-nix;
in
  pkgs: src:
    lint-nix.lib.lint-nix rec {
      inherit pkgs src;

      linters = {
        typos = {
          ext = "";
          cmd = "${pkgs.typos}/bin/typos $filename";
        };
      };

      formatters = {
        clang-format = {
          ext = [".c" ".cpp" ".h" ".hpp" ".cc"];
          cmd = "${pkgs.clang-tools}/bin/clang-format";
          stdin = true;
        };

        alejandra = {
          ext = ".nix";
          cmd = "${pkgs.alejandra}/bin/alejandra --quiet";
          stdin = true;
        };

        mdformat = {
          ext = [".md"];
          cmd = "${pkgs.python311Packages.mdformat}/bin/mdformat $filename";
        };
      };
    }
