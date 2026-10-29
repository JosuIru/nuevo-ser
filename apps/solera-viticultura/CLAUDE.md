# Larrea Viticultura — CLAUDE.md

Cerebro persistente del proyecto. Se lee al inicio de cada sesión.

> **2026-10-22 (0.1.5)**: piezas comunes del core. Clave de Anthropic con `EstadoClaveAnthropic.paraApp('solera_viticultura')` + `PantallaClaveAnthropic` (con «Probar la clave»; `estado/clave_ia.dart`); identificación por foto con `ClienteClaude` (`claude-haiku-5-5`, esfuerzo bajo, `pedirJson`; prompt y cruce con el catálogo de plagas propios en `servicios/analizador_foto_vid.dart`; errores de `ErrorClaude`). Facturas con `Factura`/`GeneradorFacturaPdf` del core. Copia de seguridad con `ServicioCopiaSeguridad` (`servicios/backup_servicio.dart`: misma BD, mismo prefijo de ZIP, fecha de última copia conservada, sin preferencias, `PRAGMA integrity_check`; valida y enseña la fecha antes de restaurar; `main()` deshace una restauración interrumpida). Barra inferior: **Hoy · Mapa · Cepas · Registros · Ajustes**; la Guía pasa a icono en la AppBar de Hoy y Hoy gana «Asistente (chat)» (Claude con la clave de la app; sin DeepSeek). Registros: Libro PAC (también en el menú del mapa), facturas, libro económico, extracto anual. Borrados: `estado/clave_anthropic.dart`, `pantallas/pantalla_clave_anthropic.dart`, `servicios/cliente_anthropic.dart`, `modelos/factura.dart`, `servicios/generador_factura_pdf.dart`, `datos/configuracion.dart`.

> **2026-10-22 (0.1.4)**: fuera duplicados con el core — `ServicioChat`, `AutoBackup`, `ServicioMeteoAgro` y los validadores numéricos (`validarImporteObligatorio`, `validarNumeroOpcional`, `leerEntero`; mensajes por `SoleraL10n`, rechazan negativos) vienen ya de `nuevo_ser_core`; borrados `servicios/{servicio_chat,auto_backup,servicio_meteo_agro}.dart` y `utiles/validadores_numero.dart`. Ajustes por secciones (`CabeceraSeccionAjustes`: Explotación · Registros y documentos —con Libro PAC, que sigue también en el menú del mapa— · Inteligencia artificial · Preferencias · Datos · Aplicación). El mapa tiene lupa «Buscar un lugar» (`buscarLugarEnMapa` del core, zoom 15).

> **2026-10-22 (0.1.3)**: los tres PDF (factura, libro PAC, extracto económico) usan `temaPdfSolera()` del core (letra Archivo incrustada: Helvetica dejaba «€» y «—» en blanco). Los números de los formularios se leen a la española con `leerNumero`/`centimosDesdeTexto` del core (gasto, ingreso, evento, línea de factura) y avisan si no se entienden (`utiles/validadores_numero.dart`) en vez de guardar 0.

## Encuadre

Primer fork de la **Suite Larrea** dentro del monorepo. Producto comercial dirigido a **bodegas pequeñas y medianas** (5-30 ha). Hermana técnica de `apps/agro` (Larrea generalista) y futura `apps/solera-apicola` y `apps/solera-arbolado-urbano`.

Modelo de negocio: suscripción **€15-40/mes por finca**. Comprador identificable (viticultor/enólogo de bodega pequeña que hoy lleva el cuaderno PAC en Excel). Hueco de mercado claro frente a Vintia/AgroOptima — éstos son ERP pesados de oficina; Larrea Viticultura va en el móvil al campo.

## Posicionamiento — diferenciadores

1. **Cuaderno PAC móvil**: libro oficial de tratamientos exigido por la PAC española (RD 1311/2012) generado en PDF firmable desde el campo. Adiós a la oficina los domingos. **F1-7.**
2. **IA por foto vid-específica**: identificación de mildiu, oídio, botritis y polilla del racimo con Claude Vision. Catálogo curado propio (no PlantNet). **F1-8.**
3. **Calendario fenológico BBCH** con avisos contextualizados a la variedad y la zona. **F1-6.**
4. **Punto suelto soportado de raíz** (cepa sin viñedo obligatorio) — heredado del modelo de agro.
5. **Offline real** (sólo va a la nube cuando hay sync).

## Stack

Heredado de la suite Larrea. Dependencias en `pubspec.yaml`. Consume `nuevo_ser_core` por path local para `GestorFotos`, `csv_io` (parser/escape de CSV), `informe_periodico_pdf` (plantilla PDF con cabecera/footer/tabla consistentes).

## Catálogos curados — flujo de validación

```
content/viticultura/         CSVs editables por el asesor
├── README.md
├── variedades.csv           40 filas, 0 revisadas
├── portainjertos.csv        10 filas, 0 revisadas
├── plagas_vid.csv           19 filas, 0 revisadas
├── materias_activas.csv     19 filas, 0 revisadas
└── calendario_bbch.csv      72 filas, 0 revisadas

apps/solera-viticultura/tool/compilar_catalogos.dart
                             Lee los 5 CSVs, skipea líneas `#`,
                             genera 5 .dart en lib/datos/catalogos_generados/
                             + flag_revision.dart (true cuando todas las
                             filas tienen `revisado_por` no vacío).

Flujo:
  1. Asesor edita CSV en Excel/Sheets, exporta CSV UTF-8.
  2. dart run tool/compilar_catalogos.dart  (regenera los 5 .dart).
  3. flutter analyze && flutter test.
  4. Commit del CSV + .dart regenerado en el mismo commit.

Estado actual: PROVISIONAL — banner visible en PantallaAcerca y en
modal IA hasta que `catalogosCompletamenteRevisados == true`.
```

## Estructura

```
lib/
├── datos/                 base_datos.dart (sqflite v1, esquema completo)
├── modelos/               Cepa, Vinedo, Cosecha, Observacion, Incidencia,
│                          Tratamiento (con campos PAC), Titular
├── pantallas/             pantalla_mapa (clustering OSM), pantalla_lista_cepas,
│                          pantalla_ficha_cepa (timeline), pantalla_nueva_cepa,
│                          pantalla_nuevo_evento (4 tipos),
│                          pantalla_titular (PAC), pantalla_libro_pac (export),
│                          pantalla_clave_anthropic (BYO key),
│                          pantalla_onboarding (primer arranque),
│                          pantalla_ajustes (consolidador), pantalla_backup,
│                          pantalla_acerca
│                          + widgets/{selector_fotos, boton_identificar_ia}
├── servicios/             generador_libro_pac (PDF firmable),
│                          cliente_anthropic (Claude Haiku vision),
│                          backup_servicio (zip BD+fotos con safety pre-restore)
├── estado/                vinedo_activo (persistido en shared_preferences),
│                          clave_anthropic (BYO key local-only)
├── utiles/                permisos_gps
└── main.dart              entry point — home: PantallaMapa
```

## Modelo de datos planificado (sqflite)

Forkeado de agro con renombrados:

- `vinedos` (era `fincas`) — vínedo opcional (cepas pueden ser puntos sueltos).
- `cepas` (era `plantas`) — entidad central. `variedadId`, `portainjertoId`, `latitud/longitud`, `etiqueta` (ej. F3-12 = fila 3, planta 12), `fechaPlantacion`.
- `cosechas`, `observaciones`, `incidencias`, `tratamientos` — eventos hijo de cepa.
- `tratamientos` lleva campos PAC obligatorios: `numeroRegistroFito`, `nifAplicador`, `superficieTratada`, `materiaActiva`, `dosisHa`, `motivo` (plaga/enfermedad detectada).

## Roadmap

| Fase | Estado | Entregable |
|---|---|---|
| F0 Extracción al core | ✅ | `gestor_fotos`, `csv_io`, `informe_periodico_pdf` extraídos a nuevo_ser_core con tests caracterización; agro refactorizado para consumir el core |
| F1-1 Esqueleto | ✅ | apps/solera-viticultura/ creado, pubspec, branding mínimo, dependencia del core |
| F1-2 Modelos + BD | ✅ | Cepa, Vinedo, Cosecha, Observacion, Incidencia, Tratamiento (campos PAC) + Titular + BD sqflite v1 con esquema completo (sin tracks de momento). 14 tests POJO. |
| F1-3 Pantallas básicas | ✅ | PantallaMapa (clustering OSM, FAB GPS), PantallaListaCepas (busca + filtra), PantallaFichaCepa (timeline unificada de 4 tipos), PantallaNuevaCepa (alta/edición con GPS), PantallaNuevoEvento (cosecha/observación/incidencia/tratamiento + campos PAC condicionados). Versión minimalista — sin catálogos curados (quedan como text-input libre hasta F1-4..F1-6) |
| F1-4 Catálogo cepas + portainjertos | ✅ con datos provisionales | 40 variedades + 10 portainjertos en `content/viticultura/variedades.csv` y `portainjertos.csv`. Compilador CSV → Dart en `tool/compilar_catalogos.dart`. Autocomplete cableado en PantallaNuevaCepa. **Datos provisionales sin validar enológicamente** — esperando asesor (BLOQUEOS-PENDIENTES.md). |
| F1-5 Catálogo plagas/enfermedades vid | ✅ con datos provisionales | 19 plagas + 19 materias activas en `plagas_vid.csv` y `materias_activas.csv`. Autocomplete cableado en PantallaNuevoEvento (incidencia). Matching fuzzy en modal IA con 3 estados (verde validado / amarillo provisional / naranja libre). **Datos provisionales sin validar agronómicamente** — esperando asesor + descarga registro MAPA vigente. |
| F1-6 Calendario fenológico BBCH | ✅ con datos provisionales | 72 estados en `calendario_bbch.csv` (8 zona-variedades × 9 estados principales). Helpers `calendarioDe()` y `estadoEsperadoEn()` listos para "qué toca esta semana" cuando entre la pantalla. **Datos provisionales** — esperando asesor enológico para confirmar décadas por DO. |
| F1-7 Cuaderno PAC | ✅ | PantallaTitular (datos del titular + asesor + aplicador), PantallaLibroPac (selector viñedo + campaña, generar y compartir / abrir en visor del SO), `generador_libro_pac.dart` que usa la plantilla `informe_periodico` del core. **Limitación**: el formato exacto vigente del MAPA debe validarse antes de inspección oficial — registrado en BLOQUEOS-PENDIENTES.md. |
| F1-8 IA Claude Vision vid-específica | ✅ con caveat | BYO key Claude Haiku 4.5, prompt curado vid-específico (lista canónica de 14 incidencias comunes en *Vitis vinifera*: mildiu, oídio, botritis, polilla del racimo, mildiu falso, black-rot, eutipiosis, yesca, etc.). Botón "Identificar con IA" en formulario de incidencia, modal con diagnóstico + severidad + manejo cultural + advertencias, "Aceptar y pre-rellenar" → rellena formulario con notas auto antepuestas. Hard limit: NO recomienda productos comerciales. **Caveat**: hasta F1-5 todo diagnóstico se marca como "diagnóstico libre, no validado por catálogo Larrea" (cuando entre el catálogo curado, se valida automáticamente como en agro) |
| F1-9 Pulido | ✅ con caveat | Onboarding 3 cards primer arranque (PageView con flag persistido), backup ZIP de BD+fotos con safety pre-restore (heredado patrón agro), pantalla acerca con compromisos legales explícitos, pantalla ajustes consolidando Titular + IA + Backup + Acerca, menú overflow del mapa simplificado a "Libro PAC" + "Ajustes". **Caveat**: branding visual definitivo (logo, splash, paleta extendida más allá de burdeos+crema) sigue siendo decisión humana — registrado en BLOQUEOS-PENDIENTES.md. |
| F1-10 Branding + refactor al core | ✅ | Logo cabecera (`assets/icono-log-viticultura.png` — hoja de vid en acuarela burdeos), iconos lanzador Android adaptive (5 mipmap-* + adaptive icon Android 8+ via `flutter_launcher_icons`), splash screen Android (incluye Android 12+ via `flutter_native_splash`) sobre fondo crema `#F6E8D2`. **Refactor**: `CampoAutocompleteCatalogo<T>`, `SelectorFotos`, `BannerCoincidenciaCatalogo`/`BannerDeclaracionObligatoria`/`BannerRiesgoSanitarioPublico` extraídos al `nuevo_ser_core` (`src/ui/`) — la app pasa a consumirlos por barrel y elimina los widgets locales duplicados (compartidos con apícola y arbolado). Banner declaración obligatoria cableado en `pantalla_nuevo_evento.dart` por columna `declaracion_oficial` del CSV de plagas — listo para encenderse cuando el agrónomo asesor añada plagas reguladas (Xylella, Flavescencia dorada). |
| F1-11 Catálogos pre-curados con fuente pública | ✅ | Las 5 CSVs marcadas con `revisado_por=fuente_pública` (MAPA Registro Variedades Vid 2026, IMIDA + ENTAV-INRA, Boletines fitosanitarios CCAA, Registro Fitosanitario MAPA 2026, Eichhorn-Lorenz / Lorenz et al. 1995). **Añadidas 2 plagas cuarentenarias UE** con `declaracion_oficial=si` (Xylella - síndrome de Pierce, Flavescencia dorada) — banner rojo automático al teclear el diagnóstico. Generador libro PAC verificado conforme RD 285/2021 vigente. CUE digital (RD 34/2025, vigor 2027) anotado en BLOQUEOS para F1.1. `catalogosCompletamenteRevisados=true` — el banner "datos provisionales" queda desactivado. **Pendiente auditoría humana**: enólogo + agrónomo asesores firman y sustituyen `revisado_por` por su nombre + nº colegiado. |
| F1-12 Libro ingresos/gastos + extracto fiscal | ✅ con datos provisionales | 4 modelos (Tercero, ConfiguracionFiscal, ApunteIngreso con tipos venta_uva/venta_vino_botella/venta_vino_granel/alquiler/PAC y campo `loteVino` libre para trazabilidad DOP/IGP, ApunteGasto con tipos vid: insumos_vid/tratamientos/vendimia/embotellado/etiquetado/barricas/maquinaria/mano_obra/combustible/seguros/transporte/certificación). Migración BD v1→v2 puramente aditiva (4 tablas con FK a `vinedos` y `tratamientos` para sinergia futura con libro PAC). Pantalla de **Configuración fiscal** con régimen IRPF + IVA. Pantalla de **Terceros** con CRUD lista + sheet edición. Pantalla **Libro económico** con TabBar 3 pestañas (Ingresos / Gastos / Resumen — el resumen distingue uva vs vino para que se vea de un vistazo qué es producto agrícola REAGP-elegible y qué es producto transformado por la bodega). Formularios `PantallaNuevoIngreso` y `PantallaNuevoGasto` con autocálculo IVA/compensación (clave: la **uva** entra en REAGP 12% / IVA 4% según régimen, el **vino** siempre 21% IVA general porque es producto transformado y queda fuera de REAGP), foto factura vía `SelectorFotos` del core, imputación a vinedo_concreto/variedad_general/general. Pantalla **Extracto económico anual** con PDF reusando `informe_periodico_pdf` del core, 6 tablas (mensual con columna uva separada de vino, modelo 347, sin-NIF, detalle ingresos con variedad y lote, detalle gastos con imputación). Importes en céntimos. 14 tests POJO nuevos. **Banner amarillo "PROVISIONAL"** persistente. Cableado en pantalla_ajustes con 3 entradas nuevas. **Asunciones provisionales aplicadas** en `BLOQUEOS-PENDIENTES.md` F1-12: módulos NO soportado v1, REAGP + ED simplificada como regímenes ofrecidos, IVA uva 4% / 12% compensación REAGP / vino 21% siempre, IVA insumos vid 4%, IVA seguros 0% / mano de obra 0% / vendimia 0% / resto 21%, alquiler terreno con uso agrícola exento, reparto proporcional por superficie de gastos imputados a `variedad_general` listado pero no calculado (importe íntegro asignable), `loteVino` como texto libre en v1 (tabla de lotes formal queda para F1-13 si se decide). |
| F2 Lanzamiento | pendiente | Stores, web, primeros suscriptores |

## Hard limits

- **No recomendar productos fitosanitarios sin validación contra BBDD MAPA**. Heredado de agro: en MVP sólo manejo cultural + sustancias de uso común validadas; el matching contra el catálogo oficial entra en F1-7 con asesor agronómico.
- **No inventar datos enológicos**. Conservador: si no hay fuente clara, dejar placeholder con etiqueta "v2".
- **Compliance PAC es load-bearing**. El formato del libro de tratamientos cambia con la regulación; hay que seguirlo activamente.
- **Cero PlantNet, cero imágenes Commons en BD pre-cargada**. Caché de fotos = del cliente. Activos ilustrativos = stock comercial pagado o generación propia.

## Reglas de interacción

- **Voz adulta directa**, profesional/semi-profesional. No Kids.
- **Nombres descriptivos en castellano** (regla del monorepo).
- **Tests antes del código no visual**: motor, sync, persistencia, parsing.
- **Antes de meter información agronómica/enológica nueva**: verificar fuente o consultar con asesor. Sin fuente → placeholder "v2".

## Decisiones humanas pendientes

Ver `BLOQUEOS-PENDIENTES.md` (a crear cuando entre F1-4).

- Validación del catálogo de cepas + portainjertos por enólogo asesor.
- Validación del catálogo de plagas/enfermedades vid + materias activas BOE/MAPA por agrónomo.
- Calendario fenológico BBCH por variedad y zona (hay variabilidad regional alta).
- Formato vigente exacto del libro oficial de tratamientos PAC (RD 1311/2012 actualizado).
- Logo y branding visual definitivo.
- `applicationId` final (`com.coleccionnuevoser.solera_viticultura` actual).
- **F1-12 Libro ingresos/gastos — asesor fiscal humano + enólogo asesor** antes de quitar provisional. Decisiones acopladas: (1) régimen fiscal soportado v1 (REAGP es lo dominante en bodega pequeña; ¿se cubre estimación directa también?); (2) granularidad mínima del stock por lote para casar con la trazabilidad DOP/IGP que el consejo regulador pide en cada visita; (3) política RGPD para NIF de clientes recurrentes (distribuidores/hostelería); (4) cómo se maneja exportación intracomunitaria a efectos de IVA + modelo 349.
