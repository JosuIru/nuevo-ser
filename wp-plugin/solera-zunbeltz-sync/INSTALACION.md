# Solera Zunbeltz — instalación del servidor

Guía para poner en marcha el servidor de la app en el **WordPress propio de Zunbeltz**, en un subdominio de su servidor (por ejemplo `app.zunbeltz.com`). El WordPress solo sirve a la app y al panel de la oficina: no es la web pública.

## 1. Lo que hace falta del hosting

- **PHP 8.1 o superior** y **MySQL 5.7+ / MariaDB 10.3+** (lo normal en cualquier hosting actual).
- Poder **crear un subdominio** y su **certificado HTTPS** (Let's Encrypt, gratuito en casi todos los paneles). Sin HTTPS los tokens viajarían en claro: **no se pone en marcha sin HTTPS**.
- **Envío de correo** desde el WordPress (SMTP del hosting o un plugin de SMTP como *WP Mail SMTP*) para el resumen diario y las alarmas.
- Recomendable: una **tarea cron** del sistema que llame a `wp-cron.php` cada 15 minutos, para que el correo de las 8:00 salga aunque nadie visite la web:
  `*/15 * * * * curl -s https://app.zunbeltz.com/wp-cron.php?doing_wp_cron >/dev/null`
  y en `wp-config.php`: `define( 'DISABLE_WP_CRON', true );`

## 2. WordPress nuevo en el subdominio

1. Crear el subdominio y activar su certificado HTTPS.
2. Instalar WordPress (instalador del panel del hosting o manual). Idioma: español.
3. Ajustes → Enlaces permanentes → «Nombre de la entrada» (la API de la app usa `/wp-json/`).
4. Opcional: Ajustes → Lectura → «Pide a los motores de búsqueda que no indexen este sitio».

## 3. Instalar el plugin

1. Generar el paquete: `wp-plugin/solera-zunbeltz-sync/dev/empaquetar.sh` (crea `solera-zunbeltz-sync-<versión>.zip`).
2. En el WordPress: Plugins → Añadir nuevo → Subir plugin → el `.zip` → Activar.
3. Aparece el menú **Solera Zunbeltz** (Tareas, Peticiones, Avisos, Proyectos, Actividad, Personas).

Actualizar: subir el `.zip` nuevo (WordPress ofrece reemplazar la versión instalada). Las tablas se actualizan solas y no se pierde nada.

## 4. Personas y tokens

En **Solera Zunbeltz → Personas**:

1. Crear primero las personas de **coordinación** (dinamizador, responsable de finca…). Al crear cada una se muestra su **token una sola vez**: entregárselo en mano o por un canal seguro.
2. **Enlazar** cada persona de coordinación con su **usuario de WordPress** y poner su **correo**. Así puede entrar al panel de la oficina sin ser administradora del WordPress, lo que haga queda a su nombre y recibe los correos.
3. Crear las personas **tester** (una por persona) y entregarles su token.
4. Si alguien pierde el móvil o deja el espacio: «Nuevo token» o «Desactivar».

## 5. Configurar la app en cada móvil

App → **Ajustes → Sincronización**:

- **WordPress de Zunbeltz**: la dirección que muestra la página Personas (p. ej. `https://app.zunbeltz.com`).
- **Token personal**: el de esa persona.

**La primera en sincronizar debe ser coordinación**, desde el móvil donde estén las fincas y los puntos: así llegan al servidor y, de ahí, a todos. Después, cada tester configura su móvil y recibe el espacio.

## 6. La app web, en el mismo WordPress

El plugin sirve también la **versión web de la app** en `https://app.zunbeltz.com/app/` (menú Solera Zunbeltz → «Abrir la app»). Sirve para la oficina (desde el PC) y para que las testers la prueben sin instalar nada.

- Va dentro del `.zip` si se compiló antes de empaquetar: `dev/construir_app_web.sh` y luego `dev/empaquetar.sh`.
- Al abrirla desde `/app/`, la app ya sabe cuál es su servidor: en Ajustes → Sincronización solo hay que poner el **token**.
- Los datos se guardan en el navegador y se sincronizan con el servidor como en el móvil. Las fotos no se pueden adjuntar desde la web.
- Si el WordPress está en una subcarpeta (p. ej. `/espacio`), compilar con `dev/construir_app_web.sh /espacio/app/`.

Para una **demo sin servidor** (datos de ejemplo, solo en ese navegador) está `apps/solera-zunbeltz/tool/construir_demo_web.sh`.

## 6-bis. Portada bilingüe (tema y WPML)

La entrada del WordPress es el tema **Zunbeltz Espacio** (`wp-theme/zunbeltz-espacio`, ver su `LEEME.md`):

1. Instalar **WPML** (Multilingual CMS + String Translation). Hace falta **licencia de WPML a nombre de Zunbeltz** para el servidor real; alternativa gratuita: Polylang (habría que adaptar el tema, que usa los filtros de WPML).
2. Asistente de WPML: castellano por defecto, euskera como segundo idioma, idiomas en directorios (`/eu/`).
3. Subir y activar el tema: crea la «Portada» y su traducción «Atarikoa» y las deja como página de inicio.

## 7. Copias de seguridad y datos personales

- **Copias**: base de datos completa del WordPress (las tablas `*_solera_zunbeltz_*`) al menos a diario, con el sistema del hosting o un plugin de copias.
- **RGPD**: el servidor guarda datos de las personas tester (proyectos, cuentas, incidencias de cumplimiento). Responsable del tratamiento: Zunbeltz Elkartea. Hace falta informarles y recoger su consentimiento (puede ir en el propio convenio) y limitar quién entra al panel. Las incidencias de cumplimiento solo las ven coordinación y la persona afectada.

## 8. Comprobar que todo funciona

- Entrar a `https://app.zunbeltz.com/wp-json/solera-zunbeltz/v1/yo` sin token debe dar **401** (la API está viva y protegida).
- En la app, «Sincronizar ahora» debe decir «… cambios enviados · … recibidos».
- En el panel, **Actividad** debe mostrar lo que se acaba de sincronizar.
