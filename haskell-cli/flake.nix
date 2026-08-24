{
  description = "Haskell CLI flake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    feedback.url = "github:NorfairKing/feedback";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-filter,
    pre-commit-hooks,
    feedback,
    ...
  }: let
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    filteredSrc = nix-filter.lib {
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
      overlays.default = final: prev: {
        hello = final.haskell.lib.justStaticExecutables (
          final.haskellPackages.hello.overrideAttrs (oldAttrs: {
            configureFlags = oldAttrs.configureFlags ++ ["--ghc-options=-O2"];
          })
        );
        haskellPackages = prev.haskellPackages.override (old: {
          overrides =
            final.lib.composeExtensions
            (old.overrides or (_: _: {}))
            (self: super: {
              hello =
                self.generateOptparseApplicativeCompletions
                ["hello"]
                (self.callCabal2nix "hello" filteredSrc {});
            });
        });
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = pkgsFor system;
        precommitCheck = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            actionlint.enable = true;
            alejandra.enable = true;
            beautysh.enable = true;
            check-merge-conflicts.enable = true;
            hlint.enable = true;
            hpack.enable = true;
            markdownlint.enable = true;
            nil.enable = true;
            ormolu.enable = true;
            ripsecrets.enable = true;
            shellcheck.enable = true;
            statix.enable = true;
          };
        };
      in rec {
        packages.hello = pkgs.hello;
        packages.default = packages.hello;

        apps.hello = flake-utils.lib.mkApp {drv = pkgs.hello;};
        apps.default = apps.hello;

        devShells.default = pkgs.haskellPackages.shellFor {
          packages = p: [p.hello];
          buildInputs = with pkgs;
          with pkgs.haskellPackages; [
            actionlint
            alejandra
            cabal-install
            ghcid
            haskell-language-server
            hlint
            feedback.packages.${system}.default
            nil
            ormolu
            statix
          ];
          inherit (precommitCheck) shellHook;
        };

        checks = {pre-commit-check = precommitCheck;};
      }
    );
  nixConfig = {
    extra-substituters = [
      "https://opensource.cachix.org"
      "https://haskell-language-server.cachix.org"
      "https://feedback.cachix.org"
    ];
    extra-trusted-public-keys = [
      "opensource.cachix.org-1:6t9YnrHI+t4lUilDKP2sNvmFA9LCKdShfrtwPqj2vKc="
      "haskell-language-server.cachix.org-1:juFfHrwkOxqIOZShtC4YC1uT1bBcq2RSvC7OMKx0Nz8="
      "feedback.cachix.org-1:8PNDEJ4GTCbsFUwxVWE/ulyoBMDqqL23JA44yB0j1jI="
    ];
  };
}
