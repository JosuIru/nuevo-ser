#!/usr/bin/env bash
# Comprueba que una release nueva queda la primera tanto por versión como
# comparando la etiqueta como TEXTO, que es como la ordena GitHub.
#
# Por qué: hasta la app 0.7.0 y el plugin 1.0.0, la app, la descarga del APK
# y plugin-update-checker se quedaban con la primera release que devolvía
# GitHub, y GitHub ordena «…-0.6.9» antes que «…-0.6.10». Quien siga con una
# versión anterior no recibe una release que como texto quede por detrás
# (pasó con la 0.6.10). Así que tras la 0.7.9 viene la 0.8.0, no la 0.7.10.
#
# Uso: scripts/comprobar_orden_release.sh <prefijo-de-etiqueta> <etiqueta-nueva>
#   p. ej. scripts/comprobar_orden_release.sh solera-zunbeltz- solera-zunbeltz-0.7.3+35
# Saltarlo (cuando ya no quede nadie con versiones viejas): FORZAR_ORDEN=1
set -euo pipefail
prefijo="$1"
etiqueta_nueva="$2"
[ "${FORZAR_ORDEN:-0}" = 1 ] && exit 0

etiquetas_previas="$(gh release list -R JosuIru/nuevo-ser --limit 1000 \
  --json tagName -q '.[].tagName' </dev/null | grep -F -- "$prefijo" | grep -E "^${prefijo}[0-9]" || true)"
[ -z "$etiquetas_previas" ] && exit 0

version_de() { echo "${1#"$prefijo"}" | sed 's/+.*//'; }
version_nueva="$(version_de "$etiqueta_nueva")"
problemas=0
while read -r etiqueta_previa; do
  version_previa="$(version_de "$etiqueta_previa")"
  mayor_por_version="$(printf '%s\n%s\n' "$version_previa" "$version_nueva" | sort -V | tail -1)"
  if [ "$mayor_por_version" != "$version_nueva" ] || [ "$version_previa" = "$version_nueva" ]; then
    echo "✗ $etiqueta_nueva no es mayor que $etiqueta_previa" >&2
    problemas=1
  elif [[ ! "$etiqueta_nueva" > "$etiqueta_previa" ]]; then
    echo "✗ como texto, $etiqueta_nueva queda por detrás de $etiqueta_previa:" >&2
    echo "  las instalaciones antiguas no la verían. Sube el número anterior" >&2
    echo "  (p. ej. de 0.7.9 a 0.8.0, no a 0.7.10)." >&2
    problemas=1
  fi
done <<< "$etiquetas_previas"
exit $problemas
