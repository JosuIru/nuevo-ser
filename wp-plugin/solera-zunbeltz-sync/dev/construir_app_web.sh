#!/usr/bin/env bash
# Compila la versión web de la app (apps/solera-zunbeltz) dentro del plugin,
# en app-web/, para que el WordPress la sirva en /app/.
#
#   dev/construir_app_web.sh              # WordPress en la raíz del dominio
#   dev/construir_app_web.sh /espacio/app/ # WordPress en /espacio
set -euo pipefail
plugin="$(cd "$(dirname "$0")/.." && pwd)"
app="$plugin/../../apps/solera-zunbeltz"
ruta_base="${1:-/app/}"
export PATH="$HOME/flutter/bin:$PATH"

cd "$app"
flutter build web --release \
  --no-wasm-dry-run \
  --no-web-resources-cdn \
  --base-href "$ruta_base" \
  -o "$plugin/app-web"
echo "App web lista en $plugin/app-web (se sirve en $ruta_base)"
