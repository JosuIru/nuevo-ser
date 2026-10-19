#!/usr/bin/env bash
# Empaqueta el plugin y lo publica como release de GitHub
# (`plugin-solera-zunbeltz-sync-<versión>`), de donde lo toman los
# WordPress instalados para actualizarse (includes/actualizaciones.php).
# Uso: dev/publicar_release.sh [fichero-de-notas.md]
set -euo pipefail
notas_fichero="${1:+$(realpath "$1")}"
cd "$(dirname "$0")/.."
version="$(grep -o "define( 'SZS_VERSION', '[^']*'" solera-zunbeltz-sync.php | sed "s/.*'\(.*\)'/\1/")"
cabecera="$(grep -o '^ \* Version: *[0-9.]*' solera-zunbeltz-sync.php | grep -o '[0-9.]*$')"
if [ "$version" != "$cabecera" ]; then
  echo "SZS_VERSION ($version) y la cabecera Version ($cabecera) no coinciden" >&2
  exit 1
fi
tag="plugin-solera-zunbeltz-sync-$version"
if gh release view "$tag" -R JosuIru/nuevo-ser >/dev/null 2>&1; then
  echo "Ya existe la release $tag: sube la versión antes de publicar" >&2
  exit 1
fi
temporal="$(mktemp -d)"
trap 'rm -rf "$temporal"' EXIT
zip="$(dev/empaquetar.sh "$temporal")"
notas=(--notes "Plugin solera-zunbeltz-sync $version.")
[ -n "$notas_fichero" ] && notas=(--notes-file "$notas_fichero")
gh release create "$tag" "$zip" -R JosuIru/nuevo-ser --target main \
  --title "Plugin Solera Zunbeltz $version" "${notas[@]}"
