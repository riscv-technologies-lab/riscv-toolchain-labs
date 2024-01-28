{
  inputs,
  outputs,
  ...
}: let
  callLib = pathToLib:
    import pathToLib {
      inherit inputs outputs;
    };
in {
  lints = callLib ./lints.nix;
}
