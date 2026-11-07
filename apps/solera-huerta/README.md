# Larrea Huerta

Cuaderno de campo y de cestas para **huertas pequeñas y diversificadas**
(0,5-5 ha), ecológicas o en conversión, que venden en cestas a grupos de
consumo, en mercados y a restaurantes. Parte de la suite Larrea (Colección
Nuevo Ser). Funciona sin cobertura y en castellano, euskera, catalán y gallego
(las tres últimas en borrador).

## Qué hace

- **Parcelas y bancales** con su situación ecológica (ecológica, en
  conversión, convencional), SIGPAC, riego y ubicación GPS.
- **Plan de rotación por bancal**: aviso si una familia botánica vuelve al
  bancal antes de los años mínimos del catálogo (también contra lo ya
  planificado), familias bloqueadas y hasta cuándo, y recordatorio de
  leguminosas (Reglamento (UE) 2018/848, anexo II, parte I, 1.9.2).
- **Siembras y plantaciones** planificadas o hechas, **series escalonadas**
  (N siembras cada X días), lote de semilla y kilos previstos.
- **Cosechas** por bancal y destino (cestas, mercado, restaurante, semilla…).
- **Cestas por socio**: suscripciones (tamaño, semanal o quincenal, pausa),
  cosecha real y prevista de la semana, **propuesta de reparto** proporcional
  al tamaño (pasos de 50 g o piezas, mayor resto, turno rotatorio), cestas
  editables y entregas.
- **Insumos** con categoría del anexo (Reglamento de Ejecución (UE)
  2021/1165) y «permitido en ecológico» marcado por la persona con su
  justificante; aplicaciones y tratamientos con las columnas del RD 1311/2012.
- **Banco de semillas**: lotes propios y comprados, origen y autorización si
  la semilla no es ecológica.
- **IA** (clave propia de Anthropic): propone la plaga, enfermedad o carencia
  a partir de una foto de hoja y abre una observación (nunca un tratamiento).
- **Documentos PDF** (PROVISIONALES): cuaderno de campo para el certificador
  ecológico y hoja de cestas y reparto de la semana.
- **Ingresos y gastos** con REAGP (compensación del 12 % solo a empresarios o
  profesionales) o régimen general, ventas por canal y extracto PDF.

## Lo que no hace

No certifica nada como ecológico, no recomienda productos ni dosis, no
sustituye al organismo de control ni al asesor, no afirma que se cumpla
ninguna norma y no envía nada al SIEX. Ver `BLOQUEOS-PENDIENTES.md`.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze && flutter test
dart run tool/compilar_catalogos.dart      # content/huerta/*.csv → lib/datos/catalogos_generados/
flock /tmp/larrea-build-apk.lock flutter build apk --release
```

Las cestas viven en `lib/provisional_core/venta_directa/` hasta que el módulo
transversal T2 (venta directa) exista en `nuevo_ser_core`.

Estado, decisiones y fuentes: `CLAUDE.md`. Catálogos y su revisión:
`content/huerta/`.
