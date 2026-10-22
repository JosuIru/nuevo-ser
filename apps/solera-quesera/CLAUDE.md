# Solera Quesera — CLAUDE.md

Cerebro persistente del proyecto. Se lee al inicio de cada sesión.

> **2026-10-22 — ajustes por secciones, Acerca de y buscador del mapa (0.1.4)**. Fuera `lib/utiles/validar_numero.dart`: los formularios usan los validadores del core (`validarNumeroOpcional`, `validarImporteOpcional`, `validarEnteroOpcional`/`leerEntero`; temperaturas con `permitirNegativos: true`); cantidad de factura, nº de piezas, minutos de coagulación, días de curación y nº de animales ya no leen «2,5» en silencio. Ajustes por secciones con `CabeceraSeccionAjustes` (Explotación · Registros y documentos · Inteligencia artificial · Preferencias · Datos · Aplicación), sin la tarjeta «Resumen»; «Acerca de» es `pantalla_acerca.dart` (con `versionSoleraQuesera` y estado de los catálogos). El mapa tiene lupa (`buscarLugarEnMapa` del core).

> **2026-10-22 — PDF con «€» y «—» y números a la española (0.1.3)**. Factura, libro de trazabilidad e informe de simulación usan `temaPdfSolera()` del core (Archivo incrustada; Helvetica dejaba «€» y «—» en blanco). Los campos numéricos de partidas, lotes, recetas, cava/APPCC, libro económico y facturas se leen con `leerNumero` del core (antes «12,5» se perdía): importes con punto de millares, litros/kg avisan si «1.200» es ambiguo; los formularios avisan con `avisoNumeroNoValido` (`lib/utiles/validar_numero.dart`) en vez de guardar 0.

## Encuadre

Cuarto fork de la **Suite Solera** dentro del monorepo. Producto comercial dirigido a **queserías artesanales pequeñas y medianas** (1-10 empleados, 20-500 piezas en afinado) en toda España. Hermana técnica de `apps/agro` (Solera generalista), `apps/solera-viticultura`, `apps/solera-apicola` y `apps/solera-arbolado-urbano`.

Modelo de negocio: suscripción **€10-25/mes por quesería**. Comprador identificable: quesero artesanal que hoy lleva la trazabilidad en Excel + cuaderno de papel + etiquetas a mano. El proyecto **SMART GAZTA** (2022-2023, Consejo Regulador Idiazabal) ya demostró la necesidad de digitalización en este sector.

## Posicionamiento — diferenciadores

1. **Libro de Trazabilidad APPCC**: PDF inspeccionable con 7 secciones (recepción leche, producción, curación, analíticas, incidencias, ventas, controles APPCC). Adiós al estrés pre-inspección. **F1-4.**
2. **Gestión de afinado por pieza individual**: cada rueda de queso es una entidad con historia, peso, ubicación en cava, volteos. Como las cepas/colmenas/árboles de las otras Solera. **F1-3.**
3. **Verticalización por DO**: activas el perfil de tu Denominación de Origen (Idiazabal, Manchego, Cabrales, Roncal, Mahón…) y la app valida los requisitos del pliego de condiciones (raza, curación mínima, zona, métodos). **F1-5.**
4. **IA por foto Claude Vision**: identificación de defectos en corte y corteza (ojos anormales, moho, grietas, ácaros). Mismo patrón que la IA de plagas en viticultura/apícola. **F1-6.**
5. **Catálogos curados por asesor quesero** en CSVs editables (tipos de queso, razas lecheras, DO, defectos, analíticas). **F1-4.**
6. **Offline real** (sólo va a la nube cuando hay sync).

## Stack

Heredado de la suite Solera. Consume `nuevo_ser_core` por path local para `GestorFotos`, `csv_io`, `informe_periodico_pdf`.

## Estructura

```
lib/
├── datos/                 base_datos.dart (sqflite v1, 15 tablas),
│                          catalogos_generados/
├── modelos/               Queseria, ProveedorLeche, PartidaLeche, Receta,
│                          LoteProduccion, Pieza, EventoCuracion, Analitica,
│                          Incidencia, Venta, ControlTemperatura,
│                          ControlLimpieza, ControlPlagas, Formacion
├── pantallas/             pantalla_hoy (dashboard), pantalla_mapa,
│                          pantalla_lista_lotes, pantalla_ficha_lote,
│                          pantalla_nuevo_lote, pantalla_nueva_partida,
│                          pantalla_cava (gestión afinado),
│                          pantalla_trazabilidad (PDF + ejercicios),
│                          pantalla_onboarding, pantalla_ajustes
│                          + widgets/
├── servicios/             generador_libro_trazabilidad (PDF 7 secciones),
│                          cliente_anthropic (planificado),
│                          backup_servicio (planificado)
├── estado/                (planificado) queseria_activa
├── utiles/                permisos_gps
└── main.dart              entry point — onboarding → PantallaPrincipal

content/quesera/           CSVs editables por el asesor quesero
├── README.md
├── tipos_queso.csv        23 filas, 0 revisadas
├── razas_lecheras.csv     17 filas, 0 revisadas
├── do_quesos.csv          15 filas, 0 revisadas
├── defectos_queso.csv     18 filas, 0 revisadas
└── parametros_analitica.csv 14 filas, 0 revisadas

tool/compilar_catalogos.dart  Lee los 5 CSVs, skipea líneas #,
                             genera 5 .dart en lib/datos/catalogos_generados/
                             + flag_revision.dart
```

## Modelo de datos (sqflite, v1)

- `queserias` — single-row (una quesería por dispositivo en v0.1). Datos RGSEAA, NIF, localización.
- `proveedores_leche` — ganaderos externos + rebaño propio. Raza, tipo de leche, número de animales.
- `partidas_leche` — cada recepción diaria. Volumen, temperatura, pH, grasa, proteína, antibióticos.
- `recetas` — cada tipo de queso. Parámetros de proceso, ingredientes, curación mínima, DO asociada.
- `lotes_produccion` — **entidad central**. Lote con trazabilidad completa: partidas usadas, fermentos, cuajo, rendimiento.
- `piezas` — cada rueda individual con peso, ubicación en cava, estado (afinando/lista/expedida/baja).
- `eventos_curacion` — historial de volteos, ahumados, cepillados, controles de peso por pieza.
- `analiticas` — controles microbiológicos, físico-químicos, sensoriales.
- `incidencias` — defectos, no conformidades, acciones correctivas.
- `ventas` — salida de producto. Cliente, líneas (piezas o lotes), factura, IVA.
- `controles_temperatura` — APPCC: registro diario de temperatura y HR por cava.
- `controles_limpieza` — APPCC: limpieza de zonas y equipos.
- `controles_plagas` — APPCC: gestión de plagas.
- `formacion` — APPCC: formación del personal.

## Roadmap

| Fase | Estado | Entregable |
|---|---|---|
| F1-1 Esqueleto | ✅ | apps/solera-quesera/ creado, pubspec, branding, dependencia del core, estructura de directorios |
| F1-2 Modelos + BD | ✅ | 14 modelos + sqflite v1 con 15 tablas, FK, índices, migraciones aditivas. 23 tests POJO |
| F1-3 Pantallas básicas | ✅ | PantallaHoy (dashboard), PantallaMapa (proveedores), PantallaListaLotes, PantallaFichaLote, PantallaNuevoLote, PantallaNuevaPartida, PantallaCava (gestión afinado), PantallaTrazabilidad (generación PDF), PantallaOnboarding, PantallaAjustes |
| F1-4 Libro de Trazabilidad PDF | ✅ | `generador_libro_trazabilidad.dart` — PDF inspeccionable con 7 secciones, compartible vía sistema. **Caveat**: formato pendiente de validar con inspector real |
| F1-5 Catálogos provisionales | ✅ con datos provisionales | 5 CSVs en `content/quesera/` (23 tipos queso, 17 razas, 15 DO, 18 defectos, 14 parámetros analítica) + `tool/compilar_catalogos.dart`. Banner "datos provisionales" activo. **Datos sin validar por asesor quesero**. |
| F1-6 Perfiles DO | ⏳ pendiente catálogos | Activar perfil DO → validación de raza, zona, curación mínima, etiquetado. Checklist de cumplimiento por DO. |
| F1-7 IA Claude Vision | pendiente | BYO key Claude Haiku, identificación de defectos en corte/corteza, contraste contra catálogo, pre-relleno de incidencia |
| F1-8 Backup + pulido | pendiente | Backup ZIP de BD, onboarding pulido, pantalla acerca legal |
| F1-9 Libro ingresos/gastos | pendiente | Mismo patrón F3.5/F1-12 del resto de Solera: Ingresos (venta queso, ferias, suscripción, subvención DO), Gastos (leche, fermentos, energía cavas, cuota DO, analíticas) |
| F1-10 Catálogos pre-curados | pendiente | Revisión por asesor quesero + fuentes públicas (BOE DO, MAPA, AESAN) |
| F2 Lanzamiento | pendiente | Stores, web, primeros suscriptores |

## Hard limits

- **No recomendar fermentos, cuajos o aditivos comerciales sin validación**. En catálogo van tipos (animal/vegetal/microbiano), no marcas.
- **No inventar datos de DO**. Cada pliego de condiciones es texto legal; si no está confirmado del BOE o del Consejo Regulador, no se incluye.
- **Compliance sanitaria es load-bearing**. El formato del libro de trazabilidad debe ajustarse a RGSEAA + Reglamento CE 853/2004 + CCAA. Validar con inspector real antes de release.
- **El etiquetado generado por la app no es vinculante** — el quesero verifica antes de imprimir.
- **Cero PlantNet, cero imágenes Commons en BD pre-cargada**.

## Reglas de interacción

- **Voz adulta directa**, profesional. No Kids.
- **Nombres descriptivos en castellano** (regla del monorepo). Términos técnicos: RGSEAA, APPCC, DO, cuajo, afinado, volteo.
- **Tests antes del código no visual**: modelos, parsing, generación PDF.
- **Antes de meter información quesera nueva**: verificar fuente o consultar con asesor. Sin fuente → placeholder "v2".

## Decisiones humanas pendientes

Ver `BLOQUEOS-PENDIENTES.md`.

- Validación del catálogo de tipos de queso + razas + DO por quesero asesor.
- Formato exacto del libro de trazabilidad conforme a RGSEAA + CE 853/2004 + CCAA (validar con inspector real).
- Validación del catálogo de defectos queseros para IA visual (F1-7).
- Logo y branding visual definitivo (dorado/corteza + crema leche).
- `applicationId` final (`com.josu.solera_quesera` actual).
- **Libro ingresos/gastos — asesor fiscal humano** antes de quitar provisional (F1-9).
- Decidir si la app cubre también otros productos lácteos (yogur, requesón, cuajada) o se mantiene solo queso.
