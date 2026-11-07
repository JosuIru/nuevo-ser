# Larrea Obrador

Gestor para panaderías artesanas, obradores caseros, repostería y conservas
(suite Larrea, Colección Nuevo Ser). Móvil, sin conexión y en es/eu/ca/gl.

- **Recetas** con bases y rellenos: alérgenos heredados, trazas, ingredientes por
  peso para la etiqueta, coste y margen por pieza, sal estimada y aviso frente a
  la norma de calidad del pan (RD 308/2019).
- **Autocontrol**: cuaderno del mes en dos toques, con acciones correctoras.
- **Hornadas** con los lotes de ingrediente usados (trazabilidad), **pedidos fijos**
  y **masa madre**.
- **Documentos PDF** (PROVISIONAL): cuaderno de autocontrol, ficha técnica y cartel
  de alérgenos; extracto de ingresos y gastos.
- **IA** con clave propia: leer la etiqueta del proveedor y proponer alérgenos.

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test                          # tests
dart run tool/compilar_catalogos.dart # tras tocar content/obrador/*.csv
flutter build apk --release
```

Estado, decisiones y límites: `CLAUDE.md`. Lo que espera a una persona:
`BLOQUEOS-PENDIENTES.md`. Encargo: `docs/plan-verticales/obrador.md`.
