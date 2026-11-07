# Larrea Aromáticas

Cuaderno de campo para productores pequeños de **plantas aromáticas** (lavanda,
lavandín, romero, tomillo, salvia, orégano…) en **cultivo** o en **recolección
silvestre**, que secan, venden planta seca o **destilan aceite esencial e
hidrolato**. Parte de la suite Larrea (Colección Nuevo Ser). Funciona sin
cobertura y en castellano, euskera, catalán y gallego (las tres últimas en
borrador).

## Qué hace

- **Parcelas** de cultivo (especie, SIGPAC, ecológico, GPS) y **zonas de
  recolección silvestre** con su permiso: número, órgano, vigencia, especies
  y límite de kg. Mapa de las dos.
- **Cosechas** de parcela o de zona: kg frescos, floración, parte, recolector.
  En silvestre, avisos frente al permiso (sin permiso, fuera de fechas,
  especie no incluida, límite superado, especie protegida, especies con las
  que se confunde). Los avisos no bloquean.
- **Taller**: secado (kg frescos → kg secos) y destilación (kg de planta → ml
  de aceite esencial + l de hidrolato, con la estructura de la molturación de
  aceitera), con rendimientos comparados con los orientativos del CTFC.
- **Lotes** con trazabilidad hasta la parcela o la zona y su permiso, destino
  (sin decidir, alimentario, cosmético, otros usos) y **pasaporte** con QR.
- **IA** (clave propia de Anthropic): propone la especie (nunca habilita el
  consumo) o la plaga en cultivo (nunca propone tratamientos).
- **Documentos PDF** (PROVISIONALES): cuaderno de cosechas y recolección, y
  libro de destilación y lotes.
- **Ingresos y gastos** con REAGP solo para la venta de planta (la destilación
  puede ser transformación: por verificar), margen por parcela y extracto PDF.

## Lo que no hace

Ninguna propiedad medicinal ni terapéutica en ningún texto (hay un test que lo
vigila). No decide si hace falta permiso ni si una recolección es legal: eso
lo fija cada comunidad autónoma. No anima a recolectar especies protegidas.
No genera etiquetas de venta ni CLP, no recomienda productos ni dosis y no
afirma que se cumpla ninguna norma. Ver `CLAUDE.md` (normativa con enlaces) y
`BLOQUEOS-PENDIENTES.md`.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze && flutter test
dart run tool/compilar_catalogos.dart      # content/aromaticas/*.csv → lib/datos/catalogos_generados/
```
