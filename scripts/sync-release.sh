#!/usr/bin/env bash
# Sync nix/package-manifest.json (version, per-platform url + hash) from the latest yvgude/lean-ctl release.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
manifest=nix/package-manifest.json
tag=$(gh api repos/yvgude/lean-ctl/releases/latest --jq .tag_name)
version=${tag#v}
current=$(jq -r .package.version "$manifest")
[ "$current" != "$version" ] || { echo "already at $version"; exit 0; }
tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
jq --arg v "$version" --arg c "$current" '.package.version=$v | .dist.platforms |= map_values(.url |= sub("v" + $c; "v" + $v) | .url |= sub("/" + $c + "/"; "/" + $v + "/"))' "$manifest" > "$tmp"
for system in $(jq -r '.dist.platforms|keys[]' "$tmp"); do
  url=$(jq -r --arg s "$system" '.dist.platforms[$s].url' "$tmp")
  hash=$(nix store prefetch-file --json "$url" | jq -r .hash)
  jq --arg s "$system" --arg h "$hash" '.dist.platforms[$s].hash=$h' "$tmp" > "$tmp.n" && mv "$tmp.n" "$tmp"
done
cp "$tmp" "$manifest"
echo "synced lean-ctl $version"
