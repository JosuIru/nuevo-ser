#!/usr/bin/env bash
# Empaqueta el plugin de una app social en un zip listo para subir desde
# Plugins → Añadir nuevo → Subir plugin, o para `montar-servidor.sh --zip`.
#
#   ./empaquetar.sh [concejo]     → salida/concejo-<versión>.zip
#
# Copia la carpeta (no sigue enlaces fuera de ella) y deja fuera tests/.
# Nunca subas el zip a un WordPress cuyo plugin sea un enlace al repo:
# WordPress borra la carpeta enlazada antes de descomprimir.
set -euo pipefail

nombre_plugin="${1:-concejo}"
directorio_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
raiz_monorepo="$(cd "$directorio_script/../.." && pwd)"
origen="$raiz_monorepo/social/wp-plugin/$nombre_plugin"
archivo_principal="$origen/$nombre_plugin.php"

if [[ ! -f "$archivo_principal" ]]; then
  echo "No encuentro $archivo_principal" >&2
  exit 1
fi

version="$(sed -n 's/^[ *]*Version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$archivo_principal" | head -1)"
if [[ -z "$version" ]]; then
  echo "No encuentro la cabecera «Version:» en $archivo_principal" >&2
  exit 1
fi

mkdir -p "$directorio_script/salida"
destino="$directorio_script/salida/$nombre_plugin-$version.zip"
temporal="$(mktemp -d)"
trap 'rm -rf "$temporal"' EXIT

mkdir "$temporal/$nombre_plugin"
( cd "$origen" && tar --exclude='./tests' --exclude='./.git*' --exclude='*.zip' -cf - . ) \
  | ( cd "$temporal/$nombre_plugin" && tar -xf - )
rm -f "$destino"
( cd "$temporal" && zip -qr "$destino" "$nombre_plugin" )

echo "$destino"
