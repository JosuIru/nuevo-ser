#!/usr/bin/env bash
# Compila Uno Roto para web y lo despliega en un WordPress con el plugin
# nuevo-ser-core (shortcode [uno_roto]). El build va a
# wp-content/uploads/juegos/uno-roto/, fuera del plugin (pesa ~50 MB).
#
# Uso (desde apps/uno-roto/):
#   bash scripts/web/desplegar.sh                 # WordPress local (uno-roto.local)
#   bash scripts/web/desplegar.sh /ruta/a/wp-content/uploads/juegos/uno-roto
#
# El audio (assets/sonido, ignorado por git) entra en el build tal como
# esté en disco: generar antes con los scripts de scripts/sonido/.
set -euo pipefail

DESTINO="${1:-$HOME/Local Sites/uno-roto/app/public/wp-content/uploads/juegos/uno-roto}"
BASE_HREF="${BASE_HREF:-/wp-content/uploads/juegos/uno-roto/}"

cd "$(dirname "$0")/../.."
export PATH="$HOME/flutter/bin:$PATH"
flutter build web --release --base-href "$BASE_HREF" --no-wasm-dry-run
# Modo sin conexión: service worker con todos los archivos del build.
python3 scripts/web/generar_sw.py build/web
mkdir -p "$DESTINO"
rsync -a --delete build/web/ "$DESTINO/"
echo "Desplegado en: $DESTINO ($(du -sh "$DESTINO" | cut -f1))"
