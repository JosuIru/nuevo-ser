# El Cuaderno — Paquete documental v0.1

> Juego pedagógico no narrativo para **Colección Nuevo Ser Kids**.
> Materia: Conocimiento del Medio Natural (LOMLOE primaria, ciclos 2-3).
> Edad: 9-13 años.
> Modelo: herramienta de campo digital con alma pedagógica, sin protagonista ni mundo ficticio.

> **Encuadre del programa.** *El Cuaderno* se propone como tercer juego de la línea **Colección Nuevo Ser Kids** (juegos digitales pedagógicos infantiles/escolares). La **Colección Nuevo Ser** madre es un proyecto editorial y de pensamiento más amplio: editorial de libros, plugins para colectivos y comunidades, herramientas para favorecer alternativas y pensamiento crítico y constructivo (https://coleccion-nuevo-ser.gailu.net/). Cuando este paquete dice "la Colección" se refiere a Kids salvo aviso. *La Tierra que Despierta*, columna filosófica de El Cuaderno, viene de la Colección madre.

---

## Qué es este paquete

14 documentos que cubren completamente la capa estratégica, pedagógica, técnica y de contenido inicial de **El Cuaderno**, el primer juego no narrativo de la Colección Nuevo Ser.

El paquete está pensado para entrar a las Fases 1, 2 y 3 del proceso de incorporación a la Colección (definidas en `coleccion-nuevo-ser-criterios-de-integracion.md`), y deja preparado el material necesario para Fase 4 (piloto).

**Estado:** v0.1, borrador completo. Pendiente de revisión humana antes de cierre a producción.

---

## Orden de lectura recomendado

Si vas a leer el paquete por primera vez, este es el orden que minimiza confusión:

### Para entender la idea (45 min)

1. `el-cuaderno-00-propuesta-fase-1.md` — Documento de presentación al equipo editorial. Resumen de la idea y de cómo cumple los criterios filosóficos de la Colección.
2. `el-cuaderno-01-biblia.md` — Documento maestro. Diez principios jerárquicos, mecánicas centrales, lo que el juego es y lo que no es.

### Para entender la voz (45 min)

3. `el-cuaderno-04-voces-y-figuras.md` — La voz del Cuaderno (sistema) y del Tutor IA. Ejemplos canónicos, vocabulario prohibido, decisión abierta sobre la abuela.
4. `el-cuaderno-13-flujos-de-usuario.md` — Diez recorridos típicos paso a paso. El doc más concreto del paquete.

### Para entender la pedagogía (60 min)

5. `el-cuaderno-02-mapa-habilidades-atomicas.md` — 59 habilidades atómicas en 9 dominios. Mapeo a LOMLOE.
6. `el-cuaderno-05-pedagogia-del-lugar.md` — Cómo el juego trata el lugar real del niño sin folclorismo rural ni desprecio urbano.
7. `el-cuaderno-06-pedagogia-misterios.md` — Anatomía de un Misterio bueno, anatomía de uno malo, reglas de redacción.
8. `el-cuaderno-15-acompanamiento.md` — Vista del cuidador, vista del aula, materiales pedagógicos.

### Para entender la estética (30 min)

9. `el-cuaderno-11-guia-visual.md` — Paleta, tipografía, iconografía, ilustración botánica.
10. `el-cuaderno-12-guia-sonora.md` — Brevísimo. El silencio es el contenido.

### Para entender lo técnico (60 min)

11. `el-cuaderno-03-arquitectura-tecnica.md` — Stack, perfil P5 nuevo del motor adaptativo, privacidad por diseño.
12. `el-cuaderno-prompt-claude-code.md` — Prompt para arrancar el primer sprint técnico.
13. `el-cuaderno-14-prompt-maestro-contenido.md` — Tres prompts para escalar producción de contenido con Claude.

### Para ver el juego hablando (30 min)

14. `el-cuaderno-catalogo-seminal-misterios.md` — 19 Misterios redactados al detalle. Primer cargamento de contenido jugable concreto.

---

## Estado por documento

| # | Documento | Estado | Pendiente |
|---|---|---|---|
| 00 | Propuesta de Fase 1 | Cerrado v0.1 | Falta firmar (sección 7) |
| 01 | Biblia maestra | Cerrado v0.1 | 5 decisiones abiertas (§10) |
| 02 | Mapa de habilidades atómicas | Borrador v0.1 | Asesoría didáctica para [?] |
| 03 | Arquitectura técnica | Cerrado v0.1 | Validación con ingeniero sénior |
| 04 | Voces y figuras | Cerrado v0.1 | Decisión sobre la abuela |
| 05 | Pedagogía del lugar | Cerrado v0.1 | — |
| 06 | Pedagogía de los Misterios | Cerrado v0.1 | — |
| 11 | Guía visual | Cerrado v0.1 | Encargo a ilustradora |
| 12 | Guía sonora | Cerrado v0.1 | — |
| 13 | Flujos de usuario | Cerrado v0.1 | Implementación |
| 14 | Prompt maestro de contenido | Cerrado v0.1 | — |
| 15 | Acompañamiento | Cerrado v0.1 | Validación con psicóloga infantil (caso 1 §8) |
| Catálogo | 19 Misterios seminales | Cerrado v0.1 | Verificación científica de [DATOS A VERIFICAR], traducciones eu/ca, test con niños |
| Prompt CC | Bootstrap técnico | Cerrado v0.1 | Ejecución |

---

## Decisiones abiertas por cerrar

Por orden de urgencia para arrancar producción:

### Bloqueantes para entrar a Fase 2 oficial
1. **Asesoría didáctica** sobre el mapa de habilidades atómicas (doc 02) — especialmente las marcadas con `[?]`.
2. **Asesoría psicológica** sobre el caso 1 del doc 15 §8 (detección o no de angustia).
3. **Decisión sobre el nombre** definitivo del juego.

### Bloqueantes para entrar a Fase 3 oficial
4. **Validación técnica** de la arquitectura por ingeniero sénior, especialmente el perfil P5.
5. **Política de privacidad** específica revisada por especialista en LOPDGDD para menores.

### Bloqueantes para entrar a Fase 4 (piloto)
6. **Verificación de los `[DATO A VERIFICAR]`** del catálogo de Misterios con fuentes científicas (SEO/BirdLife, Real Jardín Botánico CSIC, etc.).
7. **Traducciones a euskera y catalán** por hablantes nativos con criterio terminológico naturalista.
8. **Captación de 12-15 familias voluntarias** para el piloto.
9. **Decisión sobre Versión A o B del cold start** (cuaderno vacío vs cuaderno heredado).

### Bloqueantes para producción de arte
10. **Encargo de ilustración botánica** a ilustradora humana profesional. ~75-80 ilustraciones. Coste estimado 10-25k€.

---

## Lo que no está en este paquete y se construye después

- **Lotes 2-5 del catálogo de Misterios** (60-80 Misterios adicionales hasta llegar al MVP completo). Se redactan con el doc 14.
- **Claves de identificación regionales** específicas. Requieren naturalistas humanos del territorio.
- **Calendario fenológico Iberia** (30-40 marcadores iniciales). Requiere ornitólogos y botánicos.
- **Banco de cantos de pájaros** del catálogo. Requiere acuerdos con Xeno-canto u otros.
- **Materiales pedagógicos para profesores** alineados con LOMLOE. Producibles con didactas.
- **Sprints técnicos 2-9** (ver doc 03 §12). Cada uno se documenta con su propio prompt cuando llega su turno.

---

## Anclajes filosóficos

El paquete se apoya explícitamente en cinco fuentes externas que conviene tener leídas:

- *Educar para el Nuevo Ser* (libro original de la colección).
- *La Tierra que Despierta* (libro complementario; columna vertebral filosófica de El Cuaderno).
- `coleccion-nuevo-ser-manifiesto.md` (manifiesto de la Colección).
- `coleccion-nuevo-ser-criterios-de-integracion.md` (criterios formales).
- `nuevo-ser-core-arquitectura.md` (arquitectura común de la plataforma).

---

## Licencia

Como el resto de la Colección Nuevo Ser:

- **Código**: AGPL-3.0
- **Contenido**: CC BY-SA 4.0

Estos términos aplican desde el primer commit. Las traducciones, ilustraciones encargadas y materiales pedagógicos se publicarán bajo licencia compatible.

---

## Próximos pasos sugeridos

1. **Lectura crítica** por una persona de tu círculo editorial cercano. Buscar incoherencias internas, decisiones que no encajan, voces que se desvían.
2. **Lectura por un niño de 9-13 años** con cuidador, leyendo en voz alta los Misterios del catálogo seminal y la microcopia de pantalla principal.
3. **Lectura por una persona del oficio** (naturalista de campo) buscando errores biológicos en el catálogo.
4. **Iteración a v0.2** en los puntos donde estas tres lecturas detecten problemas.
5. **Decisión** sobre si entrar a Fase 1 oficial del proceso de incorporación a la Colección.
6. Si la decisión es sí: ejecutar el Sprint 1 técnico con el prompt para Claude Code.

---

*Paquete documental v0.1 — abril 2026.*
*Producido en colaboración con Claude (asistente de Anthropic) y revisado pendientemente por humanos.*
