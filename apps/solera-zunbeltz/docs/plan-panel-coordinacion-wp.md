# Panel de coordinación en WordPress — plan (plugin `solera-zunbeltz-sync` v0.3+)

> Partida extra aprobada por Zunbeltz el **2026-10-06**: **2.000 €** para *administración en WordPress, gestión de roles y tareas*. Se instala en **un subdominio del servidor que ya tiene Zunbeltz**, con un WordPress nuevo y el plugin. Base: plugin v0.2 (personas con rol y token personal, sincronización de tareas, política de permisos en servidor). Requisitos: `docs/respuestas-zunbeltz-2026-10-06.md` y `docs/convenio-tester-implicaciones.md`.

> **Ampliado el 2026-10-06**: entran también la sincronización de fincas, puntos y proyectos, las incidencias con alarmas y avisos en el móvil, y la economía real del test (antes «fuera de esta partida»). Ver bloques 7-9.

## Qué resuelve

La coordinación (dinamizador, responsable de finca y, si procede, personal de Andía) **gestiona las tareas desde el PC de la oficina**, en el escritorio de WordPress, y las personas tester las ven y ejecutan desde el móvil. Es la respuesta a «¿se podría ver desde un PC en la oficina?» para la parte de tareas, sin esperar a sincronizar el resto de la app.

## Alcance (v0.3)

### 1. Roles y permisos según las respuestas
- **Tester**: ve **sus tareas + las generales**; **no crea tareas**, envía **peticiones**; ejecuta las suyas (estado, coste, notas); puede cogerse una tarea general.
  - *Supuesto a confirmar*: **tarea general = tarea sin responsable asignado**.
- **Coordinación**: crea, asigna, edita y cierra todo; acepta o descarta peticiones.
- Se quitan `ver_todas_tareas` y `crear_tareas` al tester; capacidad nueva `enviar_peticiones`. Rol nuevo reservado **Andía** (por defecto, igual que coordinación pero sin gestionar personas; a confirmar).
- **Personas de coordinación enlazadas a su usuario de WordPress** (`wp_user_id`): entran al panel con su login y lo que hacen queda a su nombre. Las personas tester siguen sin cuenta WP: solo token en la app.

### 2. Peticiones de tarea (sugerencias/mejoras)
- Desde la app el tester envía una **petición**: qué pasa, finca, punto/zona si aplica, urgencia.
- En el panel: bandeja de peticiones → **convertir en tarea** (ya asignada) o **descartar** con motivo. El tester ve el resultado en la app.

### 3. Panel de tareas en el escritorio de WP
- Listado con **filtros** (finca, estado, responsable, vencidas) y orden por fecha objetivo.
- **Alta y edición** de tareas: título, descripción, finca, responsable, prioridad, fecha, periodicidad.
- Acciones rápidas: asignar, cambiar estado, cerrar.
- **Vencidas destacadas** arriba.
- **Exportar CSV/Excel** del listado.

### 4. Huella de actividad
- Tabla `actividad`: quién, qué (creó/asignó/cambió estado/cerró/pidió), sobre qué tarea, cuándo, desde dónde (app/panel).
- Vista en el panel: «Usuario 3 ha marcado hecha *Revisar vallado* · hace 2 h».
- La app recibe las últimas entradas (base del futuro feed de Hoy).

### 5. Avisos por correo
- **Resumen diario** a coordinación con las tareas vencidas y las peticiones nuevas (wp-cron).
- Aviso inmediato a coordinación cuando entra una petición marcada como urgente.
- *Las notificaciones push en el móvil y la bandeja de Hoy con 4 categorías no entran aquí*: van con el módulo de incidencias.

### 6. Instalación en el subdominio
- Guía de instalación (WP nuevo + plugin + HTTPS + copias de seguridad) y **puesta en marcha con ellas**: alta de personas y entrega de tokens.
- Si quieren, servir también aquí la **demo web** de la app (ficheros estáticos).

### 7. Sincronizar fincas, puntos, zonas y proyectos
- Entidades compartidas con `uid` estable (como las tareas): **fincas** (alta de fincas nuevas, p. ej. Zufía), **puntos** (incluidos los móviles: corral, bidón, con su posición actual) y **zonas**. Las tareas se anclan por `uid` de finca/punto/zona y dejan de perder el anclaje.
- **Proyectos** con todo su seguimiento (producción, comercialización, validación, económico). Visibilidad: la persona tester solo el suyo; coordinación, todos.
- Permisos: coordinación crea y edita fincas/puntos/zonas; la persona tester propone cambios (mover un corral móvil, avisar de un punto nuevo) que quedan registrados y avisan a coordinación («X ha añadido abrevadero en pieza 2»).
- Fotos: fuera de la primera vuelta (pesan; se decide almacenamiento).

### 8. Incidencias y avisos
- **Avisos de campo** con categoría (ganado · instalaciones · seguimiento individual · noticias, a confirmar viendo la app de Andía) y gravedad **alarma / aviso**: los crea cualquiera; las alarmas notifican al momento.
- **Recordatorios y tareas vencidas** que insisten hasta cerrarse.
- **Notificaciones en el móvil**: notificaciones locales (vencidas, recordatorios) sin servidor; las alarmas que llegan de otras personas necesitan push (Firebase Cloud Messaging) o comprobación periódica en segundo plano — decidir (FCM implica cuenta Google y su tratamiento de datos).
- **Incidencias de cumplimiento** del convenio (leve / grave / muy grave): solo coordinación, ligadas al proyecto, con efecto en la fianza.

### 9. Economía real del test (convenio art. 7)
- Gasto con **quién lo asume** (tester / Zunbeltz) y marca de **amortización**.
- **Presupuesto previsto** por concepto (anexo II) → previsto vs. real.
- **Balance del test** (sin amortizaciones) y **balance del proyecto** (con amortizaciones); **reparto** con porcentajes por proyecto (25/75 beneficio, 50/50 pérdida por defecto); **fianza** con plazos y retenciones.
- Informes trimestral y final; marca de agua **BORRADOR** salvo cierre por coordinación.

## Orden de trabajo
1. ✅ Roles nuevos + política + app: tester ve sus tareas + generales y no crea; el servidor manda la lista completa y la app retira lo que ya no ve (2026-10-06).
2. Enlace persona ↔ usuario WP + huella de actividad.
3. Panel de tareas en el admin.
4. Peticiones (servidor + app + panel).
5. Sincronizar fincas, puntos y zonas (anclaje por `uid`, puntos móviles, altas de fincas).
6. Sincronizar proyectos y su seguimiento.
7. Economía real del test (balances, reparto, fianza, previsto vs. real) + marca BORRADOR.
8. Avisos de campo + incidencias de cumplimiento + notificaciones.
9. Avisos por correo.
10. Instalación y puesta en marcha.

**Coste**: la partida aprobada (2.000 €) se pensó para los bloques 1-6 originales. Los bloques 7-9 se han incorporado después; hay que **revisar presupuesto y plazos** con Zunbeltz.

## A confirmar con Zunbeltz
1. ~~¿«Tarea general» = sin responsable asignado?~~ Sí (2026-10-06).
2. Personal de Andía: ¿qué puede hacer?
3. ¿Quién recibe los correos de aviso y a qué hora el resumen?
4. Acceso al servidor: panel de hosting, PHP ≥ 8.1, posibilidad de crear el subdominio y el certificado.
5. Las preguntas de `docs/convenio-tester-implicaciones.md` (reparto calculado en la app, amortizaciones, si el tester ve sus incidencias, finca de Zufía).
6. Push: ¿aceptan Firebase (Google) para las alarmas, o basta con comprobar al abrir la app y notificaciones locales?
