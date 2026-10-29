# solera_aceitera

Gestor de explotación olivarera y almazara para almazaras pequeñas y medianas (100-2000 hl/campaña).

Sexto fork de la **Suite Larrea** dentro del monorepo `nuevo-ser/`. Hermana técnica de `apps/agro`, `apps/solera-viticultura`, `apps/solera-apicola`, `apps/solera-arbolado-urbano` y `apps/solera-quesera`.

Detalle de fase y diferenciadores en `CLAUDE.md`. Bloqueantes humanos en `BLOQUEOS-PENDIENTES.md`.

## Comandos habituales

```bash
export PATH="$HOME/flutter/bin:$PATH"
( cd apps/solera-aceitera && flutter pub get )
( cd apps/solera-aceitera && flutter analyze )
( cd apps/solera-aceitera && flutter test )
( cd apps/solera-aceitera && flutter run -d linux )
( cd apps/solera-aceitera && flutter build apk --release )
```
