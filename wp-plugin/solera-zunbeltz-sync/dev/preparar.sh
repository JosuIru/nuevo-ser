#!/usr/bin/env bash
# Instala WordPress en el contenedor, activa el plugin y crea dos personas de
# prueba (coordinación y tester). Sus tokens quedan en dev/.tokens (fuera de
# git). Contraseña del admin local en dev/.admin.
set -euo pipefail
cd "$(dirname "$0")"
wp() { docker compose run --rm -T cli "$@"; }

until wp db check >/dev/null 2>&1; do sleep 2; done
if ! wp core is-installed >/dev/null 2>&1; then
  clave_admin="$(head -c 18 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 20)"
  wp core install --url=http://localhost:8790 --title="Zunbeltz (local)" \
    --admin_user=admin --admin_password="$clave_admin" --admin_email=admin@zunbeltz.test --skip-email
  echo "$clave_admin" > .admin
fi
wp rewrite structure '/%postname%/' >/dev/null
wp plugin activate solera-zunbeltz-sync >/dev/null

if [ ! -s .tokens ]; then
  wp eval '
    $coordinacion = szs_crear_persona( "Pablo (coordinación)", "coordinador" );
    $tester       = szs_crear_persona( "Ane (tester)", "tester" );
    echo "COORDINACION=$coordinacion\nTESTER=$tester\n";
  ' > .tokens
fi
echo "WordPress listo en http://localhost:8790 — tokens en dev/.tokens"
