# Concejo — plugin de WordPress

Servidor de la app Concejo (`social/apps/concejo/`) para un pueblo, barrio o colectivo. Cada pueblo lo instala en su propio WordPress. Va aparte del plugin de Zunbeltz a propósito: no comparte código con un servidor en producción.

## Poner en marcha un pueblo

1. Subir la carpeta a `wp-content/plugins/concejo/` y activarla (crea sus tablas).
2. **Ajustes → Concejo**: nombre del espacio y la primera mesa (rol *Mesa* con fecha de fin de mandato). Al añadir a alguien sale su código: apuntarlo y dárselo en papel, porque no se vuelve a enseñar.
3. En la app: dirección del WordPress y el código. Desde ahí la mesa da de alta al resto y saca sus códigos (pantalla Personas).

La zona horaria del pueblo es la de WordPress (Ajustes → Generales): marca cuándo empieza y acaba cada fase.

## Resumen semanal por correo

Los lunes (WP-Cron, que se dispara con las visitas; en un sitio con poco tráfico conviene un cron real que llame a `wp-cron.php`) sale un correo en texto plano a quien tiene correo en Ajustes → Concejo y lo quiere: qué se decide y hasta cuándo, qué está en debate, las asambleas de las dos próximas semanas, lo decidido esta semana, el tablón (lo fijado y lo que otras personas han puesto esta semana) y los compromisos que vencen. Si no hay nada, no se manda. En Ajustes → Concejo hay una vista previa y un botón para mandarlo ya. Usa `wp_mail`: el WordPress tiene que saber enviar correo (un plugin SMTP si el hosting no lo hace).

## Pruebas

Sin WordPress, sobre la lógica pura:

```bash
for t in tests/test_*.php; do php "$t"; done
```

`tests/paridad.json` lo genera la app (`test/paridad_servidor_test.dart`); si falla `test_paridad.php`, una regla está distinta en la app y aquí.

### Contra un WordPress desechable (SQLite, sin tocar otros sitios)

```bash
D=/tmp/wp-concejo && mkdir -p $D && cd $D
wp core download
curl -sLO https://downloads.wordpress.org/plugin/sqlite-database-integration.zip
unzip -q sqlite-database-integration.zip -d wp-content/plugins
cp wp-content/plugins/sqlite-database-integration/db.copy wp-content/db.php
sed -i "s#{SQLITE_IMPLEMENTATION_FOLDER_PATH}#$D/wp-content/plugins/sqlite-database-integration#; s#{SQLITE_PLUGIN}#sqlite-database-integration/load.php#" wp-content/db.php
wp config create --dbname=x --dbuser=x --dbpass=x --skip-check
wp core install --url=http://localhost:8765 --title=Prueba --admin_user=admin --admin_password=admin --admin_email=a@example.com --skip-email
ln -s <monorepo>/social/wp-plugin/concejo wp-content/plugins/concejo
wp plugin activate concejo && wp rewrite structure '/%postname%/'
wp server --port=8765
```

Para cargar el pueblo de ejemplo y sacar códigos, `wp eval-file` con `concejo_estado_desde_instantanea()` sobre `tests/paridad.json` (`inicial`) y `concejo_nuevo_codigo('ane')`. Después, desde la app:

```bash
CONCEJO_SERVIDOR=http://localhost:8765 CONCEJO_CODIGO_MESA=… CONCEJO_CODIGO_VECINA=… \
  flutter test test/servidor/servidor_real_test.dart
```
