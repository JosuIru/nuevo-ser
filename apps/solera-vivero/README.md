# Larrea Vivero

Cuaderno de vivero para viveros pequeños y medianos de planta **hortícola,
forestal, frutal y ornamental**, incluidos los de semilla local y los de
reforestación comunitaria. Parte de la suite Larrea (Colección Nuevo Ser).
Funciona sin cobertura y en castellano, euskera, catalán y gallego (las tres
últimas en borrador).

## Qué hace

- **Trazabilidad de la semilla o la estaquilla a la planta vendida**: lotes de
  material (proveedor, ROPVEG, pasaporte con el que llegó; categoría y región de
  procedencia si es material forestal), siembras en bandejas, partidas de planta
  con su código, mermas y repicados enlazados, y la cadena completa en la ficha.
- **Bandejas con QR**: código propio, hoja de etiquetas para imprimir y escáner
  que abre la ficha de la bandeja (patrón de Arbolado urbano).
- **Stock** por especie, variedad y formato, con lo que está listo para venta.
- **Salidas** con la orientación de si necesitan **pasaporte fitosanitario**
  (usuario final, venta a distancia, zona protegida, traslado propio) y los
  **datos del pasaporte** (letras A-D) guardados y en **etiqueta PDF** con el
  formato del Reglamento de Ejecución (UE) 2017/2313. Registro de pasaportes
  con anulación (nunca se borran).
- **Cuaderno**: tratamientos fitosanitarios (sustancias activas del registro
  por grupo de cultivo; producto y dosis copiados de la etiqueta) e
  **inspecciones de plagas reguladas** con aviso a la autoridad pendiente.
- **Catálogos**: especies con pasaporte y anexo XIV, plagas reguladas
  (prioritarias y RNQP), plagas de vivero y 126 sustancias activas.
- **IA** (clave propia de Anthropic): propone la plaga a partir de una foto y
  abre una inspección; nunca un tratamiento.
- **Documentos PDF** (PROVISIONALES): cuaderno de tratamientos (cotejado con el
  anexo III del RD 1311/2012) y registro de pasaportes y trazabilidad (RD
  1054/2021, art. 20).
- **Ingresos y gastos** con REAGP o régimen general; las ventas salen de las
  salidas con importe (PROVISIONAL).
- **Zonas** (naves, invernaderos, umbráculos, parcelas exteriores) con GPS y mapa.

## Lo que no hace

No expide pasaportes en nombre de nadie (prepara los datos para el operador
autorizado), no da por sana ninguna partida, no recomienda productos ni dosis,
no sustituye al asesor, no afirma que se cumpla ninguna norma y no envía nada a
la administración. Ver `BLOQUEOS-PENDIENTES.md`.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze && flutter test
dart run tool/compilar_catalogos.dart      # content/vivero/*.csv → lib/datos/catalogos_generados/
dart run flutter_launcher_icons            # si cambia el logo
flock /tmp/larrea-build-apk.lock flutter build apk --release
```

Estado, decisiones y normativa con enlaces: `CLAUDE.md`. Catálogos y su
revisión: `content/vivero/` y `content/vivero/revision-2026-11-07.md`.
