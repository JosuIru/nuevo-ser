# Larrea Apícola — Bloqueos pendientes (decisión humana)

Tracker de decisiones humanas que bloquean el cierre a producción de cada fase.

---

## F1A-4 — Catálogo de razas de abeja

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08).

**Aplicado**: `razas_abeja.csv` (7 razas: *A. m. iberiensis*, *A. m. carnica*, *A. m. ligustica*, *A. m. mellifera*, caucásica, Buckfast, híbrida local) marcado `revisado_por="COLOSS + Cánovas et al. 2008"`. *A. m. iberiensis* es la subespecie autóctona dominante peninsular según taxonomía COLOSS y el artículo de Cánovas et al. 2008 sobre variación mitocondrial.

**Pendiente auditoría humana**: veterinario apícola asesor o biólogo apícola firma. El Reglamento UE 2018/848 (producción ecológica) prioriza el uso de subespecies autóctonas — relevante para apicultores ecológicos.

---

## F1A-4 — Catálogo de sustancias autorizadas para varroa

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente auditoría humana.

**Aplicado**: `sustancias_varroa.csv` (9 sustancias activas: oxálico sublimado/goteo, fórmico, timol, amitraz, flumetrina, fluvalinato, láctico, mezcla oxálico+glicerol) marcado `revisado_por="AEMPS CIMA Vet + RD 1132/2010"`. Compatibilidad ecológico según Reglamento UE 2018/848 (orgánicos+timol = SÍ; sintéticos = NO). Plazos de seguridad y eficacia esperada según ficha CIMA Vet.

**Decisión cerrada**: catálogo lista **sustancias activas**, NO medicamentos comerciales (Apivar es amitraz, Apiguard es timol, Mite-Away es fórmico). Hard limit legal de la app.

**Pendiente auditoría humana**: veterinario apícola asesor confirma autorización vigente — algunas sustancias en revisión UE (fluvalinato, cumafos). Antes de cada release: descargar listado vigente de [AEMPS CIMA Vet](https://cimavet.aemps.es/) y validar.

---

## F1A-4 — Catálogo de plagas y enfermedades apícolas

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente auditoría humana.

**Aplicado**: `plagas_apicolas.csv` (17 entradas) con fuente pública por fila — WOAH Manual de Pruebas de Diagnóstico (capítulos 3.2.1-3.2.8), RD 1492/2009, RD 630/2013, Reglamento UE 2018/1882. **Cambios respecto al estado provisional anterior**:
- **Loque europea (*Melissococcus plutonius*)**: bajada de `declaracion_oficial=si` a `=no` — RD nacional no la lista; depende de RD autonómico específico (a verificar caso a caso). Banner ahora correctamente apagado salvo CCAA con regulación añadida.
- **Tropilaelaps spp. añadido** con `declaracion_oficial=si`. Fuente: UE 2018/1882 clase A + WOAH cap. 3.2.8. Ácaro asiático ausente en España con vigilancia activa UE.

**Plagas reguladas con `declaracion_oficial=si` (banner rojo automático)**:
- `loque_americana` — *Paenibacillus larvae*. RD 1492/2009 + UE 2018/1882 clase D + WOAH 3.2.2.
- `escarabajo_colmenas` — *Aethina tumida*. UE 2018/1882 clase A + WOAH 3.2.6.
- `vespa_velutina` — RD 630/2013 + Estrategia Nacional MAPA.
- `tropilaelaps` — UE 2018/1882 clase A + WOAH 3.2.8 (ausente España, vigilancia).

**Pendiente auditoría humana**: veterinario apícola asesor confirma síntomas y manejo cultural de cada patología. Verificar RD autonómico de cada CCAA por si añade loque europea u otras al listado regulado regional.

---

## F1A-4 — Calendario apícola por zona

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente afinado por experiencia local.

**Aplicado**: `calendario_apicola.csv` (36 tareas, 3 zonas × 12 tareas) marcado `revisado_por="FEDAS + boletines técnicos cooperativas regionales"`. Granularidad: norte (Galicia/Cantábrica) / centro (meseta) / sur (mediterránea/Andalucía).

**Pendiente auditoría humana**: apicultor profesional o cooperativa local (COAG, ASAJA-Apícola, COLMENARES) afina ventanas por experiencia. Granularidad por décadas (1=1-10, 2=11-20, 3=21-fin) es orientativa ±2 semanas. En F2: override por apiario.

---

## F1A-5 — Formato vigente del libro oficial REGA

**Estado**: ✅ Conforme RD 209/2002 + RD 1492/2009 vigentes. Pendiente validación CCAA específica.

**Aplicado**: `generador_libro_rega.dart` produce PDF con 4 tablas obligatorias (tratamientos sanitarios, movimientos, incidencias, cosechas) + cabecera de titular + veterinario asesor con nº colegiado, según el [RD 209/2002](https://www.boe.es/buscar/act.php?id=BOE-A-2002-5016). El modelo cumple con la Orden AYG/2155/2007 (Castilla y León, generalizable a otras CCAA). Sustancias y plagas resueltas desde catálogos curados (no texto libre).

**Pendiente F1.1 — Integración SITRAN-AP digital**: el [Sistema Integral de Trazabilidad Animal](https://www.mapa.gob.es/es/ganaderia/temas/trazabilidad-animal/sitran) permite registro digital de movimientos. Verificar si hay obligatoriedad para 2026 o sigue siendo opcional. Fuera del alcance MVP F1A-5.

**Pendiente auditoría humana**: Josu obtiene PDF de inspección reciente firmada (cooperativa o veterinario CCAA piloto) y compara con el generado. Si hay variaciones autonómicas (Andalucía, Galicia, Castilla-La Mancha tienen variantes documentadas), añadir columnas extra al generador.

---

## Branding y `applicationId`

**Estado actual**: paleta provisional ámbar miel oscuro `#B8860B` + crema panal `#FAF6E8`. AppBar plano. `applicationId = com.coleccionnuevoser.solera_apicola`.

**Resuelve**: Josu en F1A-7 (pulido).

---

## F1A-10 — Libro económico (ingresos/gastos + modelo 347 + extracto anual)

**Estado**: ✅ con datos provisionales. Funcional end-to-end pero el formato del libro registro y del extracto está pendiente de firma de asesor fiscal antes de presentar nada en una declaración.

**Asunciones aplicadas en v1 provisional** (registradas para que el asesor fiscal las revise línea a línea):

1. **Régimen fiscal v1** soporta REAGP (compensación 12%, dominante en apicultura mediana) y Estimación directa simplificada / normal. **Módulos NO está soportado** — el asesor fiscal debe pedirlo explícitamente y validar el formato del extracto antes de añadirlo. La pantalla de Configuración fiscal lo deja claro al usuario.
2. **IVA repercutido en venta de productos apícolas** = 4% en régimen general (alimento de primera necesidad, art. 91.1.1.1.º LIVA). En REAGP no se repercute IVA — el comprador paga compensación del 12%.
3. **IVA del alquiler de colmenas para polinización** = 21% general aplicado en todos los casos. Caveat: el asesor fiscal puede determinar que en algunos casos cabe el reducido del 10% (si se considera servicio agrícola asimilado) o que encaja en REAGP. v1 aplica el más conservador (general 21%) para evitar problemas con Hacienda.
4. **IVA en la mayoría de gastos** = 21% general autocalculado. Excepción: alimentación animal al 10% reducido. El usuario puede sobrescribir manualmente cualquier valor para casar la factura real al céntimo.
5. **IVA soportado en REAGP** marcado como NO recuperable; se computa como mayor coste en el extracto (caso normal en apicultura mediana — confirma con el asesor si el titular factura algo en régimen general que permita recuperarlo).
6. **Modelo 347** se calcula sobre el importe **total** (base + IVA + compensación REAGP) por NIF y año, umbral fijo en 3.005,06€. Es la regla AEAT actual; el campo del umbral no es configurable porque cambiarlo manualmente sería un error grave (verificar antes de cada release que la AEAT no lo modifica).
7. **Reparto proporcional de gastos de trashumancia** entre colmenares NO está calculado en v1. Los apuntes con `imputacion=reparto_proporcional` se listan en el extracto con el importe íntegro asignable, y la nota final del PDF lo señala. Calcular el reparto real requiere consultar el número de colmenas activas en cada apiario en la fecha del gasto — está modelado pero no implementado todavía. Cuando el asesor fiscal valide el método de reparto (lineal por colmenas activas vs proporción declarada), el cálculo se mueve al generador.
8. **Apuntes sin NIF** (mercadillo, particular sin factura) se permiten guardar pero el extracto los lista en una tabla aparte con aviso porque NO entran al modelo 347. La AEAT permite ingresos sin NIF si están justificados por libro de caja diaria o similar — verifica práctica con tu asesor.
9. **Gestión de fotos de factura**: una foto por apunte (no varias páginas — si el documento tiene varias hojas, el usuario las junta con la app del móvil). Si el asesor pide adjuntar varias páginas por apunte, el modelo `rutaFotoFactura: String` cambia a `rutasFotosFactura: List<String>` codificado JSON (cambio aditivo no destructivo en BD v3).

**Resuelve**: asesor fiscal humano (gestoría de confianza del titular o gestoría especializada en apicultura). Pasos antes de quitar provisional:

- **Paso 1**: el asesor revisa la pantalla de Configuración fiscal y confirma que los regímenes ofrecidos son los apropiados para el perfil típico de la app (20-200 colmenas).
- **Paso 2**: el asesor genera un extracto anual de ejemplo desde la pantalla y lo coteja contra cómo monta él el libro registro de ingresos/gastos para una explotación apícola que ya gestiona. Si las columnas son las que necesita, paso 3; si no, anota qué columnas faltan/sobran.
- **Paso 3**: el asesor confirma que el cálculo del modelo 347 (operaciones >3.005,06€/NIF/año, sumando ingresos y gastos del mismo NIF) es la regla actual y que el umbral no ha cambiado.
- **Paso 4**: registrar el nombre + nº de colegiado del asesor en el banner provisional. Cambiar el banner a "Validado por [Nombre], [Colegiado]".

**Desbloquea**: cuando los 4 pasos están firmados, el banner amarillo "PROVISIONAL" se desactiva y la app pasa a producción para esta funcionalidad. Hasta entonces, el usuario sabe que es herramienta de apoyo, no documento oficial.

**Pendiente acoplado**: si la AEAT publica un nuevo formato de **declaración digital del libro registro** equivalente al CUE en agricultura (RD 34/2025 vigor 2027), F1A-10.1 añade el endpoint de exportación digital. Hoy el PDF cumple para presentar al asesor; cuando AEAT exija formato XML / API, se añade.

---

## Pendientes diferidos (no bloquean v0.1)

- **Análisis acústico** de colmena para predicción de enjambrazón: F2 (necesita micrófono + DSP en C++/Rust o ML on-device).
- **Báscula Bluetooth** para peso de colmena: F2.
- **Estación meteo** para predicción floración: F2.
- **Multi-operador con roles** (apicultor + jornalero + veterinario): F2 con backend.
- **Marketplace de medicamentos veterinarios**: pospuesto a v2.
