# Catálogos de Larrea Obrador

CSV curados que `apps/solera-obrador/tool/compilar_catalogos.dart` compila a Dart.
Convenciones de la suite: líneas `#` de comentario arriba con la fuente;
columna `revisado_por` (solo cuenta como firma humana si empieza por
`asesor:` o `persona:`; `fuente_publica` es revisión documental).

## Guía del obrador (2026-11-10)

- `guia_recetas.csv` — 10 recetas base (porcentaje panadero, harina = 100 %): hidratación (suma de
  líquidos), temperatura de masa, merma estimada, tiempos por fase, cocción, señal de hecho y notas.
  `denominacion` es un id de `denominaciones_pan.csv` (vacío si no es pan).
- `guia_recetas_ingredientes.csv` — ingredientes de cada receta en % sobre la harina; `ingrediente_id`
  es un id de `ingredientes_base.csv`. Las harinas suman 100; la masa madre es un ingrediente más.
- `guia_fichas.csv` — fichas por sección (`fermentacion`, `tiempos`, `coccion`, `harinas`, `trucos`);
  párrafos separados por `|`; `calculadora=temperatura_agua` muestra la calculadora.

Todas las filas con `fuente` y `revisado_por = revision-ia: 2026-11-10`: revisión de Claude a partir de
las fuentes citadas (BOE para el RD 308/2019 y el RD 677/2016; manuales de referencia citados por título;
King Arthur Baking y Cook's Illustrated para la temperatura del agua y la temperatura interna). **No es
firma humana** y no cuenta para el flag de catálogos. Contenido solo en castellano (v1).
Hard limits vigilados por `test/dominio/guia_obrador_test.dart`: sin promesas de salud ni nutricionales,
nada de alérgenos (los calcula la app), conservas solo remitidas, y ningún nombre que prometa una
denominación del RD 308/2019 que la receta no cumpla.
