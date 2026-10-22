# Solera — CLAUDE.md

Cerebro persistente del proyecto. Se lee al inicio de cada sesión.

> **2026-10-22 — PDF con letra incrustada y números a la española (0.3.3+6)**. Los cuatro PDF (campaña, extracto económico, cuaderno MAPA, factura) usan `temaPdfSolera()` del core (Archivo incrustada: con Helvetica «€» y «—» salían en blanco). Los importes, cantidades y superficies de los formularios (ingreso, gasto, factura, evento, SIGPAC) se leen con `leerNumero`/`centimosDesdeTexto` del core («1.200,50» ya no se guarda como 0) y los validadores avisan si no se entiende (`utiles/numeros_formulario.dart`).

## Encuadre

App **producto comercial general** (no del operador, no Kids). Gestor de fincas agrícolas para Iberia: frutales, truficultura, olivar, pistacho, vid, dehesa y forestal. Entidad central = **planta con identidad persistente** (cada árbol tiene historia: cosechas, observaciones, incidencias, tratamientos), distinto del modelo "evento puntual" de fósiles/naturaleza.

Vive en `apps/agro/` del monorepo `nuevo-ser/`. Aprovecha el stack común de fósiles/naturaleza (sqflite, flutter_map, geolocator, image_picker, cached_network_image) sin compartir todavía con `nuevo_ser_core` — pendiente de extracción cuando se valide el modelo.

## Stack

- `flutter_map` ^7.0.2 + `latlong2` ^0.9.1 + `flutter_map_marker_cluster` ^1.4.0
- `geolocator` 12.0.0 + `permission_handler` ^11.3.1
- `image_picker` ^1.1.2 + `path_provider` ^2.1.4
- `sqflite` ^2.3.3 + `shared_preferences` ^2.3.2
- `cached_network_image` ^3.4.1 (preparado para galerías Wikipedia/IA)
- `pdf` ^3.11.1 + `printing` ^5.13.4 + `share_plus` ^10.0.2
- `file_picker` ^8.1.4 (import/export CSV)

Sin Flame, sin Riverpod, sin Isar.

## Posicionamiento

"Una app que se siente especializada en cada cultivo, no genérica." Modelo de datos genérico (Finca > Planta > eventos) con **modos verticalizados activables por cultivo** que traen catálogos curados, métricas, fenología y plagas específicas. El usuario con frutales+trufas+pistachos los activa todos en la misma app — no se la cambian por cultivo.

Diferenciadores frente a competencia (ver mapeo en respuesta del 2026-05-07):
1. **Modo trufas único en el mercado** (Croptracker, FruitForest, Leaftide… ninguno cubre truficultura).
2. **Cuaderno de Explotación Digital MAPA** (RD 1311/2012) — gancho de monetización profesional. **F3.**
3. **IA por foto con Claude vision** especializada por cultivo, contrastada contra catálogo curado y BBDD MAPA. **F2.**
4. **Punto suelto soportado de raíz** (planta sin finca obligatoria).
5. **Multi-operador con roles** (dueño, asesor agrónomo, peón) — pendiente F4.
6. **Voz manos libres** — F5.
7. **Offline real** (la app sólo va a la nube cuando hay sync).

## Estructura

```
lib/
├── datos/                 base_datos.dart, catalogo_cultivos.dart,
│                          catalogo_plagas.dart,
│                          catalogo_fitosanitarios.dart,
│                          info_cultivos.dart, fenologia.dart
├── modelos/               Finca, Planta, Cosecha, Observacion,
│                          Incidencia, Tratamiento, Track, Titular
├── pantallas/             hoy, mapa, lista_plantas, ficha_planta,
│                          nueva_planta, nuevo_evento, fincas,
│                          editar_sigpac, guia, estadisticas,
│                          importar_csv, reportes, backup, tracks,
│                          onboarding, clave_anthropic, titular,
│                          cuaderno_mapa, ajustes
│                          + widgets/{selector_fotos,
│                                     imagen_commons_widget,
│                                     boton_identificar_ia}
├── servicios/             gestor_fotos, csv_plantas, generador_pdf,
│                          generador_cuaderno_mapa,
│                          backup_servicio, grabador_track,
│                          servicio_commons, cliente_anthropic
├── estado/                finca_activa, ultimo_centro_mapa,
│                          clave_anthropic
└── utiles/                permisos_gps
```

## Modelo de datos (sqflite)

- `fincas` — finca opcional (las plantas pueden ser puntos sueltos con `finca_id NULL`).
- `plantas` — entidad central. `cultivo_id`, `variedad`, `latitud/longitud`, `etiqueta` (ej. A-17, fila 3), `patron` (o hospedero en trufa), `fecha_plantacion`.
- `cosechas`, `observaciones`, `incidencias`, `tratamientos` — eventos hijos de planta con FK ON DELETE CASCADE. `tratamientos` ampliado en v5 con `numero_registro_fitosanitario`, `nif_aplicador`, `superficie_tratada_hectareas` para Cuaderno MAPA.
- `tracks` + `track_puntos` — recorridos de inspección consolidados (mismo patrón que naturaleza/fósiles).
- `track_grabacion_buffer` — buffer incremental: cada fix GPS se persiste según llega para que un crash o kill OS no pierda el recorrido. `consolidarSesionesPendientes()` al arrancar la app recupera sesiones con ≥2 puntos como "Recorrido recuperado DD/MM HH:mm".
- `titulares` — titular único de la explotación (v4). Datos NIF + nombre + dirección + REGEPA + asesor agronómico opcional + aplicador opcional. Single-row enforced por la lógica de `guardarTitular` (upsert manual). Multi-titular llega en F4 con backend.
- `fincas` ampliado en v4 con SIGPAC (provincia/municipio/polígono/parcela/recinto) + `superficie_hectareas`. Free-text en v1 — F4 valida contra BBDD pública SIGPAC.

Migraciones escalonadas en `_aplicarMigraciones`. Nunca destructivo: agricultor en campo lleva años de cosechas y no podemos perder un dato.

## Catálogos

- **Cultivos** (`catalogo_cultivos.dart`): 30 entradas en 7 categorías (Truficultura, Forestal/dehesa, Frutal pepita, Frutal hueso, Fruto seco, Oleoso, Vid, Otro). Cada una con variedades + patrones/hospederos sugeridos. Cultivos truferos enlazan con `hospederosCultivoIds`; árboles forestales hospedables enlazan con `trufasHospedables` (navegación cruzada en la guía).
- **Plagas/enfermedades** (`catalogo_plagas.dart`): 27 entradas v1 con tipo (plaga/enfermedad/fisiológico/abiótico), cultivos afectados (lista), descripción, síntomas, condiciones favorables, manejo cultural. **Sin productos comerciales en v1** — eso entra en F2 con BBDD MAPA y validación agronómica.
- **Info agronómica** (`info_cultivos.dart`): descripción, exigencias, calendario, plagas notables (texto libre) por cultivo.

## Decisiones cerradas

- **Marca**: **Solera** (premium, tradición agrícola, registrable internacionalmente). Package interno se queda como `agro` y `applicationId com.josu.agro` por compat (no perder BD instalada). Si hay rebranding final en Play Store se rehace el package.
- **Multi-finca**: sí, soportada de raíz.
- **Puntos sueltos**: sí, soportados de raíz (planta sin finca).
- **Multi-operador**: pendiente F4 (backend + JWT). En v1 single-user local.
- **Sondas físicas**: NO en v1. Lecturas ambientales sólo manuales o vía servicio meteo (Open-Meteo, AEMET) en F2+.
- **Marketplace fitosanitarios**: pospuesto a v2 — necesita alianzas con tiendas + comisiones acordadas.
- **Cultivos prioritarios**: trufas (3 especies) + frutales + olivar + pistacho. Hermano truficultor disponible para validar info de Tuber spp y plagas asociadas.

## Hard limits

- **No recomendar productos fitosanitarios comerciales sin validación agronómica + BBDD MAPA**. En v1 sólo prácticas culturales no-químicas (poda, trampeo, riego, manejo del suelo).
- **No inventar datos agronómicos**. Conservador: si no hay fuente clara y verificable, omitir o marcar "v2 con catálogo curado".
- **Compliance MAPA es load-bearing**. Si añadimos cuaderno de explotación digital (F3), el formato XML cambia con la regulación; hay que seguirlo activamente.
- **No bloquear al usuario por fallos no críticos**. Patrón heredado del monorepo: errores de I/O (foto que no se borra, sync que falla) se silencian con `catchError((_){})` y se reintentan al siguiente arranque.

## Roadmap

| Fase | Estado | Entregable |
|---|---|---|
| F0 Scaffold | ✅ | apps/agro creado, modelo de datos, navegación esqueleto |
| F1 MVP | ✅ | Mapa con clustering, modo censo, ficha planta con timeline, fotos en eventos, importar/exportar CSV, estadísticas, PDF de campaña, guía de cultivos+plagas |
| F1.A Pulir | ✅ | Editar planta/eventos, foto de planta, búsqueda, long-press en mapa, branding Solera, CLAUDE.md, `flutter analyze` a 0 |
| F1.B Tracks + onboarding + backup | ✅ | Tracks GPS de inspección con buffer incremental anti-crash + GPX export, onboarding 4 pasos en primer arranque, pantalla de backup zip (BD + fotos) con restauración con safety backup pre-restore, "qué toca esta semana/mes" en pantalla Hoy con calendario fenológico por cultivo |
| F2 IA | ✅ | BYO key Anthropic (Claude Haiku 4-5 vision) — clave sólo en SharedPreferences local, llamadas device→Anthropic sin servidor intermedio. Botón "Identificar con IA" en formulario de incidencia: análisis de foto, contraste contra `catalogo_plagas` por matching fuzzy de nombre científico/común, modal con confianza + manejo cultural sugerido. Pre-rellena tipo/diagnóstico/severidad y antepone notas auto. Hard limit: NO recomienda productos comerciales (sólo manejo cultural — compromiso legal v1) |
| F3 Cuaderno MAPA | ✅ (PDF) | PDF de Cuaderno de Explotación con titular + asesor + aplicador + parcelas SIGPAC + tratamientos fitosanitarios + otros tratamientos + incidencias justificativas, conforme RD 1311/2012. Modelo `Titular` (single-row v1) en BD v4 + ampliación de `Finca` con SIGPAC/superficie y `Tratamiento` con núm registro fitosanitario/NIF aplicador/superficie tratada (BD v5). Validador previo bloquea generación si faltan datos críticos. **Export XML SIEX/CUE oficial diferido** — la spec varía por campaña y nadie debería generar un XML que no aguante validación XSD del año en curso |
| F3+ Refuerzo profesional | ✅ | Catálogo semilla curado de fitosanitarios (`catalogo_fitosanitarios.dart`) con 11 productos ecológicos/de bajo impacto + `Autocomplete<ProductoFitosanitario>` en el campo "Producto" del formulario de tratamiento que auto-rellena núm registro, dosis sugerida y plazo de seguridad. Validador del cuaderno MAPA avisa cuando un fitosanitario aplicado a una planta tiene cultivo no autorizado en su registro (uso fuera de etiqueta) — aviso, no bloqueo. Coherente con hard limit de Solera: lista sólo ecológicos/bajo impacto en v1; ampliación a convencionales requiere validación agronómica |
| F3.5 Libro ingresos/gastos + extracto fiscal | ✅ con datos provisionales | 4 modelos (Tercero, ConfiguracionFiscal, ApunteIngreso, ApunteGasto) + migración BD v5→v6 puramente aditiva (4 tablas nuevas con FK a fincas y a tratamientos para sinergia con cuaderno MAPA). Pantalla de **Configuración fiscal** con régimen IRPF (estimación directa simplificada o normal) + IVA (REAGP con compensación 12% o régimen general). Pantalla de **Terceros** con CRUD lista + sheet edición; el NIF marca qué entradas alimentan el modelo 347. Pantalla **Libro económico** con TabBar 3 pestañas (Ingresos / Gastos / Resumen), selector de año en cabecera, FAB nuevo apunte. Formularios `PantallaNuevoIngreso` y `PantallaNuevoGasto` con autocálculo de IVA/compensación según régimen del titular (anulable manualmente — la factura real puede diferir un céntimo del cálculo), categorías agro concretas (venta_cosecha con cultivoId, venta_lena_madera, alquiler_terreno, **ayuda_pac y subvencion_autonomica como bloque aparte** del ingreso ordinario; insumos, tratamientos_fitosanitarios con `tratamientoId` opcional, maquinaria, mano_obra, combustible, seguros, riego_agua, transporte, veterinario_animal para dehesa, certificacion DOP/IGP/eco), foto de factura vía `SelectorFotos` del core, imputación a parcela_concreta / cultivo_general / general. Pantalla **Extracto económico anual** que genera PDF reutilizando `informe_periodico_pdf` del core con 6 tablas: ingresos por mes, gastos por mes, modelo 347 (terceros >3.005,06€/año), apuntes sin NIF (alerta — no entran al 347), detalle cronológico de ingresos con cultivo, detalle cronológico de gastos con imputación. Importes en céntimos para evitar errores de redondeo. 19 tests POJO nuevos. **Banner amarillo "PROVISIONAL"** persistente en libro económico, configuración fiscal y extracto anual. Cableado en pantalla_ajustes con 3 entradas nuevas. **Asunciones provisionales aplicadas** en `BLOQUEOS-PENDIENTES.md` F3.5: módulos NO soportado v1 (probable que el asesor lo pida en agro — más usado que en apicultura), REAGP + ED simplificada como regímenes ofrecidos, IVA cosecha 4% por defecto régimen general (alimento 1ª necesidad), IVA insumos agrarios 4% reducido por defecto, IVA seguros 0% (exentos), IVA mano de obra agrícola 0% por defecto, IVA riego/agua 10% reducido, IVA otros gastos 21% general, alquiler terreno con uso agrícola exento de IVA, reparto proporcional por hectárea de gastos imputados a `cultivo_general` listado pero no calculado (importe íntegro asignable al cultivo). |
| F4 Backend nube | **decisión humana pendiente** | Multi-operador con roles, sync, equipos. Stack a decidir (plugin WP Kids vs backend independiente Solera) + modelo de auth + Stripe. Detalle en "Decisiones humanas pendientes" |
| F5 Voz + marketplace | pendiente | Voz manos libres, marketplace fitosanitarios |
| F6 Lanzamiento | pendiente | Stores, web, primeros suscriptores |

## Comandos habituales

```bash
export PATH="$HOME/flutter/bin:$PATH"
( cd apps/agro && flutter analyze )
( cd apps/agro && flutter test )
( cd apps/agro && flutter run -d linux )
( cd apps/agro && flutter build apk --debug )
( cd apps/agro && adb -s 17ce64ca install -r build/app/outputs/flutter-apk/app-debug.apk )
```

## Reglas de interacción

- **Voz adulta directa**. Producto profesional/semi-profesional, no Kids — no aplica la voz amable de la biblia del cuaderno.
- **Nombres descriptivos en castellano** (regla del monorepo).
- **Antes de meter información agronómica nueva**: verificar fuente o consultar al hermano truficultor. Si no hay fuente, dejar entrada en placeholder con etiqueta "v2".
- **Tests**: pendientes. Cuando entren, foco en CSV import/export, parser fenológico, generador PDF.

## Decisiones humanas pendientes

- Validación del catálogo de trufas (Tuber spp) y plagas asociadas por el hermano truficultor.
- Validación general del catálogo de plagas (todos los cultivos) por agrónomo de confianza antes de publicación pública.
- Decidir alianzas para marketplace (Agroterra, Cosechando, otros).
- Logo y branding visual (paleta, tipografía) para "Solera".
- Decisión sobre `applicationId` final (`com.josu.agro` actual vs rebrand a `com.josu.solera`) antes de publicar en Play Store.
- **Export XML SIEX/CUE oficial**: validar la spec XSD vigente con el MAPA o un asesor antes de implementar. La estructura cambia por campaña y sirve un PDF para inspección presencial mientras tanto.
- **Validación del PDF de Cuaderno por inspector real** (técnico de Conselleria/Junta) antes de publicación pública — formato cubre los apartados del RD 1311/2012 pero conviene confirmar lo que esperan ver en una visita real.
- **Validación del catálogo de fitosanitarios** (`catalogo_fitosanitarios.dart`): semilla v1 con 11 productos ecológicos/de bajo impacto (caldo bordelés, hidróxido de cobre, azufre, aceites parafínicos, Bt kurstaki, spinosad, jabón potásico, azadiractina, polisulfuro de calcio, feromonas Lobesia y Prays). Los `numeroRegistroEjemplo` son representativos del rango — el agricultor debe verificar el código vigente del envase antes de archivarlo. Antes de publicación pública: validar lista con agrónomo + ampliar a productos comerciales típicos de cada cultivo (manteniendo el sesgo a ecológicos/integrados que el hard limit de Solera exige).
- **F3.5 Libro ingresos/gastos — asesor fiscal humano** antes de quitar provisional. Un error en el extracto fiscal cuesta dinero al usuario con Hacienda, así que sube el listón igual que el cuaderno MAPA. Antes de no-provisional: (1) asesor fiscal valida formato del libro registro y del extracto trimestral/anual conforme práctica AEAT; (2) decidir qué regímenes fiscales soporta v1 (mínimo: estimación directa simplificada + REAGP — son los dominantes en agricultor pequeño; ¿módulos también?); (3) política RGPD de retención de NIF de clientes/proveedores recurrentes; (4) ayudas PAC y subvenciones como categoría separada del ingreso ordinario para que el extracto las separe correctamente; (5) política de adjuntar foto de factura: ¿obligatorio o opcional? ¿se añade al backup zip o vive sólo en local?
- **F4 Backend nube — decisión humana** antes de cualquier implementación. Tres preguntas abiertas:
  1. **Stack**: ¿reusar el plugin WordPress `nuevo_ser_core` (compartido con Kids) o levantar backend Solera independiente? Solera necesitará Stripe/IBAN, BBDD MAPA viva, validación SIGPAC contra catastro — cosas que NO encajan en el plugin Kids. Probable necesidad de separar.
  2. **Modelo de auth multi-operador**: (A) cuenta personal con N explotaciones, (B) cuenta de explotación con N usuarios invitados con roles, (C) SSO Google/Apple + invitación por email. Cada uno tiene implicaciones en el JWT, el modelo de datos del backend y la pantalla de login en la app.
  3. **Monetización**: subscription única para titular vs por-explotación, plan free vs paid (¿paywall en cuaderno MAPA? ¿en multi-operador? ¿en sync de fotos?). Stripe + lo que requiera la AEAT.
  Hasta que haya decisión, el backend queda fuera del roadmap activo. Funciones offline (catálogo MAPA, IA, cuaderno PDF, tracks, backup zip) cubren el flujo completo single-user.
