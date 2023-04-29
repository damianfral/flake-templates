{
  description = "TBD";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    dekking.url = "github:NorfairKing/dekking";
    safe-coloured-text.url = "github:NorfairKing/safe-coloured-text";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , nix-filter
    , dekking
    , safe-coloured-text
    , pre-commit-hooks
    , ...
    }:

    let
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          safe-coloured-text.overlays.${system}
        ];
      };
      filteredSrc =
        nix-filter.lib {
          root = ./.;
          include = [
            "src/"
            "test/"
            "package.yaml"
            "LICENSE"
          ];
        };
    in
    {
      overlays.default = final: prev: with final.haskell.lib; {
        haskellPackages = prev.haskellPackages.override (old: {
          overrides = final.lib.composeExtensions
            (old.overrides or (_: _: { }))
            (self: super: {
              autodocodec-yaml = unmarkBroken (dontCheck super.autodocodec-yaml);
              sydtest = unmarkBroken (dontCheck super.sydtest);
              hello = self.generateOptparseApplicativeCompletions
                [ "hello" ]
                (self.callCabal2nix "hello" filteredSrc { });
            });
        });
      };
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = pkgsFor system;
      precommitCheck = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          actionlint.enable = true;
          hlint.enable = true;
          hpack.enable = true;
          markdownlint.enable = true;
          nil.enable = true;
          nixpkgs-fmt.enable = true;
          ormolu.enable = true;
          statix.enable = true;
        };
      };
    in
    rec {
      packages.hello = pkgs.haskellPackages.hello;
      packages.hello-coverage-report = dekking.packages.${system}.default.makeCoverageReport {
        name = "hello-coverage-report";
        packages = [ "hello" ];
      };
      packages.default = packages.hello;

      apps.hello = flake-utils.lib.mkApp {
        drv = pkgs.haskell.lib.justStaticExecutables (
          packages.hello.overrideAttrs (oldAttrs: {
            configureFlags = oldAttrs.configureFlags ++ [ "--ghc-option=-O2" ];
          })
        );
      };
      apps.default = apps.hello;

      devShells.default = pkgs.haskellPackages.shellFor {
        packages = p: [ packages.hello ];
        buildInputs = with pkgs; with pkgs.haskellPackages; [
          actionlint
          cabal-install
          ghcid
          haskell-language-server
          hlint
          nil
          nixpkgs-fmt
          ormolu
          statix
        ];
        inherit (precommitCheck) shellHook;
      };

      checks = { pre-commit-check = precommitCheck; };
    }
    );
  nixConfig = {
    extra-substituters = "https://opensource.cachix.org";
    extra-trusted-public-keys = "opensource.cachix.org-1:6t9YnrHI+t4lUilDKP2sNvmFA9LCKdShfrtwPqj2vKc=";
  };
}

