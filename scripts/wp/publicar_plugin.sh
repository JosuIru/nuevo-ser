#!/usr/bin/env bash
# Publica el plugin nuevo-ser-core en GitHub Releases con el formato que lee
# su autoactualizador (clase NS_Actualizaciones): los WordPress que lo tienen
# instalado ven la versión nueva en Escritorio → Actualizaciones.
#   tag     nuevo-ser-core-<versión>
#   assets  nuevo-ser-core-<versión>.zip     con la carpeta nuevo-ser-core/ dentro
#           nuevo-ser-core-<versión>.zip.sha256
#
# Uso:
#   bash scripts/wp/publicar_plugin.sh [--notas "texto"] [--sin-publicar]
#
# La versión sale de la cabecera «Version:» del plugin, que debe coincidir con
# NS_CORE_VERSION. Pasa los tests del plugin antes de empaquetar.
# Crear un release es público: el script pide confirmación antes de subirlo.
set -euo pipefail
raiz="$(cd "$(dirname "$0")/../.." && pwd)"
carpeta="$raiz/wp-plugin/nuevo-ser-core"
notas=""
sin_publicar=no
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notas) notas="$2"; shift ;;
    --sin-publicar) sin_publicar=si ;;
    *) echo "Opción desconocida: $1" >&2; exit 1 ;;
  esac
  shift
done

version="$(grep -E '^ \* Version:' "$carpeta/nuevo-ser-core.php" | awk '{print $3}')"
constante="$(grep -oE "NS_CORE_VERSION', '[^']+'" "$carpeta/nuevo-ser-core.php" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")"
if [[ "$version" != "$constante" ]]; then
  echo "La cabecera dice $version y NS_CORE_VERSION dice $constante: tienen que coincidir." >&2
  exit 1
fi
tag="nuevo-ser-core-$version"
nombre_zip="nuevo-ser-core-$version.zip"
salida="$raiz/dist/plugin"

if [[ "$sin_publicar" == no ]] && gh release view "$tag" >/dev/null 2>&1; then
  echo "Ya existe el release $tag. Sube la versión del plugin para publicar otra." >&2
  exit 1
fi

for prueba in "$carpeta"/tests/test_*.php; do
  php "$prueba" >/dev/null || { echo "Falla $(basename "$prueba"): no se publica." >&2; exit 1; }
done

rm -rf "$salida"
mkdir -p "$salida/nuevo-ser-core"
# Sin los tests: no hacen falta en el servidor.
rsync -a --exclude tests --exclude '.*' "$carpeta/" "$salida/nuevo-ser-core/"
(cd "$salida" && zip -qr -9 "$nombre_zip" nuevo-ser-core && sha256sum "$nombre_zip" > "$nombre_zip.sha256")
echo "Zip listo: $salida/$nombre_zip ($(du -h "$salida/$nombre_zip" | cut -f1))"

if [[ -z "$notas" ]]; then
  notas="Nuevo Ser Core $version. Se actualiza desde el wp-admin: Escritorio → Actualizaciones."
fi

if [[ "$sin_publicar" == si ]]; then
  echo "--sin-publicar: no se crea el release."
  exit 0
fi

if [[ -n "$(git -C "$raiz" log '@{u}..HEAD' --oneline 2>/dev/null)" ]]; then
  echo "Hay commits sin subir: haz git push antes de publicar (el tag apunta a HEAD)." >&2
  exit 1
fi

echo
echo "Se va a publicar en GitHub (público):"
echo "  release  $tag"
echo "  assets   $nombre_zip, $nombre_zip.sha256"
echo "  notas    $notas"
read -r -p "¿Publicar? [s/N] " respuesta
[[ "$respuesta" == s || "$respuesta" == S ]] || { echo "Cancelado."; exit 0; }

gh release create "$tag" "$salida/$nombre_zip" "$salida/$nombre_zip.sha256" \
  --target "$(git -C "$raiz" rev-parse HEAD)" \
  --title "nuevo-ser-core $version" \
  --notes "$notas" \
  --latest=false
echo "Publicado. Los WordPress con nuevo-ser-core 0.21.0 o superior lo verán en Escritorio → Actualizaciones."
