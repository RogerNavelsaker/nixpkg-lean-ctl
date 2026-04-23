{
  description = "A flake for lean-ctl binary";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        version = "0.3.0";

        sources = {
          "x86_64-linux" = {
            url = "https://github.com/yvgude/lean-ctl/releases/download/v${version}/leanctl-x86_64-unknown-linux-musl.tar.gz";
            hash = "sha256-YO/tanqX+oLSLpBlqHJ0jAlAmIX50j26wWli6+ZNgsQ=";
          };
          "aarch64-darwin" = {
            url = "https://github.com/yvgude/lean-ctl/releases/download/v${version}/leanctl-aarch64-apple-darwin.tar.gz";
            hash = "sha256-m18sCPPZaOOCMqHTUTFTFxBZhKOavHxyrwjejik1WGo=";
          };
          "x86_64-darwin" = {
            url = "https://github.com/yvgude/lean-ctl/releases/download/v${version}/leanctl-x86_64-apple-darwin.tar.gz";
            hash = "sha256-oOKIRBC53I6wFGGeA2Aqt1zsjj2kuxi+cFtJDerCgH0=";
          };
        };

        srcInfo = sources.${system} or (throw "Unsupported system: ${system}");
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "lean-ctl";
          inherit version;

          src = pkgs.fetchurl {
            inherit (srcInfo) url hash;
          };

          licenseFile = ./LICENSE;

          nativeBuildInputs = [ pkgs.installShellFiles ];

          sourceRoot = ".";

          installPhase = ''
            mkdir -p $out/bin
            cp leanctl $out/bin/leanctl
            
            # Include license as required by terms
            mkdir -p $out/share/doc/lean-ctl
            cp $licenseFile $out/share/doc/lean-ctl/LICENSE
          '';

          meta = with lib; {
            description = "Terminal-native AI coding agent";
            homepage = "https://github.com/yvgude/lean-ctl";
            license = licenses.unfreeRedistributable;
            platforms = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
            mainProgram = "leanctl";
          };
        };
      }
    );
}
