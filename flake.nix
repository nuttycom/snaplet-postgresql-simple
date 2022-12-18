{
  description = "PostgreSQL support for Snap";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkg-name = "snaplet-postgresql-simple";
        pkgs = import nixpkgs {
          inherit system;
        };

        haskell = pkgs.haskellPackages;

        jailbreakUnbreak = pkg:
            pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

        haskell-overlay = final: prev: {
          ${pkg-name} = hspkgs.callCabal2nix pkg-name ./. { };
          snap = jailbreakUnbreak prev.snap;
        };

        hspkgs = haskell.override {
          overrides = haskell-overlay;
        };
      in {
        packages = pkgs;

        defaultPackage = hspkgs.${pkg-name};

        devShell = hspkgs.shellFor {
          packages = p: [p.${pkg-name}];
          root = ./.;
          withHoogle = true;
          buildInputs = with hspkgs; [
            haskell-language-server
            cabal-install
          ];
        };
      });
}
