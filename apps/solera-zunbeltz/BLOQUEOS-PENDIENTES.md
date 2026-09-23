# Solera Zunbeltz — BLOQUEOS PENDIENTES

Decisiones que requieren a una persona (equipo de Zunbeltz Elkartea, asesor técnico/veterinario, asesor fiscal, técnico OCA, CPAEN/NNPEK) antes de poder cerrar a producción. Nada aquí se inventa: se marca PROVISIONAL y se espera firma.

## A. Para llevar a la primera reunión (que ellas aporten)

1. **Alcance del piloto**: ¿arrancamos por el **módulo de gestión de fincas + puntos en mapa + tareas de mantenimiento** (FZ-3, lo más demostrable y sin compliance) y dejamos el cuaderno ganadero y la Capa B para después? Recomendación: sí.
2. **Una capa o dos**: ¿vertical ganadera autónoma + módulo ETA encima (recomendado), o app monolítica "Zunbeltz"?
3. **Quién es el cliente/titular del producto**: Zunbeltz Elkartea, Mancomunidad de Andía, o se diseña genérico para la **red estatal de ETAs** desde el día uno. Define el modelo B2B y la licencia.
4. **Inventario real de infraestructuras**: qué puntos existen hoy en Zunbeltz y La Planilla (abrevaderos, mangas, cierres, refugios, cuadras, almacenes, balsas, cargaderos…). El mapa del MVP se siembra con datos reales, no de ejemplo.
5. **Catálogo de tareas de mantenimiento** habituales y su periodicidad (tensar alambrada, desbroce, revisión de bebederos, tejados, instalación eléctrica…). Y **quién** las ejecuta: ¿los testadores como contraprestación?, ¿operario de la Mancomunidad?, ¿empresa externa?
6. **Roles y permisos**: ¿qué ve y qué puede hacer cada rol (testador / mentor / coordinador / asesor)? En especial, **datos sensibles** del emprendedor (evaluación de viabilidad y competencias) — RGPD: ¿lo ve el coordinador?, ¿sólo el mentor?
7. **Proceso real de acompañamiento y evaluación**: qué hitos, qué competencias y con qué criterios se evalúa la viabilidad de un proyecto. Esto es **conocimiento de Zunbeltz**, no se modela sin ellas. (Es lo que la Capa B enchufa al motor de maestría del core.)
8. **Banco de tierras / relevo**: ¿lo gestiona la app o ya tienen otra vía? ¿Qué datos de cedentes/demandantes son públicos y cuáles no?
9. **La Venta de Zunbeltz**: ¿quieren trazabilidad lote→producto→venta directa dentro de la app, o queda fuera del alcance?

## A-bis. Euskera (revisión nativa — antes de la reunión si da tiempo)

9-bis. **Revisión nativa del euskera de la presentación**. El texto eu de `presentacion/index.html` es un borrador propio (batua) y, aunque cuidado, debe pasar por una persona euskaldun — idealmente del propio equipo de Zunbeltz, lo que además lo convierte en co-diseño. Puntos a confirmar con ellas: terminología agroganadera oficial (¿"Nekazaritza Saiakuntza Gunea" o la forma que ellas usan?, "manga de manejo", "larre-saila"…), euskera batua vs. variante navarra/local, y respeto de nombres propios. **No dar el euskera por bueno sin esa revisión.**
9-ter. **Bilingüismo de toda la app** (no solo la presentación): decidir alcance (es+eu mínimo; ¿se contempla algún tercer caso?) y si los PDF oficiales se emiten bilingües. Ver decisión "Lenguas" en `CLAUDE.md`.

## B. Compliance ganadero (asesor veterinario + técnico OCA + decreto foral Navarra)

10. **Formato vigente del libro de explotación ganadera** y de las **guías de movimiento pecuario / DST** conforme a normativa estatal + decreto foral de Navarra. Validar antes de cada release.
11. **SITRAN / RIIA**: alcance de la integración (¿sólo registro local exportable, o conexión digital?).
12. **Certificación ecológica CPAEN/NNPEK**: qué trazabilidad exige el consejo regulador navarro para ganadería ecológica extensiva.
13. **Catálogos** (`razas_bovino_ovino`, `medicamentos_veterinarios` con plazos de supresión, `patologias_extensivo` con declaración obligatoria, `tipos_pasto_carga`, `calendario_ganadero`): validación por veterinario asesor + descarga del registro de medicamentos vigente. Hard limit: sustancias activas, nunca marcas.

## C. Backend y plataforma (decisión compartida con F4 de agro)

14. **Stack de backend multi-rol** — ⚠️ resuelto parcialmente el 2026-09-22: se usa el **WordPress propio de Zunbeltz** (no el plugin Kids, ni un backend Solera independiente hosteado por nosotros), vía un plugin standalone nuevo (`wp-plugin/solera-zunbeltz-sync/`). Desde el mismo día (plugin v0.2) hay **personas con rol y token personal** gestionadas desde el admin de WP — ver 14-ter. **Lo que NO resuelve todavía**: roles de mentor y asesor, y el reparto de permisos validado con Zunbeltz. El auth de profesor/cuidador del companion sigue sin tocar.
14-bis. **Sincronización de tareas — adelantada fuera de orden el 2026-09-22**, a petición expresa, sin esperar a que este bloqueo estuviera cerrado del todo. Alcance real de lo construido:
    - Solo sincroniza **tareas de mantenimiento** (título, descripción, responsable, prioridad, estado, fecha objetivo, coste, recurrencia). Fincas, puntos y zonas siguen sin sincronizar.
    - Una tarea se empareja entre dispositivos por **nombre de finca** (no hay id compartido de finca todavía); si está anclada a un punto o zona pierde ese anclaje al llegar a otro dispositivo.
    - Merge **last-write-wins** por marca de tiempo de edición (`actualizado_ms`), sin resolución de conflictos más fina.
    - ~~Auth de token único compartido~~ — sustituido en la v0.2 del plugin (14-ter). El token compartido de la v0.1 se borra al actualizar.
    - Falta por decidir con Zunbeltz: quién instala/mantiene el plugin en su WP.
14-ter. **Roles y permisos sobre tareas — construido el 2026-09-22 (plugin v0.2, BD app v8), pendiente de co-diseño.**
    - **Personas** (tabla `wp_solera_zunbeltz_personas`) dadas de alta por la coordinación en el admin de WP (menú "Solera Zunbeltz"): nombre, rol, **token personal** (se muestra una vez; en BD sólo el SHA-256), activar/desactivar, regenerar token. No son usuarios de WordPress (no necesitan entrar al escritorio); enlazarlas con cuentas WP sería añadir `wp_user_id`.
    - **Roles → capacidades** en `includes/roles.php`, ampliable con el filtro `szs_roles`. La app no conoce roles, sólo capacidades (`ver_todas_tareas`, `crear_tareas`, `editar_cualquier_tarea`, `asignar_tareas`), así que un rol nuevo no exige publicar otra versión de la app.
    - **Reparto provisional**: *Coordinación (admin)* crea, edita y asigna todo. *Tester* ve todo el espacio y crea tareas; ejecuta (estado, coste) las suyas o las que creó, edita el contenido de las que creó, se coge tareas libres y suelta las suyas; no asigna a otras personas (si lo intenta, la tarea entra sin asignar).
    - **El servidor manda**: aplica la política al sincronizar (`includes/politica-tareas.php`) y devuelve `forzar` + `rechazos`; la app sobrescribe con la versión del servidor lo rechazado. La app replica las reglas (`lib/servicios/politica_tareas.dart`) sólo para no ofrecer lo que se va a rechazar. Sin sincronización configurada la app sigue en modo local, sin restricciones.
    - **A decidir con Zunbeltz**: si el tester ve todas las tareas o sólo las suyas (basta quitar `ver_todas_tareas`); si el tester puede asignar; roles de **mentor** y **asesor** y qué ven; qué pasa con fincas/puntos/zonas (hoy locales, sin permisos); RGPD de la evaluación de viabilidad (punto 6), que llegará con la Capa B.

15. **Monetización B2B**: licencia anual a la entidad gestora vs modelo por ETA en la red. Financiación pública de Zunbeltz lo descarta como SaaS individual.
16. **`applicationId` y branding visual definitivo** (logo, splash, paleta extendida más allá de monte+crema+ocre).

## D. Fiscal (asesor fiscal humano — patrón heredado del resto de Solera)

17. **Libro ingresos/gastos + extracto** (FZ-8): régimen REAGP ganadero, IVA de venta de terneros/corderos y venta directa, prima PAC/ecorégimen como bloque aparte. Banner PROVISIONAL hasta firma. Coherente con la memoria del repo: *contabilidad por vertical, gateada por el contexto fiscal español*.

## E. Distribución y costes externos (decisión comercial — hablado 2026-06-19)

18. **Plataformas de publicación**: la Fase 1 es single-device y **no necesita servidor ni dominio** (todo el coste es desarrollo). Para distribuir: **Google Play Console** son 25 USD pago único; **Apple Developer** 99 USD/año si se quiere iPhone/iPad; alternativa sin tienda: APK directo (0 €). Decidir con Zunbeltz si se publica en tienda y en qué plataformas. La app ya tiene target Android (`com.coleccionnuevoser.solera_zunbeltz`) y compila en Linux.
19. **Costes recurrentes a partir de FZ-9 (multiusuario)**: servidor en la nube + base de datos, dominio (~10-15 €/año), SSL (gratis Let's Encrypt), mantenimiento y **asesoría RGPD** (la evaluación de testadores es dato personal sensible). Comparte la decisión de stack con F4 de agro.

## F. Estado de lo construido (FZ-1 → FZ-3) — validaciones pendientes

20. **Euskera de los ARB (`lib/l10n/app_eu.arb`) y de los catálogos (`lib/modelos/constantes.dart`) = borrador propio**. Revisión nativa pendiente (ver A-bis 9-bis), sobre todo la terminología agroganadera (manga de manejo, larre-saila, askatokia…).
21. **Datos de fincas = seed de ejemplo** (`sembrarFincasDemoSiVacia`: Zunbeltz 231 ha, La Planilla 197 ha, centroides aproximados). Los recintos SIGPAC, infraestructuras y tareas reales se cargan con el equipo (A4/A5).
22. **Parte de mantenimiento PDF** sale con sello PROVISIONAL; formato a validar antes de uso oficial.

## G. Referencia de mercado — VacApp (revisada 2026-09-14)

23. **Escáner del código de barras del DIB** (mercado: VacApp lo tiene). Teclear crotales es *la* fricción real del ganadero. Implementable con `mobile_scanner`; entra como **requisito de FZ-4**, no como extra. Pendiente de confirmar con el asesor/veterinario qué codificación llevan los DIB navarros vigentes y si el crotal ovino (REIA) admite lectura equivalente — **no inventar el formato**.
24. **Import/export Excel visible para la persona usuaria** (mercado: VacApp lo tiene). `csv_io` del core ya existe pero sólo como tubería interna; hay que exponerlo como función de primera clase en FZ-4/FZ-5.
25. **Importar datos de herramientas previas**: si algún tester ya lleva su rebaño en otra app, poder tragar su export sería puente y no amenaza. Pendiente: confirmar con Zunbeltz si alguien usa ya alguna, y con qué formato exporta.
26. **Encuadre del discurso comercial**: existen cuadernos de vacuno consolidados y gratuitos (VacApp: iOS/Android/Windows/Linux, offline, gratis, "por ganaderos para ganaderos"). Nuestro diferencial **no** es la Capa A, sino multi-rol + fincas compartidas + análisis por proyecto/tester + replicabilidad a la red estatal de ETAs. Riesgo a neutralizar de frente: *"¿para qué, si aquello es gratis?"*. Ya reflejado en `presentacion/index.html` (sección "No reinventamos el cuaderno ganadero").

---

**Principio rector**: esta app se **co-diseña** con Zunbeltz Elkartea. La propuesta (CLAUDE.md + presentación) es un punto de partida sólido para que ellas lo discutan y aporten, no un diseño cerrado.
