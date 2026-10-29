# Larrea Apícola — CLAUDE.md

Cerebro persistente del proyecto. Se lee al inicio de cada sesión.

## Encuadre

Segundo fork de la **Suite Larrea** dentro del monorepo. Producto comercial dirigido a **apicultores profesionales y semi-profesionales** (20-200 colmenas) en la península ibérica. Hermana técnica de `apps/agro` (Larrea generalista) y `apps/solera-viticultura` (primera vertical especializada).

Modelo de negocio: suscripción **€8-20/mes por explotación**. Comprador identificable: apicultor que hoy lleva el libro oficial en papel o Excel y se le acumulan multas por desfases en SITRAN apícola. Ticket bajo, volumen alto, mercado muy concreto.

## Posicionamiento — diferenciadores

1. **Libro oficial REGA conforme** (RD 209/2002 + Reglamento CE 853/2004 sobre subproductos) generado en PDF firmable desde el campo. Adiós a las hojas Excel. **F1A-5.**
2. **Gestión de varroa**: tratamientos con sustancias autorizadas + plazos de seguridad + registro automático en el libro oficial. **F1A-4 + F1A-5.**
3. **Trashumancia bien modelada**: la colmena es identidad persistente con matrícula, los movimientos son un evento de pleno derecho con origen+destino+fecha. Lo que casi nadie hace bien.
4. **IA por foto vid-específica del colmenar**: identificación de varroa, nosema, loque (americana y europea), ascosferiosis, vespa velutina, polilla de la cera. **F1A-6.**
5. **Análisis acústico** para predicción de enjambrazón (micrófono + DSP en F2 — innovación de marca).

## Stack

Heredado de la suite Larrea. Dependencias en `pubspec.yaml`. Consume `nuevo_ser_core` por path local para `GestorFotos`, `csv_io`, `informe_periodico_pdf` y todas las primitivas reutilizables.

## Estructura

```
lib/
├── datos/                 (pendiente) base_datos.dart, catalogos_generados/
├── modelos/               (pendiente) Apiario, Colmena, Revision, CosechaMiel,
│                          TratamientoVarroa, IncidenciaApicola, Movimiento,
│                          Apicultor (REGA)
├── pantallas/             (pendiente) hoy, mapa, lista_colmenas, ficha_colmena,
│                          nueva_colmena, nuevo_evento, apicultor, libro_rega,
│                          ajustes
├── servicios/             (pendiente) cliente_anthropic, generador_libro_rega
├── estado/                (pendiente) apiario_activo, clave_anthropic
├── utiles/                (pendiente) permisos_gps
└── main.dart              esqueleto v0.1

content/apicola/           (pendiente F1A-4) CSVs editables por asesor
tool/compilar_catalogos.dart (pendiente F1A-4)
```

## Modelo de datos planificado (sqflite)

Forkeado del patrón de viticultura con renombrados y el evento extra de **Movimiento**:

- `apiarios` (era `vinedos`) — colmenar con localización aproximada y código REGA específico del asentamiento.
- `colmenas` (era `cepas`) — entidad central con **matrícula** (string única, p. ej. `IB-2023-042`), tipo (Layens, Dadant, Langstroth, Warré), raza de abeja, año de la reina (color identificador por ciclo de 5 años), estado (viva/vacía/descolmenada/enjambre nuevo).
- `revisiones` (era `observaciones`) — visita rutinaria del apicultor: presencia de reina, postura, cría operculada, miel, polen, varroa estimada (caída diaria o sticky board).
- `cosechas_miel` — kilos de miel, cera, polen, propóleo, jalea real con fecha y número de alza si aplica.
- `tratamientos_varroa` (era `tratamientos`) — sustancia autorizada, dosis, fecha aplicación, fecha retirada, plazo de seguridad, lote del producto, número de factura para trazabilidad REGA.
- `incidencias` — mortalidad, enjambrazón, robo, ataque vespa velutina, polilla de la cera, etc.
- `movimientos` — **evento clave en apicultura**. Registra trashumancia: apiarioOrigen, apiarioDestino (o ubicaciones puntuales si no son apiarios fijos), fecha, número de colmenas movidas, motivo (mielada/invernada/sanitario/recogida).

## Catálogos planificados (F1A-4)

5 CSVs en `content/apicola/`:

- `razas_abeja.csv` — Apis mellifera ibérica, A. m. carnica, A. m. ligustica, Buckfast, híbridos.
- `sustancias_varroa.csv` — ácido oxálico, ácido fórmico, timol, amitraz, flumetrina, fluvalinato, mezclas comerciales. Cada una con: vehículo (sublimación/sandwich/tira), eficacia esperada, plazo de seguridad para miel, autorizada en ecológico (s/n), notas.
- `plagas_apicolas.csv` — varroa, nosema (apis y ceranae), loque americana (*Paenibacillus larvae*), loque europea (*Melissococcus plutonius*), ascosferiosis (*Ascosphaera apis*), virus DWV/CBPV, vespa velutina, polilla cera, escarabajo de las colmenas (*Aethina tumida*).
- `calendario_apicola.csv` — ventanas por zona (norte/sur peninsular) de las tareas clave: revisión primaveral, traslado a mielada, cosecha, primer tratamiento varroa, invernada, segundo tratamiento varroa.
- `tipos_colmena.csv` — Layens (mediterránea típica), Dadant, Langstroth, Warré, Top-Bar.

## Roadmap

| Fase | Estado | Entregable |
|---|---|---|
| F1A-1 Esqueleto | ✅ | apps/solera-apicola/ creado, pubspec, branding mínimo, dependencia del core |
| F1A-2 Modelos + BD | ✅ | Apiario, Colmena, Revision, CosechaMiel, TratamientoVarroa, IncidenciaApicola, Movimiento, Apicultor + sqflite v1. 16 tests POJO incluyendo color marca reina por ciclo de 5 años |
| F1A-3 Pantallas básicas | ✅ | PantallaMapa (clustering OSM, FAB GPS), PantallaListaColmenas (busca + filtra), PantallaFichaColmena (timeline 5 tipos eventos), PantallaNuevaColmena (matrícula única validada), PantallaNuevoEvento (revision/cosecha/tratamiento/incidencia/movimiento). Versión minimalista — sin catálogos curados (text-input libre hasta F1A-4) |
| F1A-4 Catálogos provisionales | ✅ con datos provisionales | 5 CSVs en `content/apicola/` (7 razas, 7 tipos colmena, 9 sustancias varroa, 16 plagas, 36 tareas calendario × 3 zonas) + `tool/compilar_catalogos.dart`. Autocomplete cableado en raza/tipo (PantallaNuevaColmena), sustancia activa (PantallaNuevoEvento tratamiento, auto-rellena plazo seguridad) y diagnóstico (PantallaNuevoEvento incidencia con banner rojo si declaración obligatoria). Mapeo automático de tipo BD por id especial (vespa_velutina/polilla_cera/robo). 17 tests catálogos. **Datos provisionales sin validar** — esperando veterinario apícola asesor + descarga registro MAPA vigente. |
| F1A-5 Libro oficial REGA | ✅ con caveat | PantallaApicultor (titular + veterinario asesor con colegiado), PantallaLibroRega (selector apiario + campaña, generar y compartir / abrir), `generador_libro_rega.dart` que reusa `informe_periodico_pdf` del core. 4 tablas (tratamientos sanitarios, movimientos, incidencias, cosechas). **Caveat**: el formato exacto vigente del libro REGA debe validarse contra la circular MAPA + decreto autonómico antes de inspección — registrado en BLOQUEOS-PENDIENTES.md. |
| F1A-6 IA Claude Vision apícola | ✅ con caveat | BYO key Claude Haiku 4.5, prompt curado apícola con lista canónica de patologías peninsulares (varroosis, nosemosis A/C, loque americana/europea, ascosferiosis, DWV, CBPV, vespa velutina, polilla cera, escarabajo colmenas), banner rojo de declaración obligatoria automatizado para los 3 ids regulados, matching fuzzy del diagnóstico contra catálogo (3 estados: verde validado / amarillo provisional / naranja libre). Auto-rellena tipo de incidencia BD respetando los ids especiales (vespa_velutina/polilla_cera/robo). Hard limit: NO recomienda medicamentos zoosanitarios comerciales — sólo manejo cultural y derivación al veterinario asesor. **Caveat**: hasta validación del catálogo F1A-4 todo diagnóstico va marcado como "provisional". |
| F1A-7 Pulido | ✅ con caveat | Onboarding 3 cards primer arranque (PageView con flag persistido en SharedPreferences), backup ZIP de BD+fotos con safety pre-restore (heredado patrón viticultura), pantalla acerca con compromisos legales explícitos sobre medicamentos veterinarios + declaración obligatoria + formato REGA, pantalla ajustes consolidando Apicultor + IA + Backup + Acerca, menú overflow del mapa simplificado a "Libro REGA" + "Ajustes". main.dart orquestador onboarding → mapa. **Caveat**: branding visual definitivo (logo, splash, paleta extendida más allá de ámbar+crema) sigue siendo decisión humana — registrado en BLOQUEOS-PENDIENTES.md. |
| F1A-8 Branding + refactor al core | ✅ | Logo cabecera (`assets/icono-logo-apicultura.png` — hexágonos panal en ámbar), iconos lanzador Android adaptive (5 mipmap-* + adaptive icon Android 8+ via `flutter_launcher_icons`), splash screen Android (incluye Android 12+ via `flutter_native_splash`) sobre fondo crema `#FAF6E8`. **Refactor**: `CampoAutocompleteCatalogo<T>`, `SelectorFotos`, `BannerCoincidenciaCatalogo`/`BannerDeclaracionObligatoria` extraídos al `nuevo_ser_core` (`src/ui/`) — la app pasa a consumirlos por barrel y elimina los widgets locales duplicados (compartidos con viticultura y arbolado). Banner declaración obligatoria reutiliza el del core en `pantalla_nuevo_evento.dart` y en el modal IA. |
| F1A-9 Catálogos pre-curados con fuente pública | ✅ | Las 5 CSVs marcadas con `revisado_por=fuente_pública` (COLOSS + Cánovas et al. 2008, AEMPS CIMA Vet + RD 1132/2010, WOAH Manual + RD 1492/2009 + UE 2018/1882 + RD 630/2013, FEDAS + cooperativas regionales, RD 209/2002 + bibliografía apícola). **Cambios sanitarios trazables**: loque europea bajada a `declaracion_oficial=no` (depende RD autonómico, no claramente regulada nivel nacional); **Tropilaelaps spp. añadido** con `declaracion_oficial=si` (UE 2018/1882 clase A + WOAH 3.2.8). Generador libro REGA verificado conforme RD 209/2002. SITRAN-AP digital anotado en BLOQUEOS para F1.1. `catalogosCompletamenteRevisados=true` — el banner "datos provisionales" queda desactivado. **Pendiente auditoría humana**: veterinario apícola asesor firma y sustituye `revisado_por` por su nombre + nº colegiado; verifica RD autonómico de cada CCAA por si añade patologías reguladas regionales (loque europea principal candidato). |
| F1A-10 Libro ingresos/gastos + extracto fiscal | ✅ con datos provisionales | 4 modelos (Tercero, ConfiguracionFiscal, ApunteIngreso, ApunteGasto) + migración BD v1→v2 puramente aditiva (4 tablas nuevas, FK no destructivas). Pantalla de **Configuración fiscal** con régimen IRPF (estimación directa simplificada o normal) + IVA (REAGP con compensación 12% o régimen general). Pantalla de **Terceros** con CRUD lista + sheet edición; el NIF marca qué entradas alimentan el modelo 347. Pantalla **Libro económico** con TabBar 3 pestañas (Ingresos / Gastos / Resumen), selector de año en cabecera, FAB nuevo apunte. Formularios `PantallaNuevoIngreso` y `PantallaNuevoGasto` con autocálculo de IVA/compensación según régimen del titular (anulable manualmente — la factura real puede diferir un céntimo del cálculo), categorías apícolas concretas (miel/polen/cera/propóleo/jalea/**alquiler polinización** en ingresos; alimentación/sanidad varroa/material/transporte trashumancia/mano obra/veterinario/seguros/combustible en gastos), foto de factura vía `SelectorFotos` del core, imputación de gastos a colmenar concreto / reparto proporcional / general. Pantalla **Extracto económico anual** que genera PDF reutilizando `informe_periodico_pdf` del core con 6 tablas: ingresos por mes, gastos por mes, modelo 347 (terceros >3.005,06€/año), apuntes sin NIF (alerta — no entran al 347), detalle cronológico de ingresos, detalle cronológico de gastos. Importes en céntimos para evitar errores de redondeo. 32 tests POJO nuevos (16 modelos + getters derivados). **Banner amarillo "PROVISIONAL"** persistente en libro económico, configuración fiscal, extracto anual y bullet en Acerca. Cableado en pantalla_ajustes con 3 entradas nuevas (Configuración fiscal / Terceros / Libro económico). **Asunciones provisionales aplicadas** en `BLOQUEOS-PENDIENTES.md` F1A-10: módulos NO soportado v1, REAGP + ED simplificada como regímenes dominantes, IVA polinización 21% general, IVA alimentación animal 10% reducido, IVA otros gastos 21% general, reparto proporcional de trashumancia listado pero no calculado (importe íntegro en cada apunte). |
| Pulido 2026-10-22 (0.1.3) | ✅ | Los tres PDF (libro REGA, extracto económico, factura) usan `temaPdfSolera()` del core (Archivo incrustada: «€» y «—» ya no salen en blanco). Los importes y cantidades de los formularios (gasto, ingreso, factura, cosecha, superficie del apiario) se leen a la española con `leerNumero`/`centimosDesdeTexto` del core y avisan si no se entienden (`utiles/numeros_formulario.dart`) en vez de guardar 0. |
| Pulido 2026-10-22 (0.1.4) | ✅ | Duplicados con el core retirados: `ServicioChat`, `AutoBackup` y `ServicioMeteoAgro` se usan del core, y `utiles/numeros_formulario.dart` deja paso a los validadores comunes (`validarNumeroOpcional`, `validarImporteOpcional`, `leerEntero`…; mensajes por SoleraL10n). **Ajustes por secciones** (`CabeceraSeccionAjustes`): Explotación · Registros y documentos (ahora también Libro REGA y Apiarios, que siguen en el menú del mapa) · Inteligencia artificial · Preferencias · Datos · Aplicación. **Buscador de lugares** en el mapa (lupa, `buscarLugarEnMapa` del core). `pantalla_chat.dart` sigue sin abrirse desde ningún sitio. |
| Pulido 2026-10-22 (0.1.5) | ✅ | Adopción de piezas comunes del core: **clave de Anthropic** con `EstadoClaveAnthropic.paraApp('solera_apicola')` + `PantallaClaveAnthropic` (misma preferencia, botón «Probar la clave»); el **diagnóstico por foto** va por `ClienteClaude` (Haiku 5.5, esfuerzo bajo, `pedirJson`, errores de `ErrorClaude` incluida la negativa) con su prompt y cruce con el catálogo; **facturas** con `Factura`/`GeneradorFacturaPdf` del core; **copia de seguridad** con `ServicioCopiaSeguridad` (`servicios/copia_seguridad_apicola.dart`: valida antes de restaurar, enseña la fecha, respaldo automático y vuelta atrás; `recuperarRestauracionInterrumpida()` en `main()`; lee los ZIP `solera-apicola-backup-…` de antes). **Barra inferior**: Hoy · Mapa · Colmenas · **Registros** (Libro REGA, facturas, libro económico, extracto) · Ajustes; la **Guía** pasa a un icono de libro en la barra de Hoy, y Hoy gana la entrada **Asistente (chat)** (`ServicioChat` del core con la clave de la app; antes `pantalla_chat.dart` no se abría). Apiarios, en Ajustes → Explotación y en el menú del mapa. ⚠️ Pendiente: `estaVacia()` (para `AutoBackup`) consulta la tabla `hallazgos`, que no existe aquí: la restauración automática al arrancar nunca actúa (falla en silencio). |
| F2 Análisis acústico | futuro | Micrófono + DSP para predecir enjambrazón |

## Hard limits

- **No recomendar productos comerciales fitosanitarios para varroa**. En catálogo van **sustancias activas** (ácido oxálico, timol…), no marcas comerciales (Apivar, ApiBioxal…). Compromiso legal idéntico al de viticultura.
- **No inventar datos sanitarios**. Conservador: si no hay fuente clara (RD vigente, Reglamento CE), placeholder "v2".
- **Compliance REGA es load-bearing**. El formato del libro oficial cambia con cada actualización del MAPA + decreto autonómico (Andalucía, Galicia, Castilla-La Mancha tienen variaciones); validar formato vigente antes de cada release.
- **Sanidad apícola es nivel veterinario**. La app NO sustituye al veterinario asesor; lo COMPLEMENTA llevando la trazabilidad documental.
- **Cero PlantNet, cero imágenes Commons en BD pre-cargada**. Caché de fotos = del cliente. Activos ilustrativos = stock comercial pagado o generación propia.

## Reglas de interacción

- **Voz adulta directa**, profesional. No Kids.
- **Nombres descriptivos en castellano** (regla del monorepo). Términos técnicos en su forma oficial: REGA, SITRAN-AP, varroa, *Apis mellifera ibérica*.
- **Tests antes del código no visual**: motor, sync, persistencia, parsing.
- **Antes de meter información sanitaria nueva**: verificar fuente del MAPA o consultar veterinario asesor. Sin fuente → placeholder "v2".

## Decisiones humanas pendientes

Ver `BLOQUEOS-PENDIENTES.md`.

- Validación de los catálogos por veterinario apícola asesor + descarga registro MAPA vigente.
- Formato exacto del libro oficial REGA conforme a la circular MAPA del año en curso.
- Posibles variaciones autonómicas (RD estatal + decretos CCAA).
- Logo y branding visual definitivo.
- `applicationId` final.
- **F1A-10 Libro ingresos/gastos — asesor fiscal humano** antes de quitar provisional. Decisiones acopladas: (1) régimen fiscal soportado v1 (REAGP de IVA con compensación 12% es muy típico en apicultura — confirmar con apicultor + asesor de cooperativa); (2) cómo modela la trashumancia el apunte de gasto (colmenar de origen, de destino, distribución por días — el camión mueve colmenas a varios destinos a la vez); (3) ingreso por **alquiler de colmenas para polinización** como categoría aparte (CNAE distinto del de venta de miel, IVA aplicable, encajar en el extracto sin que el asesor fiscal lo confunda con venta de miel).
