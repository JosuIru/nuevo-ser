# Larrea Sagardoa

Sidra natural y txakoli para sagardotegis familiares y bodegas pequeñas, de la
suite Larrea (Colección Nuevo Ser). La cadena completa: pomarada → entrada de
fruta → prensado → kupela → txotx y botella, en castellano y euskera (catalán y
gallego en borrador).

> **Versión de prueba (F1, 2026-11-07).** Los documentos llevan el sello
> PROVISIONAL y los catálogos están sin firmar por una persona experta: ver
> `BLOQUEOS-PENDIENTES.md`.

## Qué hace

- **Pomaradas** (o viñas) con los datos que pide el pliego de la DOP Euskal
  Sagardoa: polígono, parcela, recinto, superficie, árboles, año y variedades
  (las 192 del pliego vasco y las 76 del asturiano). Ubicación con el GPS.
- **Tratamientos** para el cuaderno: plaga, sustancia activa con uso autorizado
  contra ella (registro del MAPA), n.º de registro, cantidad, aplicador, equipo
  y eficacia. La app no recomienda productos ni dosis.
- **Bodega**: entradas de fruta (propia o comprada), prensados con sus partidas,
  kupelas con lo que tienen dentro, mediciones (densidad, temperatura, acidez
  volátil, grado, SO₂), trasiegos, embotellado con contraetiquetas numeradas.
- **Txotx**: qué kupela se abre cada día y cuánto se sirve.
- **Avisos frente al pliego** de cada producto DOP (Euskal Sagardoa, Sidra de
  Asturias y las tres DO de txakoli). Avisa, no certifica.
- **IA** (clave de Anthropic de la persona): propone qué plaga se ve en una foto.
- **Documentos PDF** por campaña: cuaderno de la pomarada y libro de elaboración
  y embotellado. **Ingresos y gastos** con IVA o compensación del REAGP.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter pub get
flutter analyze
flutter test                                  # 53 tests
dart run tool/compilar_catalogos.dart          # content/sidra/*.csv → lib/datos/catalogos_generados/
dart run flutter_launcher_icons                # iconos desde assets/icono-logo-sidra.png
flock /tmp/larrea-build-apk.lock flutter build apk --release
```

Traducciones: `content/solera/traducciones/sidra.csv` (claves `sidr.*`), y
`cd ../../packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.

Estado, decisiones y siguiente paso: `CLAUDE.md`. Lo que espera a una persona:
`BLOQUEOS-PENDIENTES.md`. Encargo: `docs/plan-verticales/sidra.md`.
