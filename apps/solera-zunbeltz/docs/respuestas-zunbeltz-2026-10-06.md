# Respuestas de Zunbeltz al esquema de la Fase 1 — 2026-10-06

Respuestas de **Pablo (dinamizador de Zunbeltz)**, con aportaciones de **Elena**, al documento `presentacion/esquema-fase-1.md`. Primero lo que dijeron (resumido fielmente), después qué implica para la app: lo que ya existe, lo que falta y lo que cambia del diseño actual.

Leyenda: ✅ ya existe · 🟡 existe a medias · ❌ no existe · 🔁 contradice el diseño actual.

---

## 1. Hoy

**Lo que piden**
- **Categorías de registro con distinta gravedad**. Algunas son *alarma* (animal enfermo, rotura importante, falta de alimento); el resto, *aviso normal* tipo "Ander ha notificado cambios en finca 2" → entras y ves qué ha hecho.
- **Recordatorios agendados**: ITV del tractor, fecha fértil de las ovejas, cosas programadas.
- Elena se imagina algo como **la app de Andía**: 4 categorías — **Ganado · Instalaciones · Seguimiento individual · Noticias** — con avisos como iconitos que indican el tipo de incidencia.

**Implica**
- ❌ **Incidencias / notificaciones** como entidad nueva (categoría + gravedad + autor + finca/punto + foto), distinta de la tarea. Hoy "Hoy" sólo muestra el tiempo y el número de tareas abiertas.
- ❌ **Feed de actividad** ("quién hizo qué, dónde"). Requiere que todo lo que se registra lleve autor y se sincronice (hoy sólo se sincronizan tareas).
- ❌ **Notificaciones push** para las alarmas. Requiere servidor que empuje (FCM o similar) o, como mínimo, comprobar al abrir la app.
- 🟡 **Recordatorios agendados**: las tareas periódicas (BD v6) cubren parte (ITV anual = tarea cada 365 días con fecha objetivo). Falta que avisen.
- 🔁 La pantalla Hoy pasa de "resumen" a **bandeja de avisos con 4 categorías**. Conviene ver la app de Andía para no inventar la forma.

## 2. Fincas

**Lo que piden**
- **Añadir fincas nuevas**, y que las infraestructuras se puedan **añadir y mover** — incluidas las **móviles** (corrales móviles, bidón portátil).
- Elena: ¿**quién mete los puntos con GPS**? ¿Van ellas, vamos nosotros? Lo estima como mucho trabajo.
- **Crear y asignar tareas: sólo el personal de Zunbeltz**. Los testers pueden enviar **sugerencias/mejoras** y la persona responsable las convierte en tareas o etiquetas.
- **Avisos de tareas vencidas: sí**, insistentes hasta que se marque como hecha (comprar comida, inscribirse en ferias de ganado…).
- **Formato del parte**: depende; por ejemplo, la **cantidad de comida suministrada por días en Excel**.

**Implica**
- ❌ **Alta/edición de fincas** desde la app (hoy son un seed fijo de 2 fincas).
- 🟡 **Mover puntos**: ya se puede recolocar un punto en el mapa. ❌ Falta el concepto de **infraestructura móvil** (tipo + historial de ubicaciones, recolocación rápida "está aquí ahora").
- ❌ Tipos nuevos: **corral móvil**, **bidón/depósito portátil**. Pedirles la lista completa.
- **Carga inicial de puntos**: no tiene por qué ser in situ. Propuesta: (a) marcarlos en el **mapa satélite desde el PC/móvil** sin ir al sitio (la app ya permite colocar un punto tocando el mapa); (b) importar una **lista en Excel** o un **KML** si alguien los tiene ya; (c) una **jornada conjunta** sólo para lo que no se ve en satélite. Responder a Elena con esto.
- 🔁 **Permisos**: el reparto provisional (plugin v0.2) deja crear tareas al tester. Cambia a: **tester no crea tareas, crea peticiones/sugerencias**; coordinación las acepta (→ tarea) o descarta.
- ❌ **Avisos de vencidas** que se repitan hasta cerrarla (notificación local diaria mientras siga vencida).
- 🟡 **Excel**: ya hay exportación CSV del proyecto y del espacio. ❌ Falta un **resumen de alimentación por día** (kg/día por lote) exportable.

## 3. Proyectos

**Lo que piden**
- **Los cuatro bloques sí reflejan cómo evalúan un test.**
- **Parte económica**: el tester puede **añadir** gastos (veterinario, un cencerro…), pero la **versión definitiva** la genera el dinamizador / responsable de finca.
- **Capa B (vista web del acompañamiento)**: se quedan con la **evaluación del proyecto** = seguimiento del tester, **hitos y acompañamientos**. **El resto no les encaja** (convocatorias, cesiones, banco de tierras…).
- Falta, y es importante, **comercialización**:
  - **Calculadora de transformación**: animal de X kg → kg de producto obtenido → precio → rentabilidad de ese camino.
  - **Contactos e información de comercialización**.
  - **Avisos de subvenciones, ferias**, etc.
- **Informe**: análisis **ingresos–gastos** y, sobre todo, **gastos imputados al proyecto vs. gastos reales**: Zunbeltz asume costes de los que sólo se repercute una parte al tester, y quieren que el tester vea el coste real.
- **Pestaña de contactos**: mataderos, veterinario, expertos ganaderos…

**Implica**
- ✅ Producción / comercialización / validación / económico se mantienen.
- ❌ **Gasto con dos importes**: *coste real* e *imputado al tester* (o % imputado). El informe muestra ambas columnas y la diferencia ("lo que aporta Zunbeltz"). Cambio de modelo en `apuntes_economicos` → BD v9.
- ❌ **Estado borrador / definitivo** del informe económico: el tester registra; coordinación "cierra" y genera la versión definitiva. Encaja con la marca de agua de Ajustes.
- ❌ **Calculadora de rendimiento de canal / transformación** (peso vivo → canal → piezas/producto vendible → €/kg → margen). Los porcentajes de rendimiento por especie/raza **no se inventan**: PROVISIONAL, editables por el usuario.
- ❌ **Contactos** (agenda compartida del espacio: tipo, nombre, teléfono, correo, notas).
- ❌ **Avisos de ferias / subvenciones**: probablemente lo publica coordinación y llega a todos (encaja con la categoría *Noticias* de Hoy).
- 🔁 **Capa B se recorta**: fuera convocatorias, cesiones y banco de tierras del plan (FZ-10/FZ-11). Se queda **hitos + acompañamiento/tutorías + evaluación**. Actualizar roadmap y presentación.

## 4. Ajustes

**Lo que piden**
- **Marca de agua** en todos los documentos que salen del móvil, para que no pasen por definitivos. Las **versiones definitivas sólo desde PC o por el dinamizador**.

**Implica**
- 🟡 Ya llevan sello PROVISIONAL (de compliance). Hay que separar dos conceptos: **PROVISIONAL** (formato sin validar) y **BORRADOR** (no es la versión oficial de Zunbeltz). Marca de agua "BORRADOR" en todo PDF salvo que lo genere alguien con capacidad `generar_definitivos`.
- Sin respuesta a: varias personas coordinadoras, logo, datos de la entidad en informes → asumir que sí (logo + datos de la entidad en cabecera), confirmar.

## 5. Trabajo compartido

**Lo que piden**
- **Dos roles bien**; ambos notifican, uno añade cosas más concretas. Al **personal de Zunbeltz le saltan las modificaciones**: "el usuario X ha añadido abrevadero en pieza 2".
- **Testers ven sólo sus tareas y las generales.**
- **Crear tareas: el gestor**; los demás hacen **peticiones de tareas**.
- **Uso**: un móvil por tester + uno por miembro de Zunbeltz, **cada uno con su usuario** y **huella de la actividad** ("Usuario 3 ha alimentado y revisado vallado").

**Implica**
- 🔁 Quitar `ver_todas_tareas` y `crear_tareas` al rol Tester. "Generales" = tareas sin responsable o marcadas como generales (definir: ¿una tarea "general" es la de finca sin persona asignada?).
- ❌ **Sincronizar todo** (fincas, puntos, zonas, registros, incidencias), no sólo tareas. Es la pieza grande: sin esto no hay feed de actividad ni vista de PC con datos reales.
- ❌ **Registro de actividad (auditoría)** en servidor: autor, acción, entidad, fecha.
- ✅ Usuario por persona con token personal (plugin v0.2) ya existe.

## Preguntas generales

- **Imprescindible**: **facilidad de uso** — añadir tareas, resolver incidencias, programar avisos.
- **Quién y desde dónde**: responsable y dinamizador, **personal de Andía** (móvil propio o de empresa). **¿Se podría ver desde un PC en la oficina?**
- **¿Qué es más barato, app móvil o web?** Y para lo del **31 de octubre**, ¿se podría tener **algo web** para que los testers ya puedan verla y tocarla?

**Implica**
- Nuevo actor: **personal de Andía** (Mancomunidad). Probablemente con rol de coordinación o de sólo lectura — preguntar.
- Respuesta sobre web vs. móvil: ver la sección siguiente.

---

## Web vs. móvil y el 31 de octubre

**Coste**: la app está hecha en Flutter, que compila **el mismo código** a Android, iPhone, escritorio y **web**. No hay que elegir ni pagar dos desarrollos; lo que encarece no es la plataforma sino el **servidor que comparte los datos** entre personas. Diferencias prácticas:

| | Móvil (APK/tienda) | Web |
|---|---|---|
| Sin cobertura en el monte | Sí | No (o muy limitado) |
| GPS para marcar puntos | Fiable | Funciona, menos preciso |
| Avisos / alarmas | Sí (notificaciones) | Limitado |
| Ver desde el PC de la oficina | No | Sí |
| Instalar | APK o tienda | Nada, un enlace |

Recomendación: **las dos**, del mismo código — móvil para el campo, web para la oficina y para que los testers la prueben sin instalar nada.

**Para el 31 de octubre es viable** una **web de demostración**: la app actual compilada a web, con datos de ejemplo, accesible por enlace, para que los testers la toquen y opinen. **Limitación honesta**: en esa web cada navegador guarda sus propios datos; **no es todavía la herramienta compartida** (eso requiere sincronizar todo, punto 5). Riesgo técnico a verificar antes de prometerlo: la base de datos local (`sqflite`) necesita su variante web (`sqflite_common_ffi_web`), y hay que comprobar mapa, PDF y compartir en navegador. Estimación: unos días, incluido alojarla.

---

## Propuesta de orden (para validar con Zunbeltz)

1. **Antes del 31-oct** — web de demostración + ajustes rápidos que ya pidieron y no dependen del servidor: fincas editables, tipos nuevos (corral móvil, bidón), marca de agua BORRADOR, gasto real vs. imputado en el económico e informe, contactos.
2. **Permisos según sus respuestas** — tester sin crear tareas → peticiones; tester ve sólo las suyas + generales; generar definitivos sólo coordinación.
3. **Incidencias + Hoy como bandeja** (4 categorías, gravedad alarma/aviso, recordatorios de vencidas). Ver antes la app de Andía.
4. **Sincronización completa + registro de actividad** (feed "quién hizo qué") + web conectada para la oficina.
5. **Comercialización ampliada**: calculadora de transformación, avisos de ferias/subvenciones.
6. **Capa B recortada**: hitos + acompañamiento + evaluación.

## Preguntas que quedan para ellas

1. ¿Qué es exactamente lo del **31 de octubre** (justificación de la subvención, presentación a testers, otra cosa)? Define qué tiene que estar.
2. ¿Podemos ver la **app de Andía** (nombre, capturas)?
3. Lista completa de **tipos de infraestructura** que faltan, y cuáles son **móviles**.
4. Lista de **categorías de incidencia** y cuáles son **alarma**.
5. ¿Qué es una **tarea "general"** para un tester?
6. **Personal de Andía**: ¿qué ve y qué puede hacer?
7. Para el **gasto imputado**: ¿se imputa un % fijo por concepto, o un importe que decide coordinación en cada gasto?
8. **Calculadora de transformación**: ¿qué productos (canal, piezas, embutido, leche/queso…)? ¿Tienen sus propios rendimientos de referencia?
9. ¿Logo y datos de la entidad en los informes? ¿Varias personas coordinadoras?
