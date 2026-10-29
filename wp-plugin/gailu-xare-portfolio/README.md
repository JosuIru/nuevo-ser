# Plugin · Gailu Xare Portfolio

CPTs + shortcodes para convertir cualquier WordPress en un **portfolio + hub de descargas** del ecosistema Gailu (operador Josu Iru). Diseñado para usarse con el tema [`gailu-xare`](../../wp-theme/gailu-xare/), aunque cualquier tema que pueda renderizar shortcodes vale.

## Qué aporta

### Dos Custom Post Types

| CPT | Para qué | Campos |
|---|---|---|
| **Gailu · Proyectos** (`gxare_proyecto`) | Una entrada por trabajo: app, plugin, theme, servicio | nombre, subtítulo, descripción, audiencia, estado (esqueleto/MVP/producción/maduro/mantenimiento), tipo, tech stack, marca/línea, URLs (web, repo, demo), color de acento, ¿destacado?, imagen destacada (logo) |
| **Gailu · Descargas** (`gxare_descarga`) | Una entrada por release descargable: APK, plugin/theme zip, ZIP estático | proyecto asociado (por slug), versión, fecha, plataforma (android/wp/linux/web/ios), URL, peso, SHA-256, notas de release |

### Dos shortcodes

- `[gxare_proyectos]` — grid de proyectos con tarjetas. Atributos opcionales:
  - `marca` — filtra por línea ("Cuadernos de Campo", "Larrea", "Flavor")
  - `tipo` — filtra por tipo (`app`, `plugin`, `theme`, `servicio`, `libreria`)
  - `destacado` — `1` para mostrar solo destacados
  - `limite` — número máximo (`-1` = todos)
- `[gxare_descargas]` — lista de descargas. Atributos opcionales:
  - `proyecto` — slug del proyecto asociado
  - `plataforma` — `android`, `wp`, `linux`, `web`, `ios`
  - `limite` — máximo

## Seed inicial

Al activar el plugin se publican automáticamente:

- **11 proyectos**: Fósiles + Naturaleza (Cuadernos de Campo) · agro + 5 verticales (Larrea) · Flavor Platform + News Hub + Chat IA.
- **4 descargas**: Fósiles 1.0.14+15, Naturaleza 1.0, Flavor Platform 3.5.13, Flavor News Hub 0.16.6.

Idempotente vía meta `gxare_seed_id`: si los borras a mano y los reactivas no duplica nada salvo que rebajes el meta.

## Instalación

1. Copiar el directorio `gailu-xare-portfolio/` a `wp-content/plugins/` del WordPress de destino.
2. Activar desde `wp-admin → Plugins`.
3. (Opcional) Activar también el tema [`gailu-xare`](../../wp-theme/gailu-xare/) para el frontend del portfolio. Con cualquier otro tema, simplemente coloca `[gxare_proyectos]` y `[gxare_descargas]` en una página.

## Convivencia con otros plugins Flavor

El plugin **no comparte prefijo** con `flavor-platform`, `flavor-news-hub` ni `flavor-landing`:

- Prefijos PHP: `gxare_*`
- CPTs: `gxare_proyecto`, `gxare_descarga`
- Meta keys: `gxare_proyecto_*`, `gxare_descarga_*`
- Shortcodes: `gxare_*`

Puedes activarlo junto a cualquier combinación de plugins Flavor sin colisión.

## Licencia

GPL-2.0-or-later.
