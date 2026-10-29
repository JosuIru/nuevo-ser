# Larrea Aceitera — Bloqueos pendientes

Decisiones humanas que bloquean fases concretas del roadmap. Cada bloqueo
declara la fase afectada, qué pieza queda colgada y qué interlocutor
humano hace falta para resolverlo.

## F1-A6 / F1-A10 — Catálogos revisados contra fuente pública

**Estado F1-A6**: 5 CSVs en `content/aceitera/` generados (40
variedades + 25 patologías + 20 fitosanitarios + 29 DOPs + 40
eventos del calendario), compilador `tool/compilar_catalogos.dart`
en producción.

**Estado F1-A10**: las 154 filas marcadas con
`revisado_por=fuente_publica`. `flag_revision.dart` deja
`catalogosCompletamenteRevisados=true`, el banner del dashboard
queda desactivado, el autocomplete sigue admitiendo texto libre como
fallback.

**Auditoría humana definitiva pendiente** — `fuente_publica` significa
"contrastado contra MAPA / IFAPA / BOE DOPs / Estaciones de Aviso /
literatura agronómica vigente", no firma profesional. El asesor
agrónomo olivarero con colegiación debe sustituir `fuente_publica`
por su nombre + nº de colegiación cuando audite el contenido.

**CUE digital (Cuaderno Único de Explotación)**: el RD 34/2025
entra en vigor en 2027 y obliga a que el cuaderno de explotación se
lleve digitalmente con un formato estandarizado MAPA. Anotado para
F1.1 — habrá que generar la exportación CUE oficial (probablemente
JSON o XML según especificación pendiente del MAPA). Hasta entonces,
el PDF actual del Cuaderno PAC olivar sigue siendo válido.

**Bloqueante**: **asesor agrónomo olivarero**. Idealmente un técnico
IFAPA o equivalente con experiencia en cooperativa. Hace falta para:

- Validar el catálogo de variedades de olivo (picual, hojiblanca,
  arbequina, cornicabra, manzanilla cacereña, empeltre, picudo, lechín
  de Sevilla, gordal sevillana, blanqueta, farga, morrut, sevillenca,
  villalonga, manzanilla de Jaén, royal de Cazorla, etc.) — fuente
  inicial: MAPA Registro de Variedades de Olivo + IFAPA Catálogo de
  Variedades.
- Validar el catálogo de plagas y enfermedades del olivar (mosca,
  prays, repilo, verticilosis, tuberculosis, cochinilla, glifodes,
  algodoncillo, taladrillo, antracnosis…) — fuente inicial: Boletines
  de Estaciones de Aviso Fitosanitario de las CCAA olivareras.
- Validar el catálogo de DOPs olivar vigentes (29 DOPs según BOE +
  Reglamentos UE de protección de denominaciones).
- Validar el calendario fenológico por zona productiva (Jaén / Córdoba
  / Sevilla / Lleida / Tarragona / Badajoz / Toledo / Mallorca / sur de
  Portugal frontera).

**Mientras tanto**: los CSVs llevan `revisado_por=` vacío y el flag
`catalogosCompletamenteRevisados=false`. La app muestra banner amarillo
"datos provisionales" en cualquier autocomplete que dependa de catálogo.

## F1-A4 — Formato cuaderno PAC olivar (PROVISIONAL desde esta sesión)

**Estado**: implementado. `lib/servicios/generador_cuaderno_pac_pdf.dart`
produce el PDF firmable con dos tablas (tratamientos fitosanitarios +
recolección) usando la plantilla `informe_periodico` del core. Selector
de campaña + parcela opcional desde `PantallaCuadernoPac`, accesible
desde Ajustes → "Informes".

**Bloqueante**: **técnico OCA / asesor APAE humano** para auditar el
formato y registrar nombre + nº colegiado antes de retirar el sello.

- Conforme RD 1311/2012 + RD 285/2021 vigente.
- CUE digital de RD 34/2025 entra en vigor en 2027 — el PDF clásico
  sigue siendo aceptado hasta entonces, anotado para F1.1.

**Mientras tanto**: el subtítulo del PDF lleva la palabra `PROVISIONAL`
literal. El test `test/sello_provisional_test.dart` (equivalente al de
viticultura/apícola/agro, riesgo R1 de la auditoría 2026-05-12) impide
retirarlo silenciosamente — para desbloquear hay que documentar el
nombre del técnico OCA en este bloqueo y actualizar el test en el
mismo commit.

## F1-A5 — Libro de movimientos del aceite (PROVISIONAL desde esta sesión)

**Estado**: implementado. `lib/servicios/generador_libro_aceite_pdf.dart`
produce el PDF firmable con tres tablas (lotes con parámetros
analíticos + molturaciones + movimientos cronológicos) usando la
plantilla `informe_periodico` del core. Selector de campaña + lote
opcional desde `_PantallaExportLibroAceite`, accesible desde el botón
PDF del AppBar de `PantallaLibroAceite`.

**Bloqueante**: **auditor AICA humano** para auditar el formato y
registrar nombre + nº de inspector antes de retirar el sello.

- Conforme RD 760/2021 + circulares AICA vigentes.
- Verificar que la trazabilidad lote→molturación→partidas se entiende
  en una inspección real (puede haber matices regionales).

**Mientras tanto**: el subtítulo del PDF lleva la palabra `PROVISIONAL`
literal. El segundo test de `test/sello_provisional_test.dart` impide
retirarlo silenciosamente — para desbloquear hay que documentar el
nombre del auditor AICA en este bloqueo y actualizar el test en el
mismo commit.

## F1-A9 — Libro ingresos/gastos REAGP olivar (modelos+BD cerrados, UI pendiente)

**Estado**: modelos POJO y migración BD v1→v2 cerrados en esta sesión.
4 entidades (`Tercero`, `ConfiguracionFiscal`, `ApunteIngreso`,
`ApunteGasto`) con tipologías olivar específicas (venta_aceituna,
venta_aceite_envasado, venta_aceite_granel, subproducto_alperujo,
recoleccion como pico anual de mano de obra, cuota_dop, analiticas,
combustible separado para devolución IH REAGP). Reglas IVA olivar
documentadas y testeadas en `ConfiguracionFiscal`. Sello `PROVISIONAL`
custodiado por tercer test en `sello_provisional_test.dart`.

**Bloqueante**: **asesor fiscal agroalimentario humano** antes de
retirar el sello provisional. Casuística olivar a confirmar:

- Venta de aceituna a almazara/cooperativa: 12 % compensación REAGP
  vs 4 % IVA en régimen general (implementado tal cual).
- Venta de aceite envasado al consumidor final: 4 % IVA básico
  (implementado tal cual) — fuera del REAGP del agricultor.
- Venta de aceite a granel a envasador/refinador: 4 % vs 10 % según
  interpretación — implementado al 4 %, el usuario sobrescribe.
- Subproducto alperujo a orujera: 10 % IVA en uso comercial — el
  modelo lo marca como categoría aparte para validar.
- Cuota DOP, analíticas obligatorias, gasoil agrícola (devolución
  IH en REAGP) — categorías ya en el modelo `ApunteGasto`.

**Pendiente F1-A9b/F2**: pantallas (configuración fiscal + terceros +
libro económico con tabs ingresos/gastos/resumen + formularios +
extracto económico anual PDF reusando `informe_periodico` del core).

## F1-A7 — IA Claude Vision (cableada en esta sesión, caveat)

**Estado**: implementado. `ClienteAnthropic` con dos modos
(`diagnosticarPlaga` + `identificarVariedad`) y matching fuzzy contra
catálogos `plagas_olivo` + `variedades_olivo`. Botón
`BotonDiagnosticarPlagaIa` cableado en `PantallaNuevoTratamiento`.
BYO key local en `PantallaClaveAnthropic` (Ajustes → "Inteligencia
artificial").

**Caveat**: hasta que F1-A6 esté validado por el asesor agrónomo, los
diagnósticos que coincidan con el catálogo se marcan como "Coincide con
el catálogo (provisional)" y los que no, como "Diagnóstico libre —
contrasta con un técnico". El banner rojo de declaración obligatoria
funciona ya para Xylella + verticilosis (catálogo provisional).

**Hard limits respetados** (a verificar manualmente con uso real):

- La IA no recomienda productos comerciales por marca (restricción a
  nivel de system prompt — la app no la fuerza por código, pero la
  observación rutinaria del operador detectará desviaciones).
- Cero PlantNet / cero Commons en BD pre-cargada — todo se queda en el
  dispositivo del operador.

**Pendiente**: tests de integración con clave de pruebas o mock-server
en F2.

## F1-A8 — Branding visual definitivo

**Estado**: planificado tras F1-A7.

**Bloqueante**: ilustrador / diseñador. Hace falta:

- Logo (aceituna + rama estilizada, o variante minimalista).
- Iconos Android adaptive (foreground transparente sobre fondo crema).
- Splash screen Android 12+.

**Mientras tanto**: el pubspec apunta a `assets/icono-logo-aceitera.png`
que es **placeholder** — sustituir cuando entre el activo definitivo y
regenerar con `dart run flutter_launcher_icons` + `dart run flutter_native_splash:create`.

## F2 — Lanzamiento y modelo de monetización

**Estado**: bloqueado hasta que las fases F1-A2 a F1-A10 cierren.

**Bloqueantes humanos**:

- Decisión de monetización para cooperativas (suscripción por almazara
  vs. licencia anual a la cooperativa con n socios incluidos).
- `applicationId` final (`com.josu.solera_aceitera` provisional).
- Cooperativa pequeña piloto (50-200 socios) que acepte usar la app
  durante una campaña entera con feedback estructurado.
- Decisión scope: ¿la app cubre subproductos (alperujo, orujo graso,
  hueso de aceituna) o se queda sólo en aceite virgen + virgen extra?
