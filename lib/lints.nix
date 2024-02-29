{inputs, ...}: let
  cpp-extensions = [".c" ".cpp" ".h" ".hpp" ".cc"];
in
  pkgs: src:
    inputs.lint-nix.lib.lint-nix rec {
      inherit pkgs src;

      linters = {
        typos = {
          ext = [".md"] ++ cpp-extensions;
          cmd = "${pkgs.typos}/bin/typos $filename";
        };
      };

      formatters = {
        clang-format = {
          ext = cpp-extensions;
          cmd = "${pkgs.clang-tools}/bin/clang-format";
          stdin = true;
        };

        alejandra = {
          ext = ".nix";
          cmd = "${pkgs.alejandra}/bin/alejandra --quiet";
          stdin = true;
        };

        mdformat = {
          ext = ".md";
          cmd = "${pkgs.python311Packages.mdformat}/bin/mdformat $filename";
        };
      };
    }
