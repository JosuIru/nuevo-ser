#!/usr/bin/env bash
# Publica un tema de la Colección en GitHub Releases con el formato que lee el
# autoactualizador de nuevo-ser-core (NS_Actualizaciones::TEMAS): los WordPress
# con el tema y el plugin (0.22.0 o superior) ven la versión nueva en
# Escritorio → Actualizaciones.
#   tag     tema-<tema>-<versión>
#   assets  tema-<tema>-<versión>.zip     con la carpeta <tema>/ dentro
#           tema-<tema>-<versión>.zip.sha256
#
# Uso:
#   bash scripts/wp/publicar_tema.sh uno-roto [--notas "texto"] [--sin-publicar]
#
# La versión sale de la cabecera «Version:» del style.css del tema. Crear un
# release es público: el script pide confirmación antes de subirlo.
set -euo pipefail
raiz="$(cd "$(dirname "$0")/../.." && pwd)"
tema="${1:?Uso: publicar_tema.sh <tema> [--notas \"texto\"] [--sin-publicar]}"
shift
carpeta="$raiz/wp-theme/$tema"
[[ -f "$carpeta/style.css" ]] || { echo "No existe el tema $carpeta" >&2; exit 1; }
grep -q '^Update URI: https://github.com/JosuIru/nuevo-ser' "$carpeta/style.css" || { echo "El style.css del tema necesita «Update URI: https://github.com/JosuIru/nuevo-ser»." >&2; exit 1; }
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

version="$(grep -E '^Version:' "$carpeta/style.css" | awk '{print $2}')"
tag="tema-$tema-$version"
nombre_zip="tema-$tema-$version.zip"
salida="$raiz/dist/tema-$tema"

if [[ "$sin_publicar" == no ]] && gh release view "$tag" >/dev/null 2>&1; then
  echo "Ya existe el release $tag. Sube la versión del tema para publicar otra." >&2
  exit 1
fi

rm -rf "$salida"
mkdir -p "$salida/$tema"
rsync -a --exclude '.*' "$carpeta/" "$salida/$tema/"
(cd "$salida" && zip -qr -9 "$nombre_zip" "$tema" && sha256sum "$nombre_zip" > "$nombre_zip.sha256")
echo "Zip listo: $salida/$nombre_zip ($(du -h "$salida/$nombre_zip" | cut -f1))"

if [[ -z "$notas" ]]; then
  notas="Tema $tema $version. Se actualiza desde el wp-admin: Escritorio → Actualizaciones (con nuevo-ser-core 0.22.0 o superior)."
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
  --title "tema $tema $version" \
  --notes "$notas" \
  --latest=false
echo "Publicado."
