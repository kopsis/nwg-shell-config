{
  #inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      out = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          appliedOverlay = self.overlays.default pkgs pkgs;
        in
        {
          packages.nwg-shell-config = appliedOverlay.nwg-shell-config;
        };
    in
    flake-utils.lib.eachDefaultSystem out // { # update out with following attrset
      overlays.default = final: prev: {
        nwg-shell-config = final.callPackage ./derivation.nix { };
      };
    };
}

