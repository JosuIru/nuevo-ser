#!/usr/bin/env bash
# Compila un juego de la Colección para web y lo despliega en un
# WordPress con el plugin nuevo-ser-core (shortcode
# [nuevo_ser_juego juego="<juego>"]). El build va a
# wp-content/uploads/juegos/<juego>/, fuera del plugin (pesa decenas de MB).
#
# Uso (desde cualquier sitio):
#   bash scripts/web/desplegar.sh uno-roto        # WordPress local (uno-roto.local)
#   bash scripts/web/desplegar.sh las-versiones /ruta/a/wp-content/uploads/juegos/las-versiones
#
# El juego necesita su carpeta apps/<juego>/web/ con un
# flutter_bootstrap.js que registre sw_<juego>.js (guiones → guiones bajos).
# El audio (assets/sonido, ignorado por git) entra en el build tal como
# esté en disco: generar antes con los scripts de sonido de cada juego.
set -euo pipefail

JUEGO="${1:?Uso: desplegar.sh <juego> [carpeta destino]}"
RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
CARPETA_JUEGO="$RAIZ/apps/$JUEGO"
if [ ! -d "$CARPETA_JUEGO/web" ]; then
  echo "apps/$JUEGO no tiene carpeta web/: no está preparado para web." >&2
  exit 1
fi

DESTINO="${2:-$HOME/Local Sites/uno-roto/app/public/wp-content/uploads/juegos/$JUEGO}"
BASE_HREF="${BASE_HREF:-/wp-content/uploads/juegos/$JUEGO/}"

cd "$CARPETA_JUEGO"
export PATH="$HOME/flutter/bin:$PATH"
flutter build web --release --base-href "$BASE_HREF" --no-wasm-dry-run
# Modo sin conexión: service worker con todos los archivos del build.
python3 "$RAIZ/scripts/web/generar_sw.py" build/web "$JUEGO"
mkdir -p "$DESTINO"
rsync -a --delete build/web/ "$DESTINO/"
echo "Desplegado en: $DESTINO ($(du -sh "$DESTINO" | cut -f1))"
