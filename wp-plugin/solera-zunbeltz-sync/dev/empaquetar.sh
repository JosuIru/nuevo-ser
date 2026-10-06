#!/usr/bin/env bash
# Genera solera-zunbeltz-sync-<versión>.zip listo para «Plugins → Añadir
# nuevo → Subir plugin», sin el entorno de pruebas ni los tests.
set -euo pipefail
cd "$(dirname "$0")/.."
version="$(grep -o "define( 'SZS_VERSION', '[^']*'" solera-zunbeltz-sync.php | sed "s/.*'\(.*\)'/\1/")"
destino="${1:-$PWD/dev}"
temporal="$(mktemp -d)"
trap 'rm -rf "$temporal"' EXIT
mkdir -p "$temporal/solera-zunbeltz-sync"
cp -r solera-zunbeltz-sync.php includes INSTALACION.md "$temporal/solera-zunbeltz-sync/"
( cd "$temporal" && zip -qr "solera-zunbeltz-sync-$version.zip" solera-zunbeltz-sync )
mv "$temporal/solera-zunbeltz-sync-$version.zip" "$destino/"
echo "$destino/solera-zunbeltz-sync-$version.zip"
