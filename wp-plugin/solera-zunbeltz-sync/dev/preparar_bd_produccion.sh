#!/usr/bin/env bash
# Prepara la base de datos de producción a partir del WordPress de pruebas
# (Local, http://zunbeltz-app.local) sin tocarlo: la copia a una base
# temporal, le quita los datos de prueba, cambia la dirección y la vuelca.
#
#   dev/preparar_bd_produccion.sh [dominio] [correo_admin] [carpeta_salida]
#
# Se queda: páginas (Portada/Atarikoa), tema, WPML con es/eu, entidades y
# logos, canales de noticias, ajustes. Se va: personas y tokens, tareas,
# entidades sincronizadas, actividad, noticias leídas, la APK subida (el
# fichero no viaja), sesiones, transitorios y las entradas de ejemplo.
# La contraseña del admin se cambia por una aleatoria que queda en
# <carpeta_salida>/admin.txt (permisos 600), nunca en el repo.
set -euo pipefail

dominio="${1:-app.zunbeltz.com}"
correo_admin="${2:-}"
carpeta_salida="${3:-$HOME/Documentos/zunbeltz-app/produccion/$(date +%F)}"

url_local="http://zunbeltz-app.local"
url_produccion="https://$dominio"
ruta_sitio="$HOME/Local Sites/zunbeltz-app/app/public"
socket_mysql="${SOCKET_MYSQL:-$HOME/.config/Local/run/rkYeRAqYN/mysql/mysqld.sock}"
base_origen="local"
base_temporal="zunbeltz_produccion_tmp"

mysql_local() { mysql -uroot -proot -S "$socket_mysql" "$@" 2>/dev/null; }
# wp-cli contra la base temporal: el define llega antes que el de wp-config.
wp_temporal() {
  php -d mysqli.default_socket="$socket_mysql" -d error_reporting=0 \
    "$HOME/.local/bin/wp" --path="$ruta_sitio" \
    --exec="define('DB_NAME','$base_temporal');" "$@"
}

[ -S "$socket_mysql" ] || { echo "No encuentro MySQL de Local en $socket_mysql: arranca el sitio en Local." >&2; exit 1; }
mkdir -p "$carpeta_salida"
chmod 700 "$carpeta_salida"

echo "· Copiando la base '$base_origen' a '$base_temporal'"
mysql_local -e "DROP DATABASE IF EXISTS $base_temporal; CREATE DATABASE $base_temporal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysqldump -uroot -proot -S "$socket_mysql" --single-transaction --routines "$base_origen" 2>/dev/null \
  | mysql_local "$base_temporal"
trap 'mysql_local -e "DROP DATABASE IF EXISTS $base_temporal"' EXIT

echo "· Quitando datos de prueba"
mysql_local "$base_temporal" <<'SQL'
TRUNCATE wp_solera_zunbeltz_personas;
TRUNCATE wp_solera_zunbeltz_tareas;
TRUNCATE wp_solera_zunbeltz_tareas_borradas;
TRUNCATE wp_solera_zunbeltz_entidades;
TRUNCATE wp_solera_zunbeltz_revisiones;
TRUNCATE wp_solera_zunbeltz_actividad;
TRUNCATE wp_solera_zunbeltz_noticias;
UPDATE wp_solera_zunbeltz_canales SET ultima_lectura_ms = 0, ultimo_error = '', ultimas_nuevas = 0;
DELETE FROM wp_options WHERE option_name IN ('solera_zunbeltz_apk', 'wpml_language_switcher_template_objects', 'recovery_keys')
  OR option_name LIKE '\_transient\_%' OR option_name LIKE '\_site\_transient\_%';
DELETE FROM wp_usermeta WHERE meta_key IN ('session_tokens', 'wp_dashboard_quick_press_last_post_id');
SQL

# Entradas de ejemplo de WordPress (con WPML se borran también sus traducciones).
for titulo in 'Hello world!' 'Sample Page'; do
  for id in $(wp_temporal post list --post_type=any --post_status=any --title="$titulo" --field=ID --suppress_filters=true); do
    wp_temporal post delete "$id" --force >/dev/null
  done
done
wp_temporal post delete $(wp_temporal post list --post_type=revision --field=ID --format=ids) --force >/dev/null 2>&1 || true

echo "· Cambiando $url_local → $url_produccion"
wp_temporal search-replace "$url_local" "$url_produccion" --all-tables --precise --skip-columns=guid --report-changed-only
wp_temporal search-replace "zunbeltz-app.local" "$dominio" --all-tables --precise --skip-columns=guid --report-changed-only
wp_temporal search-replace "$ruta_sitio" "" --all-tables --precise --report-changed-only

echo "· Ajustes de producción"
wp_temporal option update timezone_string 'Europe/Madrid' >/dev/null
wp_temporal option update gmt_offset '' >/dev/null
wp_temporal option update WPLANG 'es_ES' >/dev/null
wp_temporal option update date_format 'j/m/Y' >/dev/null
wp_temporal option update time_format 'H:i' >/dev/null
clave_admin="$(head -c 32 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 24)"
login_admin="$(wp_temporal user get 1 --field=user_login)"
wp_temporal user update 1 --user_pass="$clave_admin" --skip-email >/dev/null
if [ -n "$correo_admin" ]; then
  # Por SQL: wp-cli avisaría por correo del cambio.
  mysql_local "$base_temporal" -e "UPDATE wp_users SET user_email = '$correo_admin' WHERE ID = 1;
    UPDATE wp_options SET option_value = '$correo_admin' WHERE option_name = 'admin_email';
    DELETE FROM wp_options WHERE option_name = 'new_admin_email';"
fi

# WPML guarda la ruta local de sus plantillas cada vez que carga; se rehace
# solo en el servidor.
mysql_local "$base_temporal" -e "DELETE FROM wp_options WHERE option_name = 'wpml_language_switcher_template_objects' OR option_name LIKE 'wpml\\_notices%'
  OR option_name LIKE '\\_transient\\_%' OR option_name LIKE '\\_site\\_transient\\_%';"

restos="$(mysqldump -uroot -proot -S "$socket_mysql" --skip-extended-insert "$base_temporal" 2>/dev/null \
  | grep -o -e '.\{80\}zunbeltz-app.local.\{40\}' -e '.\{80\}Local Sites.\{40\}' || true)"
[ -z "$restos" ] || { printf 'Quedan restos de la dirección o la ruta local:\n%s\n' "$restos" >&2; exit 1; }

fichero_sql="$carpeta_salida/zunbeltz-produccion-$(date +%F).sql.gz"
mysqldump -uroot -proot -S "$socket_mysql" --single-transaction --default-character-set=utf8mb4 \
  --no-tablespaces "$base_temporal" 2>/dev/null | gzip -9 > "$fichero_sql"
umask 077
printf 'Admin de %s\nUsuario: %s\nContraseña: %s\n' "$url_produccion/wp-admin/" "$login_admin" "$clave_admin" > "$carpeta_salida/admin.txt"

echo "✓ $fichero_sql ($(du -h "$fichero_sql" | cut -f1))"
echo "✓ Acceso de admin en $carpeta_salida/admin.txt"
