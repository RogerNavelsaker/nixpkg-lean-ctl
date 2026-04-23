{ fetchurl, installShellFiles, lib, stdenv, stdenvNoCC }:

let
  manifest = builtins.fromJSON (builtins.readFile ./package-manifest.json);
  platformDist =
    manifest.dist.platforms.${stdenv.hostPlatform.system}
      or (throw "unsupported platform for ${manifest.binary.name}: ${stdenv.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = manifest.package.repo;
  version = manifest.package.version;

  src = fetchurl {
    url = platformDist.url;
    hash = platformDist.hash;
  };

  sourceRoot = ".";
  dontBuild = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp leanctl "$out/bin/${manifest.binary.name}"
    
    # Include license
    mkdir -p "$out/share/doc/${manifest.package.repo}"
    cp ${../LICENSE} "$out/share/doc/${manifest.package.repo}/LICENSE"
    runHook postInstall
  '';

  meta = with lib; {
    description = manifest.meta.description;
    homepage = manifest.meta.homepage;
    license = licenses.unfreeRedistributable;
    mainProgram = manifest.binary.name;
    platforms = builtins.attrNames manifest.dist.platforms;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
