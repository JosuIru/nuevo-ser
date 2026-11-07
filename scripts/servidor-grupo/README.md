# Montar el servidor del grupo

Para que un grupo (pueblo, barrio, colectivo) aloje su propio servidor de una app social sin depender de nosotros. Hoy sirve para **Concejo**; vale para cualquier plugin de `social/wp-plugin/<nombre>/` con rutas `/<nombre>/v1/estado`.

| Archivo | Qué hace |
|---|---|
| `empaquetar.sh [concejo]` | Zip del plugin (sin `tests/`) en `salida/concejo-<versión>.zip`, para subirlo desde el panel |
| `montar-servidor.sh` | Comprueba requisitos, instala y activa el plugin y verifica la API (incluida la cabecera `Authorization`) |
| `guia-servidor-grupo.html` | Guía en papel para quien no programa; `generar-guia-pdf.sh` la pasa a `salida/guia-servidor-grupo.pdf` |

```bash
# Diagnóstico sin cambiar nada (lo que se usa en apps.local, que tiene datos vivos)
./montar-servidor.sh --solo-comprobar --wp "$HOME/Local Sites/apps/app/public" --url http://127.0.0.1:10114 \
  --php ~/.config/Local/lightning-services/php-8.2.27+1/bin/linux/bin/php \
  --php-ini ~/.config/Local/run/raty3SQ48/conf/php/php.ini

# Instalación en un WordPress con WP-CLI
./montar-servidor.sh --wp /ruta/a/wordpress --url https://concejo.ejemplo.org
```

## Qué hace y qué no

- **Sí:** instala el plugin desde un zip si no está, lo activa (lo que crea o actualiza sus tablas), pone los enlaces permanentes a `/%postname%/` si están en «simple», y comprueba PHP, versión de WordPress, https, zona horaria, WP-Cron, plugin de correo y que `/wp-json/<plugin>/v1/estado` responde 401 sin código.
- **No:** nunca crea personas, ni genera códigos, ni vacía o modifica tablas del plugin. La primera mesa se da de alta a mano en Ajustes → Concejo (el código se entrega en papel).
- Si el plugin ya está instalado como **enlace al repo** (los WordPress de pruebas), no lo toca: subir un zip borraría la carpeta enlazada.
- Es idempotente: lanzarlo dos veces no cambia nada la segunda.

Probado el 2026-11-07 en `apps.local` (solo `--solo-comprobar`) y en un WordPress 7.1 desechable con SQLite (instalación completa y segunda pasada).
