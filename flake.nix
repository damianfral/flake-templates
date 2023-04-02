{
  description = "A collection of flake templates";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:

    let pkgsFor = system: import nixpkgs { inherit system; }; in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = pkgsFor system;
          precommitCheck = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              actionlint.enable = true;
              markdownlint.enable = true;
              nil.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };

        in
        {
          devShells.default = pkgs.mkShell
            {
              inherit (precommitCheck) shellHook;
              buildInputs = with pkgs; [
                actionlint
                nil
                nixpkgs-fmt
                statix
              ];
            };
        }
      ) // {

      templates.haskell = {
        path = ./haskell;
        description = "Template for a haskell CLI application";
      };

    };
}
