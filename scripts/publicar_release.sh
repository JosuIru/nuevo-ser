#!/usr/bin/env bash
# Publica una versión de una app del monorepo en GitHub Releases con el
# formato que busca su pantalla «Actualizaciones» (nuevo_ser_core):
#   tag     <app>-<versión>          p. ej. uno-roto-1.0.0+20
#   asset   <app>-<versión>.apk
#
# Uso:
#   scripts/publicar_release.sh <app> [--subir-build] [--notas "texto"] [--sin-publicar]
#
#   <app>            carpeta de apps/ (uno-roto, las-versiones, agro, solera-quesera…)
#   --subir-build    suma 1 al número de build (+N) del pubspec y lo commitea
#   --notas "…"      notas del release; si no, las del git log de la app desde el
#                    release anterior
#   --sin-publicar   compila y deja el APK preparado, sin crear el release
#
# Crear un release es público: el script pide confirmación antes de subirlo.
set -euo pipefail

raiz="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/flutter/bin:$PATH"

app="${1:-}"
if [[ -z "$app" || ! -f "$raiz/apps/$app/pubspec.yaml" ]]; then
  echo "Uso: $0 <app> [--subir-build] [--notas \"texto\"] [--sin-publicar]" >&2
  echo "Apps: $(ls "$raiz/apps" | tr '\n' ' ')" >&2
  exit 1
fi
shift

subir_build=no
sin_publicar=no
notas=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subir-build) subir_build=si ;;
    --sin-publicar) sin_publicar=si ;;
    --notas) notas="$2"; shift ;;
    *) echo "Opción desconocida: $1" >&2; exit 1 ;;
  esac
  shift
done

carpeta="$raiz/apps/$app"
pubspec="$carpeta/pubspec.yaml"

if [[ "$subir_build" == si ]]; then
  actual="$(grep -E '^version:' "$pubspec" | awk '{print $2}')"
  base="${actual%%+*}"
  build="${actual#*+}"
  [[ "$build" == "$actual" ]] && build=0
  nueva="$base+$((build + 1))"
  sed -i -E "s/^version: .*/version: $nueva/" "$pubspec"
  git -C "$raiz" add "$pubspec"
  git -C "$raiz" commit -q -m "$app: versión $nueva"
  echo "Versión subida: $actual → $nueva (commit hecho; recuerda git push)"
fi

version="$(grep -E '^version:' "$pubspec" | awk '{print $2}')"
tag="$app-$version"
apk_final="$carpeta/build/$tag.apk"

if gh release view "$tag" >/dev/null 2>&1; then
  echo "Ya existe el release $tag. Usa --subir-build para publicar una versión nueva." >&2
  exit 1
fi

echo "Compilando $app $version…"
(
  cd "$carpeta"
  flutter pub get >/dev/null
  # Tras compilar la web, la primera compilación del APK a veces falla por
  # un registro de plugins viejo: se reintenta una vez.
  flutter build apk --release >/tmp/publicar_release_$app.log 2>&1 ||
    flutter build apk --release >/tmp/publicar_release_$app.log 2>&1 ||
    { tail -20 /tmp/publicar_release_$app.log; exit 1; }
)
cp "$carpeta/build/app/outputs/flutter-apk/app-release.apk" "$apk_final"
echo "APK listo: $apk_final ($(du -h "$apk_final" | cut -f1))"

if [[ -z "$notas" ]]; then
  git -C "$raiz" fetch --tags -q 2>/dev/null || true
  anterior="$(git -C "$raiz" tag -l "$app-*" --sort=-creatordate | head -1)"
  rango="${anterior:+$anterior..}HEAD"
  notas="$(git -C "$raiz" log --no-merges --format='- %s' "$rango" -- "apps/$app" | head -30)"
  [[ -z "$notas" ]] && notas="Versión $version."
fi

if [[ "$sin_publicar" == si ]]; then
  echo "--sin-publicar: no se crea el release. Notas que llevaría:"
  echo "$notas"
  exit 0
fi

if [[ -n "$(git -C "$raiz" log '@{u}..HEAD' --oneline 2>/dev/null)" ]]; then
  echo "Hay commits sin subir: haz git push antes de publicar (el tag apunta a HEAD)." >&2
  exit 1
fi

echo
echo "Se va a publicar en GitHub (público):"
echo "  release  $tag"
echo "  asset    $(basename "$apk_final")"
echo "  notas:"
echo "$notas" | sed 's/^/    /'
read -r -p "¿Publicar? [s/N] " respuesta
[[ "$respuesta" == s || "$respuesta" == S ]] || { echo "Cancelado."; exit 0; }

gh release create "$tag" "$apk_final" \
  --target "$(git -C "$raiz" rev-parse HEAD)" \
  --title "$app $version" \
  --notes "$notas"
echo "Publicado. Las apps con la versión anterior lo verán en Actualizaciones."
