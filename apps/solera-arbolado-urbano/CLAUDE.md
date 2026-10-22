# Solera Arbolado Urbano — CLAUDE.md

Cerebro persistente del proyecto. Se lee al inicio de cada sesión.

## Encuadre

Tercer fork de la **Suite Solera** dentro del monorepo. **Producto B2B** dirigido a **ayuntamientos pequeños y medianos + empresas de jardinería** que gestionan arbolado público. Hermana técnica de `apps/agro` (Solera generalista), `apps/solera-viticultura` (bodegas) y `apps/solera-apicola` (apicultura).

Diferencia central con sus hermanas: **modelo B2B** con licenciamiento por concejalía / empresa, no SaaS individual. Comprador identificable: técnico de medio ambiente del ayuntamiento que hoy gestiona el arbolado en Excel + papel + memoria del jardinero veterano que está a punto de jubilarse.

Modelo de negocio: licencia anual **€500-3.000/año por municipio** según número de árboles inventariados. Ticket alto, volumen bajo, ciclo de venta largo (concursos públicos, presupuestos por convocatoria). Compite con software municipal pesado (Esri ArcGIS, GVSIG con plugin verde) que cuesta cinco cifras y requiere consultor.

## Posicionamiento — diferenciadores

1. **Inventario por QR de chapa municipal**: cada árbol lleva un QR resistente a intemperie clavado en el tronco; el operario escanea, ve el historial completo y registra la inspección en 30 segundos. **F1U-3.**
2. **Partes de poda firmables en PDF**: cierre de campaña → informe consolidado para concejalía con todas las actuaciones, fotos antes/después, técnico responsable. **F1U-5.**
3. **IA por foto especializada en arbolado urbano ibérico**: identificación de procesionaria del pino, picudo rojo de las palmeras, anthracnosis del plátano de sombra, mancha foliar de almendros y peral ornamental, etc. **F1U-6.**
4. **Riesgo de caída evaluable**: la app incluye campo de evaluación visual de riesgo (VTA — Visual Tree Assessment simplificada), trazable en el histórico para defender decisiones de poda o tala.
5. **Multi-operario con firma trazable** en cada inspección — pieza necesaria si el ayuntamiento subcontrata el mantenimiento a una empresa externa. **F2** (multi-rol con backend).

## Stack

Heredado de la suite Solera. Añade `mobile_scanner` para el QR de chapa municipal (única dependencia adicional respecto a las hermanas). Consume `nuevo_ser_core` por path local para `GestorFotos`, `csv_io`, `informe_periodico_pdf`.

## Estructura

```
lib/
├── datos/                 (pendiente) base_datos.dart, catalogos_generados/
├── modelos/               (pendiente) Zona, Arbol, Inspeccion, Poda,
│                          Tratamiento, Incidencia, Tecnico
├── pantallas/             (pendiente) mapa, lista_arboles, ficha_arbol,
│                          nuevo_arbol (con QR scan), nuevo_evento,
│                          tecnico, informe_municipal, ajustes
├── servicios/             (pendiente) cliente_anthropic,
│                          generador_informe_municipal, escaner_qr
├── estado/                (pendiente) zona_activa, clave_anthropic
├── utiles/                (pendiente) permisos_gps, permisos_camara
└── main.dart              esqueleto v0.1

content/arbolado-urbano/   (pendiente F1U-4) CSVs editables por asesor
tool/compilar_catalogos.dart (pendiente F1U-4)
```

## Modelo de datos planificado (sqflite)

Forkeado del patrón de las hermanas con renombrados B2B y un evento extra de **Poda** (la actuación más frecuente):

- `zonas` (era `vinedos` / `apiarios`) — sector de la ciudad. Centroide + nombre humano (parque, paseo, calle).
- `arboles` (era `cepas` / `colmenas`) — entidad central con **identificador municipal** (string único, p. ej. `IRU-2024-PASEO-042`), **código QR** (URL/payload del QR físico de chapa), especie (id catálogo), edad estimada, fecha de plantación, perímetro de tronco, altura estimada, riesgo VTA (1-5), estado (sano/observación/riesgo/caído/sustituido).
- `inspecciones` (era `revisiones` / `observaciones`) — visita rutinaria del técnico: estado fitosanitario, riesgo VTA actual, observaciones libres + fotos.
- `podas` — actuación específica: tipo de poda (formación / mantenimiento / saneamiento / refaldado / drástica), volumen estimado (m³ de restos), técnico operario, fecha, fotos antes/después.
- `tratamientos` — fitosanitario o sanitario aplicado: producto / sustancia activa, dosis, motivo (procesionaria, picudo, etc.), técnico aplicador, número factura.
- `incidencias` — caídas de ramas, vandalismo, golpes vehiculares, alcorque dañado, raíces que levantan acera, etc.
- `tecnicos` — operarios autorizados para firmar partes. NIF + nombre + empresa contratista (si aplica) + carnet de aplicador para tratamientos fitosanitarios.

## Catálogos planificados (F1U-4)

5 CSVs en `content/arbolado-urbano/`:

- `especies_arboreas.csv` — selección curada de las ~50 especies más frecuentes en arbolado urbano peninsular (plátano de sombra, tilo, fresno, almendro ornamental, pino piñonero, palmera datilera, naranjo amargo, jacarandá, ciprés, encina, etc.).
- `plagas_urbanas.csv` — procesionaria del pino, picudo rojo de palmeras, lagarta peluda, oruga del plátano, anthracnosis foliar, oídio del plátano, mancha negra del peral, mineradores foliares, escolitidos.
- `tipos_poda.csv` — formación, mantenimiento, saneamiento, refaldado, drástica/aterrazado, descopado, terciado, drenaje de copa.
- `sustratos_alcorque.csv` — clasificación rápida del alcorque para el inventario (mineral / orgánico / sellado con asfalto / sin alcorque definido / pavimento poroso).
- `tareas_calendario.csv` — ventanas habituales por zona ibérica (norte / centro / sur) para tratamiento contra procesionaria, poda en savia parada, riego de mantenimiento, retirada de hoja seca, inspección anual VTA.

## Roadmap

| Fase | Estado | Entregable |
|---|---|---|
| F1U-1 Esqueleto | ✅ | apps/solera-arbolado-urbano/ creado, pubspec con stack completo + mobile_scanner, branding verde hoja `#2E7D32` + crema savia `#F4F8F0`, dependencia del core, CLAUDE.md y BLOQUEOS-PENDIENTES |
| F1U-2 Modelos + BD | ✅ | Zona, Arbol (con identificadorMunicipal único + qrPayload + riesgoVTA + 5 estados), Inspeccion, Poda (con fotos antes/después), Tratamiento (campos fitosanitarios trazables), Incidencia, Tecnico + Ayuntamiento (single-row) + sqflite v1 con índices. 17 tests POJO |
| F1U-3 Pantallas básicas | ✅ | PantallaMapa (clustering OSM, FAB nuevo árbol, búsqueda por QR), PantallaListaArboles (búsqueda multi-campo), PantallaFichaArbol (timeline 4 tipos eventos), PantallaNuevoArbol (con QR scan + GPS + selector VTA), PantallaNuevoEvento (4 tipos: inspección/poda/tratamiento/incidencia con campos condicionados + dropdown técnicos), PantallaEscanerQR. Versión minimalista — sin catálogos curados (text-input libre hasta F1U-4) |
| F1U-4 Catálogos provisionales | ✅ con datos provisionales | 5 CSVs en `content/arbolado-urbano/` (40 especies arbóreas urbanas peninsulares, 19 plagas/patologías, 12 tipos de poda, 7 sustratos, 23 tareas calendario × 3 zonas) + `tool/compilar_catalogos.dart`. Autocomplete cableado en especie/alcorque (PantallaNuevoArbol), tipo poda (con banner amarillo si controvertido) y plaga objetivo (con banner rojo automático si declaración obligatoria — picudo rojo, fuego bacteriano). 19 tests catálogos. **Datos provisionales sin validar** — esperando ingeniero técnico forestal asesor. |
| F1U-5 Informes municipales | ✅ con caveat | PantallaAyuntamiento (titular + concejalía responsable), PantallaTecnicos (CRUD operarios con NIF/empresa contratista/carnet aplicador), PantallaInformeMunicipal (selector zona + campaña), `generador_informe_municipal.dart` que reusa `informe_periodico_pdf` del core. 5 tablas (censo por especie, inspecciones, podas, tratamientos fitosanitarios, incidencias) con firma del técnico responsable. **Caveat**: el formato exacto del parte municipal varía entre ayuntamientos — registrado en BLOQUEOS-PENDIENTES.md. |
| F1U-6 IA Claude Vision | ✅ con caveat | BYO key Claude Haiku 4.5 con dos modos (`identificarEspecie` para censo, `diagnosticarPlaga` para incidencia), prompt curado arbolado urbano peninsular con lista canónica de patologías, banner rojo automático para declaración obligatoria (picudo rojo, fuego bacteriano) y banner naranja para riesgo sanitario público (procesionaria, lagarta peluda), matching fuzzy contra catálogo en 3 estados. Hard limit: NO recomienda fitosanitarios comerciales — sólo manejo cultural. **Caveat**: hasta validación del catálogo F1U-4 todo diagnóstico va marcado como "provisional". |
| F1U-7 Pulido | ✅ con caveat | Onboarding 3 cards primer arranque (PageView con flag persistido en SharedPreferences), backup ZIP de BD+fotos con safety pre-restore, pantalla acerca con compromisos legales explícitos sobre privacidad ciudadana + declaración obligatoria + responsabilidad del técnico VTA + formato municipal, pantalla ajustes consolidando Ayuntamiento + Técnicos + IA + Backup + Acerca, menú overflow del mapa simplificado a "Informe municipal" + "Ajustes". main.dart orquestador onboarding → mapa. **Caveat**: branding visual definitivo (logo, splash) sigue siendo decisión humana — registrado en BLOQUEOS-PENDIENTES.md. |
| F1U-8 Branding + refactor al core | ✅ | Logo cabecera (`assets/icono-logo-arbol-hurbano.png` — árbol geométrico con alcorque sobre verde), iconos lanzador Android adaptive (5 mipmap-* + adaptive icon Android 8+ via `flutter_launcher_icons`), splash screen Android (incluye Android 12+ via `flutter_native_splash`) sobre fondo crema savia `#F4F8F0`. **Refactor**: `CampoAutocompleteCatalogo<T>`, `SelectorFotos`, `BannerCoincidenciaCatalogo`/`BannerDeclaracionObligatoria`/`BannerRiesgoSanitarioPublico` extraídos al `nuevo_ser_core` (`src/ui/`) — la app pasa a consumirlos por barrel y elimina los widgets locales duplicados (compartidos con viticultura y apícola). Los banners de declaración obligatoria + riesgo sanitario público reutilizan los del core en `pantalla_nuevo_evento.dart` (tratamiento) y en el modal IA. |
| F1U-9 Catálogos pre-curados con fuente pública | ✅ | Las 5 CSVs marcadas con `revisado_por=fuente_pública` (Inventarios municipales Madrid + Barcelona OpenData + AEPJP, AEPJP + Estaciones Aviso Fitosanitario CCAA, Estándar Europeo de Poda EN 17321 + AEPJP, NTJ 08C + AEPJP, AEPJP guía estacional + servicios municipales). **Añadidas 2 plagas cuarentenarias UE** con `declaracion_oficial=si` (Xylella en arbolado ornamental — olivo/almendro; avispilla del castaño *Dryocosmus kuriphilus*). Plagas reguladas trazables: picudo rojo (UE 2019/2072 + RD 526/2014), fuego bacteriano (RD 1201/1999 + UE 2019/2072). Plagas con riesgo sanitario público: procesionaria (urticaria 12% rural / 4% urbano documentado), lagarta peluda. Generador informe municipal verificado compatible con la mayoría de pliegos AEPJP/FEMP — pendiente ajuste fino al pliego del municipio piloto. `catalogosCompletamenteRevisados=true` — el banner "datos provisionales" queda desactivado. **Pendiente auditoría humana**: ingeniero técnico forestal asesor firma y sustituye `revisado_por` por su nombre + nº colegiado. |
| F1U-10 Facturación B2B + control horas + estado de cobro | **decisión humana pendiente** | Modelo distinto del resto de Solera: **no hay producto vendido sino partes municipales firmados convertibles a líneas de factura**. Las podas/inspecciones/tratamientos del libro F1U-5 ya están registradas con técnico, NIF y empresa contratista — sumar precio unitario por tipo de actuación (poda formación, poda mantenimiento, tala, tratamiento por árbol/zona) negociado por contrato y generar **prefactura mensual** al ayuntamiento. Control de horas operario (entrada/salida + zona) para ajuste por jornal y para auditoría del pliego. Estado de cobro de cada factura emitida (emitida / aprobada por interventor / pagada / rechazada con motivo). Soporte de **factura electrónica Facturae 3.2.x para FACe** (obligatoria para AAPP españolas). NO se llama "ingresos/gastos" como en el resto de Solera — confunde el modelo, esto es facturación de servicios. **Provisional hasta que asesor fiscal + ayuntamiento piloto firmen** |
| F2 Multi-rol con backend | futuro | Roles ayuntamiento + empresa contratista; sync nube; firma electrónica de partes |

**2026-10-22 (0.1.3)** — los PDF (factura, hoja de QR, informe municipal) usan `temaPdfSolera()` del core: con Helvetica «€» y «—» salían en blanco. Los números de los formularios se leen a la española con `leerNumero` del core (`utiles/numeros_formulario.dart`): precio de factura con punto de millares («1.200,50» ya no da 0 €), cantidad de línea sin adivinar «1.200» (y admite decimales), perímetro/altura/volumen de restos con validador que avisa si no se entiende.

## Hard limits

- **No recomendar productos fitosanitarios concretos por marca**. En catálogo van **sustancias activas** + **tipos de poda** (heredado de viticultura/apícola).
- **No inventar datos sanitarios**. Conservador: si no hay fuente clara, placeholder "v2".
- **Compliance municipal es load-bearing**. Los partes deben llevar nombre, NIF, empresa contratista (si aplica), carnet de aplicador para tratamientos. Sin estos datos el PDF queda incompleto.
- **Riesgo VTA es responsabilidad del técnico**. La app facilita el registro pero NO emite dictámenes — la decisión de talar es siempre humana y firmada por técnico cualificado.
- **Privacidad ciudadana**: las fotos pueden capturar transeúntes sin querer. La app NO sube fotos a ningún servidor de Solera; sólo a Anthropic en el momento de identificación IA y por elección explícita del operario.
- **Cero PlantNet, cero imágenes Commons en BD pre-cargada**. Caché de fotos = del cliente. Activos ilustrativos = stock comercial pagado o generación propia.

## Reglas de interacción

- **Voz adulta directa**, profesional. No Kids.
- **Nombres descriptivos en castellano** (regla del monorepo). Términos técnicos en su forma oficial: VTA (*Visual Tree Assessment*), procesionaria, *Thaumetopoea pityocampa*.
- **Tests antes del código no visual**: motor, sync, persistencia, parsing.
- **Antes de meter información agronómica nueva**: verificar fuente o consultar con asesor. Sin fuente → placeholder "v2".

## Decisiones humanas pendientes

Ver `BLOQUEOS-PENDIENTES.md`.

- Validación de los catálogos por ingeniero técnico forestal o de jardinería + descarga registro MAPA vigente.
- Formato exacto del parte municipal de poda según práctica habitual de los ayuntamientos objetivo (varía mucho).
- Decisión de monetización B2B: licencia anual / por árbol / freemium con tope.
- Logo y branding visual definitivo.
- `applicationId` final.
- **F1U-10 Facturación B2B — asesor fiscal humano + ayuntamiento piloto** antes de quitar provisional. Decisiones acopladas: (1) formato Facturae 3.2.x vigente para FACe (cambia con normativa AEAT — la versión a soportar el día de release puede no ser la actual); (2) cómo se negocia el precio unitario por actuación con cada ayuntamiento (anejo del contrato vs tarifa por defecto editable; ¿IVA al 21% o exento por servicio público en algunos casos?); (3) política RGPD del control de horas del operario (sólo dueño y asesor lo ven, no el ayuntamiento); (4) ¿la app sólo registra factura emitida o se conecta a FACe por API para enviarla y leer el estado de cobro? La segunda opción exige certificado digital — alcance distinto.
