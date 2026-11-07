# Asistente de auditoría

Prepara el trabajo de los asesores humanos de cada vertical Larrea (agrónomo, técnico OCA, auditor AICA, asesor fiscal, apicultor, quesero, arborista…) para retirar los sellos PROVISIONAL sin que Josu tenga que hacer de intermediario.

Reutiliza el lector de `scripts/pendientes/`.

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd scripts/auditoria && dart pub get

# 1. Lista de comprobación en PDF (una sección por asesor, con casillas y hueco para la firma)
dart run bin/auditoria.dart lista aceitera
dart run bin/auditoria.dart lista aceitera --para auditorAica

# 2. Cuando la persona ha firmado, se apunta su firma en el catálogo
dart run bin/auditoria.dart firmar ../../content/aceitera/variedades_olivo.csv \
    --firma "Nombre Apellido (agrónomo, nº colegiado, 2026-11-20)"
dart run bin/auditoria.dart firmar … --ids picual,hojiblanca   # solo esas filas

# 3. ¿Se pueden retirar ya los sellos?
dart run bin/auditoria.dart comprobar aceitera
```

## Reglas

- `firmar` escribe `asesor: <firma>; fuente: <cita previa>` en `revisado_por`: la cita no se pierde y el compilador de catálogos sigue viendo el campo relleno. Solo toca las filas firmadas; el resto queda igual byte a byte. Una fila ya firmada no se vuelve a firmar. Con `--como persona` escribe `persona:` (quien asume la revisión sin ser asesor) y con `--como revision-ia` anota una revisión de IA: cuenta aparte en el tablero, no es firma y admite encima la de una persona.
- **Nunca firmes en nombre de nadie.** Solo se apunta lo que la persona ha firmado en papel o por escrito.
- `comprobar` no retira nada: dice qué falta. Quitar el literal `PROVISIONAL` del código sigue siendo un cambio a mano, protegido por `test/sello_provisional_test.dart`, y hay que dejar constancia en `BLOQUEOS-PENDIENTES.md`.
- La lista no tiene validez jurídica por sí sola; lo dice en el propio PDF.
