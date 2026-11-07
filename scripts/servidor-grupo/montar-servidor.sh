#!/usr/bin/env bash
# Deja el WordPress de un grupo listo para una app social (hoy, Concejo):
# comprueba requisitos, instala y activa el plugin y verifica que la API
# responde. NUNCA crea personas, ni genera códigos, ni toca las tablas del
# plugin: activarlo crea o actualiza sus tablas, y nada más.
#
#   ./montar-servidor.sh --wp <ruta-de-wordpress> --url <https://…> [opciones]
#
# Opciones:
#   --plugin <nombre>     plugin de social/wp-plugin/ (por defecto: concejo)
#   --zip <archivo.zip>   instala desde este zip (si no, lo empaqueta del repo)
#   --solo-comprobar      no cambia nada: solo diagnostica
#   --php <binario>       PHP con el que lanzar WP-CLI (p. ej. el de Local)
#   --php-ini <php.ini>   php.ini para ese PHP (Local: ~/.config/Local/run/<id>/conf/php/php.ini)
#   --wp-cli <ruta>       WP-CLI (por defecto: `wp` del PATH)
#
# Salida: 0 si todo está bien, 1 si hay algún fallo, 2 si se usa mal.
set -uo pipefail

directorio_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
raiz_monorepo="$(cd "$directorio_script/../.." && pwd)"

ruta_wordpress=""
url_sitio=""
nombre_plugin="concejo"
archivo_zip=""
solo_comprobar=0
binario_php=""
php_ini=""
ruta_wp_cli="$(command -v wp || true)"

uso() { sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wp) ruta_wordpress="${2:-}"; shift 2 ;;
    --url) url_sitio="${2%/}"; shift 2 ;;
    --plugin) nombre_plugin="${2:-}"; shift 2 ;;
    --zip) archivo_zip="${2:-}"; shift 2 ;;
    --solo-comprobar) solo_comprobar=1; shift ;;
    --php) binario_php="${2:-}"; shift 2 ;;
    --php-ini) php_ini="${2:-}"; shift 2 ;;
    --wp-cli) ruta_wp_cli="${2:-}"; shift 2 ;;
    -h|--help) uso; exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; uso >&2; exit 2 ;;
  esac
done

if [[ -z "$ruta_wordpress" || -z "$url_sitio" ]]; then
  uso >&2
  exit 2
fi

fallos=0
avisos=0
bien()  { printf '  \033[32m✔\033[0m %s\n' "$*"; }
aviso() { printf '  \033[33m!\033[0m %s\n' "$*"; avisos=$((avisos + 1)); }
fallo() { printf '  \033[31m✘\033[0m %s\n' "$*"; fallos=$((fallos + 1)); }
paso()  { printf '\n%s\n' "$*"; }

# WP-CLI, con el PHP indicado si lo hay (Local trae su propio PHP y socket).
wp_cli() {
  local -a orden=()
  if [[ -n "$binario_php" ]]; then
    orden+=("$binario_php")
    [[ -n "$php_ini" ]] && orden+=(-c "$php_ini")
  fi
  orden+=("$ruta_wp_cli" --path="$ruta_wordpress" --skip-themes)
  if [[ -n "$binario_php" ]]; then
    local librerias
    librerias="$(cd "$(dirname "$binario_php")/../shared-libs" 2>/dev/null && pwd || true)"
    LD_LIBRARY_PATH="${librerias}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" "${orden[@]}" "$@"
  else
    "${orden[@]}" "$@"
  fi
}

# Compara versiones «a.b.c»: verdadero si $1 >= $2.
version_al_menos() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" == "$2" ]]
}

# Código HTTP; «000» si no hay conexión (curl ya lo escribe así).
codigo_http() {
  curl -s -o /dev/null -w '%{http_code}' -m 15 "$@" 2>/dev/null || true
}

# --------------------------------------------------------------------------
paso "1. Requisitos"

if [[ -z "$ruta_wp_cli" || ! -e "$ruta_wp_cli" ]]; then
  fallo "No encuentro WP-CLI. Instálalo (https://wp-cli.org) o pásalo con --wp-cli."
  exit 1
fi
if ! wp_cli core is-installed >/dev/null 2>&1; then
  fallo "No hay un WordPress instalado y accesible en $ruta_wordpress (¿base de datos parada? ¿falta --php/--php-ini?)."
  exit 1
fi
bien "WordPress encontrado en $ruta_wordpress"

archivo_principal="$raiz_monorepo/social/wp-plugin/$nombre_plugin/$nombre_plugin.php"
php_minimo="$(sed -n 's/^[ *]*Requires PHP:[[:space:]]*\([0-9.]*\).*/\1/p' "$archivo_principal" 2>/dev/null | head -1)"
wp_minimo="$(sed -n 's/^[ *]*Requires at least:[[:space:]]*\([0-9.]*\).*/\1/p' "$archivo_principal" 2>/dev/null | head -1)"
php_minimo="${php_minimo:-8.1}"
wp_minimo="${wp_minimo:-6.4}"

version_php="$(wp_cli eval 'echo PHP_VERSION;' 2>/dev/null)"
if version_al_menos "$version_php" "$php_minimo"; then
  bien "PHP $version_php (mínimo $php_minimo)"
else
  fallo "PHP $version_php: el plugin pide $php_minimo o más. Pídelo al hosting."
fi

version_wp="$(wp_cli core version 2>/dev/null)"
if version_al_menos "$version_wp" "$wp_minimo"; then
  bien "WordPress $version_wp (mínimo $wp_minimo)"
else
  fallo "WordPress $version_wp: el plugin pide $wp_minimo o más. Actualízalo antes."
fi

case "$url_sitio" in
  https://*) bien "La dirección usa https" ;;
  http://localhost*|http://127.0.0.1*|http://*.local|http://*.local:*)
    aviso "Dirección http en local: vale para pruebas, no para un grupo real (los códigos viajarían sin cifrar)." ;;
  *) fallo "La dirección no usa https: los códigos personales viajarían sin cifrar. Activa un certificado (Let's Encrypt suele ser gratis en el hosting)." ;;
esac

# --------------------------------------------------------------------------
paso "2. Plugin «$nombre_plugin»"

directorio_plugins="$(wp_cli plugin path 2>/dev/null)"
carpeta_plugin="$directorio_plugins/$nombre_plugin"

if wp_cli plugin is-installed "$nombre_plugin" 2>/dev/null; then
  version_instalada="$(wp_cli plugin get "$nombre_plugin" --field=version 2>/dev/null)"
  if [[ -L "$carpeta_plugin" ]]; then
    bien "Instalado ($version_instalada) como enlace a $(readlink -f "$carpeta_plugin"). No se toca: un zip borraría la carpeta enlazada."
  else
    bien "Instalado ($version_instalada). Para actualizarlo, sube el zip nuevo desde Plugins → Añadir nuevo."
  fi
elif [[ $solo_comprobar -eq 1 ]]; then
  fallo "No está instalado (modo --solo-comprobar: no lo instalo)."
else
  if [[ -z "$archivo_zip" ]]; then
    archivo_zip="$("$directorio_script/empaquetar.sh" "$nombre_plugin")" || {
      fallo "No he podido empaquetar el plugin."; exit 1; }
  fi
  if wp_cli plugin install "$archivo_zip" >/dev/null 2>&1; then
    bien "Instalado desde $(basename "$archivo_zip")"
  else
    fallo "WP-CLI no ha podido instalar $archivo_zip"
  fi
fi

if wp_cli plugin is-active "$nombre_plugin" 2>/dev/null; then
  bien "Activo"
elif [[ $solo_comprobar -eq 1 ]]; then
  fallo "Instalado pero no activo (modo --solo-comprobar: no lo activo)."
elif wp_cli plugin activate "$nombre_plugin" >/dev/null 2>&1; then
  bien "Activado (ha creado o actualizado sus tablas)"
else
  fallo "No se ha podido activar. Mira el registro de errores de PHP del hosting."
fi

# --------------------------------------------------------------------------
paso "3. Ajustes de WordPress"

estructura_enlaces="$(wp_cli option get permalink_structure 2>/dev/null)"
if [[ -n "$estructura_enlaces" ]]; then
  bien "Enlaces permanentes: $estructura_enlaces"
elif [[ $solo_comprobar -eq 1 ]]; then
  aviso "Enlaces permanentes «simples»: la app funciona, pero conviene Ajustes → Enlaces permanentes → «Nombre de la entrada»."
else
  wp_cli rewrite structure '/%postname%/' >/dev/null 2>&1 \
    && bien "Enlaces permanentes puestos a /%postname%/ (estaban en «simple»)" \
    || aviso "No he podido cambiar los enlaces permanentes."
fi

zona_horaria="$(wp_cli option get timezone_string 2>/dev/null)"
if [[ -n "$zona_horaria" && "$zona_horaria" != "UTC" ]]; then
  bien "Zona horaria: $zona_horaria (marca cuándo empieza y acaba cada fase)"
else
  aviso "Zona horaria sin ciudad (${zona_horaria:-UTC±}). Ponla en Ajustes → Generales, p. ej. Europe/Madrid: marca cuándo se abre y se cierra cada votación."
fi

if wp_cli config get DISABLE_WP_CRON >/dev/null 2>&1 \
   && [[ "$(wp_cli config get DISABLE_WP_CRON 2>/dev/null)" =~ ^(1|true)$ ]]; then
  aviso "WP-Cron está desactivado: el resumen semanal solo sale si hay un cron real que llame a wp-cron.php."
else
  bien "WP-Cron activo (en un sitio con pocas visitas, mejor un cron real que llame a wp-cron.php cada hora)"
fi

plugins_correo="$(wp_cli plugin list --status=active --field=name 2>/dev/null | grep -Ei 'smtp|mail' || true)"
if [[ -n "$plugins_correo" ]]; then
  bien "Correo: plugin activo ($(echo "$plugins_correo" | tr '\n' ' '))"
else
  aviso "No veo plugin SMTP. Si el hosting no envía correo, el resumen semanal no llegará. Pruébalo con el botón «Mandar ya» de Ajustes → $nombre_plugin."
fi

# --------------------------------------------------------------------------
paso "4. La API responde"

codigo_raiz="$(codigo_http "$url_sitio/wp-json/")"
if [[ "$codigo_raiz" == "200" ]]; then
  bien "$url_sitio/wp-json/ → 200"
else
  fallo "$url_sitio/wp-json/ → $codigo_raiz. ¿La dirección es correcta? ¿Algún plugin de seguridad bloquea la API REST?"
fi

# Sin código, la ruta del plugin tiene que existir y pedir código (401).
codigo_ruta="$(codigo_http "$url_sitio/wp-json/$nombre_plugin/v1/estado")"
case "$codigo_ruta" in
  401) bien "/wp-json/$nombre_plugin/v1/estado → 401 sin código (la ruta existe y pide código)" ;;
  404) fallo "/wp-json/$nombre_plugin/v1/estado → 404: el plugin no ha registrado sus rutas (¿está activo?)." ;;
  *)   fallo "/wp-json/$nombre_plugin/v1/estado → $codigo_ruta (se esperaba 401 sin código)." ;;
esac

# Con la cabecera Authorization: algunos hostings la quitan y la app no podría
# identificarse. Un código inventado tiene que dar 401 «código incorrecto», no
# otra cosa.
respuesta_codigo="$(curl -s -m 15 -H 'Authorization: Bearer COMPROBACION0000' \
  "$url_sitio/wp-json/$nombre_plugin/v1/estado" 2>/dev/null || true)"
if [[ "$respuesta_codigo" == *"${nombre_plugin}_codigo"* ]]; then
  bien "La cabecera Authorization llega a WordPress"
else
  aviso "No puedo confirmar que la cabecera Authorization llegue a WordPress. Si la app dice «código incorrecto» con un código bueno, añade al .htaccess: SetEnvIf Authorization \"(.*)\" HTTP_AUTHORIZATION=\$1"
fi

# --------------------------------------------------------------------------
paso "Resultado"
if [[ $fallos -gt 0 ]]; then
  echo "  $fallos fallos y $avisos avisos. Corrige los fallos y vuelve a lanzarlo."
  exit 1
fi
echo "  Todo bien ($avisos avisos)."
cat <<SIGUIENTE

Siguientes pasos (a mano, en el panel de WordPress):
  1. Ajustes → $nombre_plugin: nombre del espacio y la primera mesa.
  2. Apunta en papel el código de cada persona: no se vuelve a enseñar.
  3. En la app: dirección $url_sitio y el código.
SIGUIENTE
exit 0
