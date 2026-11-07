#!/usr/bin/env bash
# Convierte guia-servidor-grupo.html en salida/guia-servidor-grupo.pdf (A4)
# con Chrome o Chromium sin ventana.
set -euo pipefail
directorio_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
navegador="$(command -v google-chrome || command -v chromium || command -v chromium-browser || true)"
if [[ -z "$navegador" ]]; then
  echo "Necesito Chrome o Chromium. También vale abrir el HTML y «Imprimir → Guardar como PDF»." >&2
  exit 1
fi
mkdir -p "$directorio_script/salida"
destino="$directorio_script/salida/guia-servidor-grupo.pdf"
"$navegador" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$destino" "file://$directorio_script/guia-servidor-grupo.html" 2>/dev/null
echo "$destino"
