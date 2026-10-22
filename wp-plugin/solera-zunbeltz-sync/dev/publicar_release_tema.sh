#!/usr/bin/env bash
# Empaqueta el tema wp-theme/zunbeltz-espacio y lo publica como release de
# GitHub (`tema-zunbeltz-espacio-<versión>`), de donde lo toma el plugin
# para actualizar el tema en los WordPress instalados (includes/actualizaciones.php).
# Uso: dev/publicar_release_tema.sh [fichero-de-notas.md]
set -euo pipefail
notas_fichero="${1:+$(realpath "$1")}"
cd "$(dirname "$0")/../../../wp-theme"
version="$(grep -o '^Version: *[0-9.]*' zunbeltz-espacio/style.css | grep -o '[0-9.]*$')"
tag="tema-zunbeltz-espacio-$version"
if gh release view "$tag" -R JosuIru/nuevo-ser >/dev/null 2>&1; then
  echo "Ya existe la release $tag: sube la versión en style.css antes de publicar" >&2
  exit 1
fi
temporal="$(mktemp -d)"
trap 'rm -rf "$temporal"' EXIT
zip="$temporal/zunbeltz-espacio-$version.zip"
zip -qr "$zip" zunbeltz-espacio -x '*.DS_Store' 'zunbeltz-espacio/dev/*'
notas=(--notes "Tema zunbeltz-espacio $version.")
[ -n "$notas_fichero" ] && notas=(--notes-file "$notas_fichero")
gh release create "$tag" "$zip" -R JosuIru/nuevo-ser --target main \
  --title "Tema Zunbeltz Espacio $version" "${notas[@]}"
