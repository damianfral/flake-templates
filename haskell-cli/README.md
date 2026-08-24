# Nix flake for a Haskell CLI application

This flake contains a Nix package and a development shell for a sample Haskell
CLI application called `hello`.

The Haskell package is wrapped with `generateOptparseApplicativeCompletions`,
which adds shell completion scripts. These scripts will be automatically picked
up if the resulting derivation is installed.

The development shell provides the following tools for Haskell development:

- [cabal-install](https://www.haskell.org/cabal/)
- [haskell-language-server](https://github.com/haskell/haskell-language-server)
- [ghcid](https://github.com/ndmitchell/ghcid)
- [pre-commit / git-hooks.nix](https://github.com/cachix/git-hooks.nix)
  - [actionlint](https://github.com/rhysd/actionlint)
  - [alejandra](https://github.com/kamadorueda/alejandra)
  - [beautysh](https://github.com/lovesegfault/beautysh)
  - [check-merge-conflicts](https://github.com/pre-commit/pre-commit-hooks)
  - [hlint](https://github.com/ndmitchell/hlint)
  - [hpack](https://github.com/sol/hpack)
  - [markdownlint](https://github.com/igorshubovych/markdownlint-cli)
  - [nil](https://github.com/oxalica/nil)
  - [ormolu](https://github.com/tweag/ormolu)
  - [ripsecrets](https://github.com/StackExchange/security)
  - [shellcheck](https://github.com/koalaman/shellcheck)
  - [statix](https://github.com/nerdypepper/statix)
