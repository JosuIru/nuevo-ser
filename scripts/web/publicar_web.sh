#!/usr/bin/env bash
# Publica la versión web de un juego en GitHub Releases con el formato que
# instala el plugin nuevo-ser-core desde el wp-admin (Nuevo Ser Core →
# Juegos web, clase NS_Instalador_Juegos_Web):
#   tag     web-<juego>-<versión>            p. ej. web-uno-roto-1.0.0+20
#   assets  <juego>-web-<versión>.zip        build/web en la raíz del zip
#           <juego>-web-<versión>.zip.sha256
#
# Uso:
#   bash scripts/web/publicar_web.sh uno-roto [--notas "texto"] [--sin-publicar]
#
# El build sale con la ruta base /wp-content/uploads/juegos/<juego>/: vale
# para un WordPress en la raíz de su dominio o subdominio. Para uno en un
# subdirectorio, BASE_HREF=/sub/wp-content/uploads/juegos/<juego>/.
# El audio (assets/sonido, ignorado por git) entra tal como esté en disco.
# Crear un release es público: el script pide confirmación antes de subirlo.
set -euo pipefail

raiz="$(cd "$(dirname "$0")/../.." && pwd)"
juego="${1:?Uso: publicar_web.sh <juego> [--notas \"texto\"] [--sin-publicar]}"
shift

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

carpeta_juego="$raiz/apps/$juego"
version="$(grep -E '^version:' "$carpeta_juego/pubspec.yaml" | awk '{print $2}')"
tag="web-$juego-$version"
nombre_zip="$juego-web-$version.zip"
salida="$carpeta_juego/build/publicar-web"
zip_final="$salida/$nombre_zip"

if [[ "$sin_publicar" == no ]] && gh release view "$tag" >/dev/null 2>&1; then
  echo "Ya existe el release $tag. Sube la versión del pubspec para publicar otra." >&2
  exit 1
fi

rm -rf "$salida"
mkdir -p "$salida"
bash "$raiz/scripts/web/desplegar.sh" "$juego" "$salida/web"
(cd "$salida/web" && zip -qr -9 "$zip_final" .)
(cd "$salida" && sha256sum "$nombre_zip" > "$nombre_zip.sha256")
echo "Zip listo: $zip_final ($(du -h "$zip_final" | cut -f1))"

if [[ -z "$notas" ]]; then
  notas="Versión web de $juego $version. Se instala desde el wp-admin: Nuevo Ser Core → Juegos web."
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

gh release create "$tag" "$zip_final" "$zip_final.sha256" \
  --target "$(git -C "$raiz" rev-parse HEAD)" \
  --title "$juego web $version" \
  --notes "$notas" \
  --latest=false
echo "Publicado. En el wp-admin: Nuevo Ser Core → Juegos web → Instalar."
