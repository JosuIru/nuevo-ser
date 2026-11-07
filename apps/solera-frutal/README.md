# Larrea Frutal

Cuaderno de campo para explotaciones pequeñas y medianas de **almendro,
avellano, nogal, castaño, pistachero y frutal de hueso y pepita**. Parte de la
suite Larrea (Colección Nuevo Ser). Funciona sin cobertura y en castellano,
euskera, catalán y gallego (las tres últimas en borrador).

## Qué hace

- **Parcelas** con especie, variedad, marco (árboles/ha), SIGPAC, secano o
  regadío y ubicación GPS; **filas** por variedad con sus polinizadoras.
- **Polinización**: aviso si una variedad necesita polinizadora y no la tiene
  (orientación del catálogo) y **colmenas** del apicultor (código REGA) por ha.
- **Cuaderno**: tratamientos (sustancia activa del catálogo, producto y dosis
  copiados de la etiqueta), abonados, riegos, heladas y pedrisco, y
  **seguimiento de plagas** con el umbral de la guía de gestión integrada.
- **Cosecha**: kilos en cáscara, rendimiento en grano, calibre y humedad por
  parcela y campaña; aviso si se cosecha dentro de un plazo de seguridad.
- **Avisos de helada** (previsión de 7 días × calendario fenológico).
- **IA** (clave propia de Anthropic): propone la plaga a partir de una foto.
- **Documentos PDF** (PROVISIONALES): cuaderno de explotación (orden y códigos
  del modelo de Andalucía v8) y parte de cosecha y rendimientos.
- **Ingresos y gastos** con REAGP (compensación del 12 %) o régimen general,
  margen por parcela y extracto PDF (PROVISIONAL).

## Lo que no hace

No recomienda productos ni dosis, no sustituye al asesor, no afirma que se
cumpla ninguna norma y no envía nada al SIEX (el registro electrónico de
tratamientos es obligatorio desde el 1-1-2027). Ver `BLOQUEOS-PENDIENTES.md`.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze && flutter test
dart run tool/compilar_catalogos.dart      # content/frutal/*.csv → lib/datos/catalogos_generados/
flock /tmp/larrea-build-apk.lock flutter build apk --release
```

Estado, decisiones y fuentes: `CLAUDE.md`. Catálogos y su revisión:
`content/frutal/` y `content/frutal/revision-2026-11-07.md`.
