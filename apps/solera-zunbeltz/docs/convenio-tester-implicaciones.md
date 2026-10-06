# Convenio tester (plantilla 2026) — qué implica para la app

Fuente: `2026_BASE_Convenio tester_proyecto (2).docx` (plantilla del convenio privado entre la Asociación Zunbeltz y cada persona tester; documento de Zunbeltz, fuera del repo). Leído el 2026-10-06. Aquí solo lo que afecta al diseño; el convenio manda.

## 1. Economía del test (art. 7) — sustituye a «gasto real vs. imputado»

Lo que en las respuestas se llamó *gasto imputado al tester vs. gasto real* el convenio lo concreta así:

- **Quién asume cada coste inicial**:
  - **Tester**: ganado · alimentación · servicios y productos veterinarios.
  - **Zunbeltz**: infraestructuras y fincas · materiales ganaderos · transformación · personal · otros gastos complementarios (el anexo I añade también el ganado en algún caso: *se define por proyecto*).
- **Todas las facturas van a nombre de la Asociación** (proveedores y clientes). La app no emite facturas; registra los movimientos del proyecto.
- **Seguimiento económico trimestral** conjunto, y al final **dos balances**:
  - **Balance final del test**: ingresos y gastos directamente imputables a la actividad, **sin amortizaciones** de infraestructuras y materiales. Es el que cuenta para el resultado.
  - **Balance final del proyecto**: todo, **con amortizaciones**, informativo (es lo de «que vean la realidad del coste»).
- **Reparto del resultado** (sobre el balance del test): beneficio **25 % Zunbeltz / 75 % tester**; pérdida **50 % / 50 %** como criterio inicial. Modificable por acuerdo escrito → porcentajes **configurables por proyecto**.
- **Fianza**: 10 % del valor estimado de los servicios que presta Zunbeltz (terreno, infraestructuras, horas de personal técnico y ganaderos expertos, transformación, complementarios), en plazos; se retiene total o parcialmente por incidencias graves o muy graves.
- **Anexo II — previsión económica** por proyecto: coste estimado total, parte del tester, parte de Zunbeltz.

**Modelo que se deriva** (en vez de un % imputado por gasto):
- Cada gasto lleva **quién lo asume** (tester / Zunbeltz) y si es **amortización** (entra solo en el balance del proyecto).
- Proyecto con **presupuesto previsto** por concepto → comparativa **previsto vs. real**.
- Ficha de **cierre**: balance del test, balance del proyecto, reparto según los porcentajes del proyecto, fianza (importe, plazos pagados, retenciones).
- Informe **trimestral** y **final**, con marca BORRADOR hasta que la coordinación lo cierra (encaja con «la versión definitiva la hace el dinamizador»).

## 2. Incidencias de cumplimiento (art. 8) — distintas de los avisos de campo

El convenio registra **incidencias del tester** en tres niveles con efecto sobre la fianza:
- **Leve** (retraso puntual, error de registro sin consecuencias, desajuste menor) → sin retención.
- **Grave** (incumplimiento puntual de tareas relevantes, fallos reiterados en registros obligatorios, uso inadecuado de recursos, no comunicar decisiones relevantes) → retención parcial.
- **Muy grave** (reiteración de graves, abandono, negligencia en bienestar animal, sanciones, daños relevantes, incumplimiento reiterado del plan) → retención total y rescisión.

No son lo mismo que las incidencias de campo de las respuestas («animal enfermo», «rotura», «falta de alimento») que avisan al equipo. Hay que separarlas:
- **Avisos de campo** (alarma / aviso) → los crea cualquiera, los ve el equipo.
- **Incidencias de cumplimiento** (leve / grave / muy grave) → **solo coordinación**, dato personal sensible (RGPD), alimentan la evaluación y la fianza. Las ve la persona tester afectada (debe poder conocerlas: «resolución motivada»), nunca el resto de testers.

## 3. Indicadores de seguimiento (anexo IV) — el contenido de la evaluación

Tabla Zunbeltz ↔ tester, por bloques:
- **Soporte integral**: formaciones (propuestas / asistidas, mínimo una), visitas a explotaciones de referencia, asesoramientos de ganaderos expertos.
- **Difusión**: visitas recibidas en el ETA, mercados, medios de difusión.
- **Seguimiento**: **al menos 1 reunión mensual** con el equipo y **1 visita mensual a la finca de Zufía**.
- **Venta y transformación**: canales propuestos/identificados (grupos de consumo, mercados y ferias, venta directa, pequeño comercio, hostelería, crowdfunding, restauración colectiva, centro de acopio y distribución, otros) y horas de búsqueda; mercados.
- **Soporte físico**: uso correcto de infraestructuras; apoyo en tareas generales extraordinarias (p. ej. recogida de forraje).
- **Valoración general**: implicación en el proyecto, 0-10, por ambas partes.

→ Es exactamente la «evaluación del proyecto / hitos / acompañamiento» que quieren conservar de la Capa B. Se modela como **actividades de acompañamiento** (formación, visita, asesoramiento, reunión, mercado, difusión…) con *propuesta* y *asistencia*, contadas contra los mínimos del anexo, más la valoración 0-10.

## 4. Otros puntos con efecto en la app

- **Anexo III — infraestructuras cedidas por proyecto** (aprisco, caseta, manga, abrevaderos, comederos…): enlazar proyecto ↔ puntos de infraestructura del mapa.
- **Finca de Zufía**: aparece como finca del equipo → confirma que hacen falta **altas de fincas**.
- **Canales de venta**: la lista del anexo IV sustituye a la actual de la app (añadir pequeño comercio, hostelería, crowdfunding, restauración colectiva, centro de acopio; revisar «online» y «mayorista»).
- **Uso de recursos compartidos sujeto a validación** de la Asociación (art. 5) → encaja con las peticiones de tarea.
- **Aviso con antelación de ausencias** para que el personal cubra el cuidado del ganado (art. 4) → posible tipo de petición («necesito cobertura del X al Y»).
- **Confidencialidad** de la información del tester (art. 4) → refuerza la visibilidad restringida.

## Preguntas que abre

1. ¿El reparto 25/75 y 50/50 se calcula en la app o solo se muestra el balance y lo reparten ellas?
2. Amortizaciones: ¿tienen tabla de vida útil por infraestructura/material o se apunta la cuota a mano?
3. ¿La persona tester ve sus incidencias de cumplimiento en la app, o se le comunican fuera?
4. ¿La finca de Zufía se añade ya al mapa?
