#!/usr/bin/env bash
# Construye la versión web de demostración de Solera Zunbeltz en build/web.
#
#   tool/construir_demo_web.sh            # para servirla en la raíz del dominio
#   tool/construir_demo_web.sh /app/      # para servirla bajo /app/
#   tool/construir_demo_web.sh / https://app.zunbeltz.com
#                                         # y que enseñe las noticias del
#                                         # sector de ese WordPress
#
# Servida desde el propio WordPress en /app/ no hace falta el servidor: lo
# deduce de la dirección.
# En la demo los datos de ejemplo se cargan solos la primera vez y una franja
# avisa de que todo se guarda solo en ese navegador (ver
# lib/estado/version_demo.dart). Los recursos de Flutter (CanvasKit) se
# sirven desde el propio servidor, no desde el CDN de Google.
set -euo pipefail

ruta_base="${1:-/}"
servidor_noticias="${2:-}"
directorio_app="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/flutter/bin:$PATH"

cd "$directorio_app"
flutter build web --release \
  --no-wasm-dry-run \
  --no-web-resources-cdn \
  --base-href "$ruta_base" \
  --dart-define=SOLERA_DEMO=true \
  --dart-define=SOLERA_DEMO_SERVIDOR="$servidor_noticias"

echo "Demo web lista en $directorio_app/build/web (base: $ruta_base)"
