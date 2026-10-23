#!/usr/bin/env bash
# Compila el APK y lo publica como release de GitHub
# (`solera-zunbeltz-<versión>` con `solera-zunbeltz-<versión>.apk`), de donde
# se actualiza la app y lo sirve «Descargar para Android» del plugin.
# Antes comprueba que la etiqueta queda la primera también como texto
# (scripts/comprobar_orden_release.sh).
# Uso: tool/publicar_release.sh [fichero-de-notas.md]
set -euo pipefail
notas_fichero="${1:+$(realpath "$1")}"
cd "$(dirname "$0")/.."
export PATH="$HOME/flutter/bin:$PATH"
version="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
tag="solera-zunbeltz-$version"
if gh release view "$tag" -R JosuIru/nuevo-ser >/dev/null 2>&1 </dev/null; then
  echo "Ya existe la release $tag: sube la versión en pubspec.yaml" >&2
  exit 1
fi
../../scripts/comprobar_orden_release.sh solera-zunbeltz- "$tag"
version_en_ajustes="$(grep -o "versionAppZunbeltz = '[^']*'" lib/pantallas/pantalla_ajustes.dart | sed "s/.*'\(.*\)'/\1/")"
if [ "$version_en_ajustes" != "${version%%+*}" ]; then
  echo "versionAppZunbeltz ($version_en_ajustes) no coincide con pubspec (${version%%+*})" >&2
  exit 1
fi
flutter build apk --release </dev/null
temporal="$(mktemp -d)"
trap 'rm -rf "$temporal"' EXIT
apk="$temporal/$tag.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$apk"
notas=(--notes "Larrea Zunbeltz $version.")
[ -n "$notas_fichero" ] && notas=(--notes-file "$notas_fichero")
gh release create "$tag" "$apk" -R JosuIru/nuevo-ser --target main \
  --title "Larrea Zunbeltz $version" "${notas[@]}" </dev/null
