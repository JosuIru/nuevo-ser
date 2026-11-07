# Tablero de pendientes

Lee todo lo que espera a una persona en el monorepo y lo agrupa por **a quién se espera**:

- las secciones de cada `BLOQUEOS-PENDIENTES.md` de `apps/*` y `social/apps/*`;
- los sellos `PROVISIONAL` que quedan en literales de código de `lib/` (y si un `sello_provisional_test.dart` los protege);
- los catálogos CSV de `content/`, contando cuántas filas tienen firma de una persona experta;
- los flags `catalogosCompletamenteRevisados`.

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd scripts/pendientes
dart pub get
dart run bin/pendientes.dart                 # terminal + salida/pendientes.html
dart run bin/pendientes.dart --solo-terminal
dart test
```

## Cómo decide

- Un `##` con `###` debajo es un grupo; sus `###` son los bloqueos. Un `##` sin hijos es un bloqueo.
- **Resuelto** si el título (o el del grupo) lleva ✅, «resuelto» o «cerrado», salvo que diga «provisional», o si todas sus casillas `- [x]` están hechas.
- **Responsable** por palabras clave (`lib/src/clasificador_responsables.dart`). Orienta, no manda: lo que caiga en «Sin clasificar» indica que falta una palabra clave o que el bloqueo está mal redactado.

## Firma de persona en `revisado_por`

Hoy los catálogos llevan en `revisado_por` una **cita** (`fuente_publica`, «MAPA Registro Variedades Vid 2026»…): están contrastados con documentación, pero ninguna persona experta los ha firmado. Para que cuente como firma, el valor tiene que empezar por `asesor:` o `persona:`:

```
picual,Picual,…,asesor: Nombre Apellido (agrónomo, 2026-11-20)
```

Lo escribe el asistente de auditoría (`scripts/auditoria/`).
