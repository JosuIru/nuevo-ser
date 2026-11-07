# Revisor de traducciones para nativos

Pasa los textos de una app (archivos ARB) a una hoja de cálculo para que una
persona nativa los revise sin tocar código, y vuelve a meter sus correcciones
en el ARB.

## Para quien revisa (asesoría lingüística)

Recibirás un archivo `.csv`. Ábrelo con LibreOffice Calc o Excel (si
LibreOffice pregunta, elige juego de caracteres **Unicode (UTF-8)** y
separador **coma**). Cada fila es un texto de la app:

| columna | qué es | ¿la tocas? |
|---|---|---|
| `clave` | nombre interno del texto | **no** |
| `es` | el original en castellano | **no** |
| `eu`, `ca`, `gl`... | la traducción actual | **sí**: corrígela aquí |
| `estado` | en qué punto está la fila | **sí** |
| `nota` | comentarios para el equipo | sí, si quieres |
| `descripcion` | contexto: dónde sale el texto | no |

**Estado.** Al recibir la hoja verás `pendiente` (hay traducción, sin
revisar), `falta` (no hay traducción) o `igual_que_es` (es idéntica al
castellano: a veces es correcto, como «OK»). Cuando des una fila por buena,
corregida o no, escribe **`revisado`**. Solo las filas `revisado` se aplican;
el resto se ignora, así que puedes entregar la hoja a medias.

**Las llaves `{...}` no se traducen.**

- `{fecha}`, `{cantidad}`, `{nombre}`... son huecos que la app rellena. Deja
  el mismo nombre, tal cual, en el lugar que pida tu lengua:
  `Debate: desde el {fecha}` → `Eztabaida: {fecha}(e)tik aurrera`.
- Los plurales tienen esta forma:
  `{cantidad, plural, =1{Una persona} other{{cantidad} personas}}`.
  Traduce solo el texto de dentro de cada `{...}` del final; deja igual
  `cantidad, plural,` y las palabras `=1`, `other`. El caso `other` es
  obligatorio; los demás (`=0`, `=1`, `one`...) puedes quitarlos o añadirlos
  si tu lengua lo necesita.
- Si una fila tiene un error en las llaves, no se aplica: el equipo te la
  devolverá señalada.

**Al guardar**, mantén el formato CSV: en LibreOffice «Mantener el formato
actual» con UTF-8; en Excel, «CSV UTF-8 (delimitado por comas)». Si Excel lo
guarda con punto y coma, también vale.

## Para desarrollo

Paquete Dart puro (sin Flutter), fuera de Melos. Desde `scripts/traducciones/`:

```bash
export PATH="$HOME/flutter/bin:$PATH"
dart pub get
dart test

# Hoja para revisar el euskera de Concejo
dart run traducciones exportar ../../social/apps/concejo/lib/l10n eu concejo_eu.csv
# Aplicar la hoja revisada (solo filas «revisado»)
dart run traducciones importar ../../social/apps/concejo/lib/l10n eu concejo_eu.csv
# Resumen por lengua: total, faltan, iguales al es, sobrantes, errores de ICU
dart run traducciones estado ../../social/apps/concejo/lib/l10n
```

`<dir_arb>` es la carpeta con los `<prefijo>_<lengua>.arb` (debe haber un
`*_es.arb`). Tras importar, regenera las traducciones de la app
(`flutter gen-l10n` o `flutter pub get`) y revisa el `git diff` del ARB.

Comportamiento de `importar`:

- Reescribe solo los valores que cambian; orden de claves, metadatos `@...`,
  indentación y escapes originales quedan intactos (una ida y vuelta sin
  cambios deja el archivo byte a byte igual). Las claves nuevas se insertan
  tras la anterior en el orden del español.
- Rechaza, y lista al final sin aplicar, las filas con: placeholders distintos
  del español, ICU mal formado, plural sin `other` o con categorías no
  válidas, `select` con casos distintos, clave desconocida, traducción vacía o
  texto `es` cambiado desde la exportación (hay que volver a exportar).
- Nunca escribe el ARB `es`. Si la lengua no tiene ARB, lo crea.
- Código de salida: 0 bien, 1 hubo filas rechazadas, 2 error, 64 mal uso.

Limitaciones v0.1: no valida que los casos de un plural sean los correctos
para cada lengua (CLDR), ni `offset:` ni el escape con apóstrofos (se tratan
como texto, igual que `gen-l10n` por defecto). La hoja debe guardarse en
UTF-8; si llega en otra codificación, `importar` se niega y lo explica.
