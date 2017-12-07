#!/usr/bin/env bash
set -e
json="{}"
add() { json=$(jshon "$@" <<<"$json"); }

rm -rf overlay/upstream
mkdir -p overlay/upstream/{master,stable}

GET() {
  curl -s -H "Authorization: token ${GITHUB_TOKEN?Need OAuth token}" "$@"
}

package() {
  echo -n bumping "$1 "
  pkg="$1"
  name=$(basename "$pkg")
  tag=$(GET https://api.github.com/repos/"$pkg"/tags | jshon -e 0)
  version=$(jshon -e name -u <<<"$tag")
  taghash=$(jshon -e commit -e sha -u <<<"$tag")
  head=$(GET https://api.github.com/repos/"$pkg"/commits | jshon -e 0)
  headhash=$(jshon -e sha -u <<<"$head")
  echo -n "stable $version, master $headhash"
  tagsha256=$(
    nix-prefetch-url \
      --unpack \
      https://github.com/"$pkg"/archive/"$version".tar.gz 2>/dev/null)
  headsha256=$(
    nix-prefetch-url \
      --unpack \
      https://github.com/"$pkg"/archive/"$headhash".tar.gz 2>/dev/null)
  add -n {} \
      -s "${version#v}" -i version \
      -n {} \
      -s "$headhash" -i rev \
      -s "$headsha256" -i sha256 \
      -s "$(dirname "$pkg")" -i owner \
      -s "$name" -i repo \
      -i master \
      -n {} \
      -s "$taghash" -i rev \
      -s "$tagsha256" -i sha256 \
      -s "$(dirname "$pkg")" -i owner \
      -s "$name" -i repo \
      -i stable \
      -i "$name"

  tree=$(GET https://api.github.com/repos/"$pkg"/git/trees/"$taghash")
  nix=$(jq -r <<<"$tree" '.tree | .[] | select(.path == "default.nix") | .url')
  GET "$nix" | jshon -e content -u | base64 -d > overlay/upstream/stable/$name.nix

  tree=$(GET https://api.github.com/repos/"$pkg"/git/trees/"$headhash")
  nix=$(jq -r <<<"$tree" '.tree | .[] | select(.path == "default.nix") | .url')
  GET "$nix" | jshon -e content -u | base64 -d > overlay/upstream/master/$name.nix

  echo
}

package mbrock/jays
package mbrock/symbex
package makerdao/setzer
package lessrest/restless-git

package dapphub/hevm
package dapphub/seth
package dapphub/ethsign

# This one is slow because of node_modules, lol.
package dapphub/dapp

echo "$json" | jq . > overlay/versions.json