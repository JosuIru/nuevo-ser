# V4 — Larrea Ganadera · ficha de encargo

> **Estado**: ficha, 2026-11-07. La propuesta completa (para quién, diferencial, normativa con fuentes, bloques F1G-1…10, hard limits) está en **`docs/propuestas/larrea-ganadera.md`**: es la referencia. Esta ficha solo fija lo que cambia para hacerla sin intervención.
> **App**: `apps/solera-ganadera/` · `scripts/nueva_vertical.sh ganadera "Larrea Ganadera" 7A5C44 F5EFE2 gana Ganadera` · prefijo `solera-ganadera:`.

## Cambio respecto a la propuesta: regla Z

**Zunbeltz está en producción y no se toca** (decisión de Josu, 2026-11-07). El bloque F1G-2 de la propuesta («extraer el dominio de ganado al core y que Zunbeltz dependa de él») **no se hace**. En su lugar:

- **Copiar** (nunca mover) a `apps/solera-ganadera/lib/` los modelos y la lógica pura de ganado de `apps/solera-zunbeltz/lib/modelos/`: `ganado.dart`, `carga_ganadera.dart`, `ganado_ecologico.dart`, `historial_animal.dart` y lo que arrastren. **Quitar** todo lo de sincronización y permisos (`uid`, `actualizado_ms`, `PoliticaEspacio`): la F1 es de un solo dispositivo.
- Copiar también sus tests de ese dominio y adaptarlos.
- Apuntar en `CLAUDE.md` el commit de Zunbeltz del que se copió, para poder comparar más adelante.
- Que algún día las dos apps compartan paquete lo decide Josu con la sesión de Zunbeltz: fuera de este plan.

## Lo demás, como la propuesta

- F1G-3…10 tal cual, con BD sobre `BaseDatosSolera`, y el **informe del eco-régimen de pastoreo** (F1G-7) como diferencial, en lógica pura con test.
- La **tabla UGM** va por trámite y como catálogo con fuente; los coeficientes de Zunbeltz son de la Junta de Andalucía y no valen para la PAC sin verificarlo.
- Hard limits de la propuesta §5: no recomendar medicamentos ni dosis, no sustituir SITRAN ni PRESVET, el informe del eco-régimen es una ayuda y no una declaración, y exportación completa de los datos.
- **Branding**: pardo lana `#7A5C44` + crema, con acento rojo de marcaje `#B8402A`.
