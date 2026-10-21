# Zunbeltz Espacio — tema de WordPress

Tema de bloques para el WordPress de la herramienta del Espacio Test Zunbeltz (el que lleva el plugin `wp-plugin/solera-zunbeltz-sync`). La portada es la **entrada**: presenta la herramienta y lleva a la **app web** (`/app/`), a la **descarga para Android** y a la **oficina de coordinación**.

- Identidad de **zunbeltz.com** (con permiso de Zunbeltz): verdes `#004331` / `#25AC74` / `#E6EEEA`, fondo `#fafaf9`, Poppins para títulos e Inter para texto. Tipografías **alojadas en el tema** (`assets/fuentes/`, SIL OFL), sin Google Fonts.
- **Bilingüe castellano / euskera con WPML** (o sin él, todo en castellano):
  - La portada es una **página** («Portada», castellano) con su traducción («Atarikoa», euskera, en `/eu/`), editables en Gutenberg y enlazadas en WPML. Se crean solas al activar el tema; a mano: `wp eval 'zunbeltz_espacio_crear_portadas();'`. Su contenido inicial sale de `patterns/portada-es.php` y `patterns/portada-eu.php`. **Cambiar el patrón no cambia la página ya creada**: al actualizar el tema, si la portada conserva textos viejos, sale un aviso en Escritorio y en Apariencia → Temas con el botón «Actualizar las portadas con los textos nuevos» (pisa lo editado a mano; también `wp eval 'zunbeltz_espacio_rehacer_portadas();'`).
  - Cabecera (con selector **ES · EU**), pie y 404 cambian de idioma solos (`zunbeltz_espacio_texto()`).
  - El botón de la app en euskera abre `/app/?lang=eu` y la app arranca en euskera.
- **Logos de las entidades** (impulsan, con el apoyo económico de, colaboran, miembro de) en el pie, con el bloque «Entidades y logos» del plugin (`solera-zunbeltz/entidades`; en una página vale también el shortcode `[solera_zunbeltz_entidades]`). Se editan en **Solera Zunbeltz → Entidades y logos**; sin el plugin, el pie sale sin ellos.
- En el pie, **«Sobre el proyecto»** enlaza la presentación de la herramienta que sirve el plugin en `/presentacion/` (sin el plugin, no sale).
- **El euskera es borrador pendiente de revisión nativa.**

Instalar: copiar o enlazar `wp-theme/zunbeltz-espacio` en `wp-content/themes/`, activar WPML (castellano por defecto, euskera, idiomas en directorios) y activar el tema en Apariencia → Temas.
