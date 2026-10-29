# Guía de testeo — Larrea (agro)

Gestor de fincas agrícolas para Iberia. Modelo de **planta con identidad
persistente**: cada árbol, cepa o planta es una entidad con historia
(cosechas, observaciones, incidencias, tratamientos). Cubre fruticultura,
truficultura, olivar, pistacho, vid, dehesa y forestal. Incluye Cuaderno
de Explotación PAC (RD 1311/2012), identificación con IA por foto (Claude
Vision), libro de ingresos/gastos para REAGP, tracks GPS de inspección,
catálogo de plagas, fitosanitarios y calendario fenológico.

**Versión a testear**: 0.3.1 (release `apks-2026-05-14`)
**Dispositivo recomendado**: Android 8+, 3 GB RAM, GPS, cámara, conexión a
internet al menos parcial.

---

## Antes de empezar

- [ ] **Permisos**: ubicación, cámara, almacenamiento, notificaciones.
- [ ] **Onboarding**: al primer arranque pasa por las 4 cards iniciales.
- [ ] **Datos de prueba**: crea una finca y al menos una planta para tener
  algo con qué probar el resto.
- [ ] **API key Anthropic**: si tienes una de Claude para probar la IA,
  configúrala en Ajustes → "IA Claude Vision". Si no, salta los bloques
  de IA y anótalo.

---

## Bloque 1 — Pantalla Hoy (dashboard)

- [ ] La app abre en la pestaña "Hoy".
- [ ] **Tarjeta meteo** visible desde el primer momento (no debe quedarse
  oculta detrás de un spinner).
- [ ] La meteo muestra T mín/máx, lluvia, viento del día.
- [ ] Tocar la tarjeta meteo abre la pantalla completa con previsión a
  7 días.
- [ ] Si hay avisos del día (helada, mal día para tratamientos, estrés
  hídrico), aparecen debajo de los datos meteo.
- [ ] Sección "Qué toca esta semana / este mes": consejos del calendario
  fenológico según los cultivos que tengas.
- [ ] Sección "Hoy" carga rápido.

**Notas / hallazgos**:


---

## Bloque 2 — Fincas y modelo SIGPAC

- [ ] Pantalla "Fincas" muestra la lista de fincas creadas.
- [ ] Botón "Nueva finca" abre el formulario.
- [ ] **Campos SIGPAC** (provincia / municipio / polígono / parcela /
  recinto): se pueden rellenar como texto libre.
- [ ] **Superficie en hectáreas** se acepta con decimales.
- [ ] Una planta puede ser **punto suelto** sin finca asignada (probarlo).
- [ ] Editar finca: cambios se guardan.
- [ ] Borrar finca (si la finca tiene plantas, debería avisar o
  desasignar).

**Notas / hallazgos**:


---

## Bloque 3 — Mapa y modo censo

- [ ] Pantalla "Mapa" muestra todas las plantas con clustering por zoom.
- [ ] Toque corto en marker abre la ficha de la planta.
- [ ] Toque largo en mapa abre "Nueva planta" con coords predefinidas.
- [ ] Cambio de capa base (calle/satélite) si está disponible.
- [ ] Filtro por finca / por cultivo si está disponible.
- [ ] Botón "Centrar en mi GPS".
- [ ] **Modo censo**: si tu árbol está en grid (filas x columnas) hay
  forma de añadir varios consecutivamente sin volver a pantalla
  anterior cada vez.

**Notas / hallazgos**:


---

## Bloque 4 — Plantas

### Crear planta

- [ ] Formulario "Nueva planta" con: cultivo, variedad, patrón / hospedero
  (si trufas), etiqueta (p. ej. A-17), fecha de plantación, GPS.
- [ ] **Autocomplete de cultivo** muestra catálogo (frutales, vid, olivo,
  trufa, etc.) agrupado por categoría.
- [ ] Variedades sugeridas según cultivo.
- [ ] Captura de GPS funciona.
- [ ] Foto de planta opcional.

### Lista de plantas

- [ ] Lista filtrable por finca / cultivo / búsqueda libre.
- [ ] Cada item muestra etiqueta, cultivo y miniatura si tiene foto.

### Ficha de planta

- [ ] Toda la información de la planta.
- [ ] **Timeline** cronológica con todos los eventos (cosechas,
  observaciones, incidencias, tratamientos).
- [ ] Tocar un evento abre su detalle.
- [ ] Botón "Nuevo evento" desde la ficha.
- [ ] Botón "Editar planta".
- [ ] Botón "Borrar" pide confirmación y borra la planta + sus eventos.

**Notas / hallazgos**:


---

## Bloque 5 — Eventos (cosecha, observación, incidencia, tratamiento)

### Cosecha

- [ ] Formulario con: kg, calidad, destino, fecha, fotos.
- [ ] Guardar añade a la timeline.

### Observación

- [ ] Formulario con texto libre, estado fenológico, fotos.
- [ ] Estados fenológicos sugeridos según cultivo (BBCH).

### Incidencia (plaga, enfermedad, fisiológico, abiótico)

- [ ] Selector de tipo.
- [ ] **Autocomplete del diagnóstico** contra catálogo de plagas; si
  coincide aparece banner verde "validado".
- [ ] Si es plaga **declaración obligatoria** (Xylella, fuego bacteriano,
  picudo rojo), aparece banner rojo.
- [ ] Si es riesgo sanitario público (procesionaria, lagarta peluda),
  banner naranja.
- [ ] **Botón "Identificar con IA"** (requiere API key Claude):
  - Adjunta foto, llama a Claude Haiku.
  - Modal con diagnóstico, confianza, manejo cultural sugerido.
  - "Aceptar" pre-rellena tipo + diagnóstico + severidad + nota.
- [ ] La IA NO recomienda productos comerciales (debe limitarse a
  manejo cultural).
- [ ] Severidad: escala visible.

### Tratamiento

- [ ] Formulario con: producto / sustancia activa, dosis, plaga objetivo,
  fecha, técnico aplicador, carnet, superficie tratada.
- [ ] **Autocomplete de producto** contra catálogo de fitosanitarios.
- [ ] Al elegir producto, autollena número de registro, dosis sugerida,
  plazo de seguridad.
- [ ] **Aviso** si el fitosanitario tiene plaga objetivo NO autorizada
  para el cultivo (uso fuera de etiqueta — debe ser aviso, no bloqueo).
- [ ] Captura foto de la factura (opcional).

**Notas / hallazgos**:


---

## Bloque 6 — Guía de cultivos y plagas

- [ ] Pantalla "Guía" muestra catálogos.
- [ ] Información agronómica por cultivo (descripción, exigencias,
  calendario, plagas notables).
- [ ] Información por plaga (descripción, síntomas, condiciones,
  manejo cultural).
- [ ] **Truficultura**: relación cultivo trufero ↔ árbol hospedero
  navegable en ambos sentidos.
- [ ] Búsqueda funciona.

**Notas / hallazgos**:


---

## Bloque 7 — Cuaderno PAC

El cuaderno de explotación PDF según RD 1311/2012.

- [ ] Pantalla "Titular" con datos del titular fiscal: NIF, nombre,
  dirección, REGEPA, asesor agrónomo opcional, aplicador opcional.
- [ ] Guardar persiste los datos.
- [ ] Pantalla "Cuaderno PAC" o "Generar cuaderno":
  - Selector de campaña/año.
  - Selector de finca o "todas".
  - **Validador previo** avisa de qué falta antes de generar (titular
    incompleto, finca sin SIGPAC, tratamientos sin núm registro…).
  - Si falta algo, NO bloquea pero advierte claramente.
- [ ] Generar produce un PDF descargable / compartible.
- [ ] El PDF contiene: portada con titular, parcelas SIGPAC, tratamientos
  fitosanitarios con todos los campos, otros tratamientos, incidencias
  justificativas.
- [ ] Llevará un sello "PROVISIONAL" mientras no esté auditado.

**Notas / hallazgos**:


---

## Bloque 8 — Tracks GPS de inspección

- [ ] Botón de grabación inicia un track de inspección.
- [ ] Mientras graba, la app dibuja el recorrido en el mapa.
- [ ] Crash deliberado de la app (cerrar forzando): al volver a abrir, los
  puntos GPS NO se han perdido (buffer incremental).
- [ ] Pantalla "Tracks" lista los tracks guardados.
- [ ] Detalle de track con mapa, duración, distancia, número de puntos.
- [ ] Exportar GPX.
- [ ] Importar GPX desde archivo.
- [ ] Asociar hallazgos hechos durante el track al informe del track.

**Notas / hallazgos**:


---

## Bloque 9 — Importar / exportar CSV

- [ ] Pantalla "Importar CSV de plantas".
- [ ] Selección de fichero CSV con formato esperado (cabeceras claras).
- [ ] Vista previa antes de importar.
- [ ] Importar añade plantas con sus datos.
- [ ] Exportar todas las plantas a CSV: el fichero exportado es legible
  en Excel/Sheets.
- [ ] Importar lo exportado funciona (ida y vuelta).

**Notas / hallazgos**:


---

## Bloque 10 — Libro de ingresos y gastos (libro económico)

*Está marcado como PROVISIONAL — pendiente de asesor fiscal humano.*

### Configuración fiscal

- [ ] Pantalla "Configuración fiscal".
- [ ] Selector régimen IRPF (estimación directa simplificada o normal).
- [ ] Selector régimen IVA (REAGP con compensación 12 % o régimen
  general).
- [ ] Año fiscal seleccionable.

### Terceros

- [ ] Pantalla "Terceros" con CRUD de clientes/proveedores.
- [ ] NIF, nombre, tipo (cliente / proveedor / ambos), email opcional.
- [ ] Edición en sheet.

### Apuntes

- [ ] **Nuevo ingreso**: tipo (venta_cosecha con cultivoId, alquiler,
  PAC, subvención…), tercero, cantidad, unidad, IVA, fecha, foto de
  factura, finca/cultivo imputado.
- [ ] **Autocálculo de IVA** según régimen del titular y tipo de ingreso.
- [ ] **Nuevo gasto**: tipo (insumos, tratamientos, mano de obra,
  combustible, seguros…), proveedor, cantidad, IVA manual leído de
  factura, fecha, foto, imputación a parcela_concreta / cultivo_general /
  general.
- [ ] **Ayudas PAC y subvención** como categoría separada del ingreso
  ordinario.
- [ ] Foto de factura adjunta.

### Libro económico

- [ ] Pestañas Ingresos / Gastos / Resumen.
- [ ] Selector de año.
- [ ] Totales por mes y resultado bruto coloreado.
- [ ] Botón "Generar extracto anual" produce PDF con 6 tablas (ingresos
  por mes, gastos por mes, modelo 347 >3.005,06 €/NIF, apuntes sin NIF,
  detalle ingresos, detalle gastos).
- [ ] Banner amarillo "PROVISIONAL" visible.

**Notas / hallazgos**:


---

## Bloque 11 — Backup

- [ ] Pantalla "Backup" (en Ajustes).
- [ ] **Crear backup**: genera un .zip con BD + fotos.
- [ ] El zip se puede compartir (Drive, email).
- [ ] **Restaurar backup**: pide confirmación clara.
- [ ] Antes de sobrescribir, la app hace **safety backup** pre-restore
  por si la operación va mal.
- [ ] Tras restaurar, los datos vuelven al estado del backup.

**Notas / hallazgos**:


---

## Bloque 12 — Ajustes

- [ ] **Titular fiscal**: entrada accesible.
- [ ] **API key Anthropic**: pegar y guardar; la clave queda solo en local.
- [ ] **Configuración fiscal / Terceros / Libro económico**: accesibles.
- [ ] **Backup**: accesible.
- [ ] **Acerca**: versión, compromisos legales explícitos sobre IA y
  fitosanitarios.

**Notas / hallazgos**:


---

## Bloque 13 — Pruebas de robustez

- [ ] Crear 50+ plantas rápidamente. La app no se ralentiza al volver al mapa.
- [ ] Hacer un tratamiento sin foto. Guarda igual.
- [ ] Hacer un tratamiento sin todos los datos PAC. Guarda con aviso.
- [ ] Activar modo avión: la app funciona con datos locales; meteo y IA
  fallan con mensaje claro.
- [ ] Cerrar app durante grabación de track: al volver, el track sigue
  ahí.
- [ ] Backup → borrar todo → restaurar: los datos vuelven correctamente.
- [ ] Girar el dispositivo: nada se rompe.
- [ ] Borrar una planta: sus eventos también desaparecen.
- [ ] Borrar una finca con plantas: avisa antes y mantiene las plantas
  (o las desasigna).

**Notas / hallazgos**:


---

## Bloque 14 — Perspectiva profesional agronómica

*Esta sección es para perfiles con formación agronómica, ingeniero técnico
agrícola, técnico OCA o agricultor con años de experiencia. El resto puede
saltarla o leerla por curiosidad.*

### Modelo de datos

- [ ] El concepto "**planta con identidad persistente**" (cada árbol /
  cepa / colmena es una entidad con historia): ¿es práctico de mantener
  en campo? ¿O resulta excesivo para fincas con miles de plantas?
- [ ] **Punto suelto** sin finca asignada: ¿útil para tu caso?
- [ ] **Etiqueta** (A-17, fila 3, planta 12): ¿corresponde a cómo se
  identifican plantas en campo en tu zona?
- [ ] **Cultivos / variedades / patrones / hospederos**: ¿están los que
  realmente se cultivan en Iberia? Anota los que faltan.

### Catálogo de plagas

- [ ] ¿Las plagas / enfermedades / desórdenes incluidos son los más
  habituales en los cultivos de tu zona?
- [ ] ¿Las plagas marcadas como "declaración obligatoria" lo son en
  realidad según RD vigente?
- [ ] ¿Las plagas de "riesgo sanitario público" están bien
  identificadas?
- [ ] ¿Qué plagas relevantes faltan?

### Catálogo de fitosanitarios

- [ ] Sustancias activas listadas: ¿están las más usadas?
- [ ] **Hard limit**: la app solo lista sustancias activas, no marcas
  comerciales (compromiso con la PAC). ¿Es coherente con tu práctica?
- [ ] El **autocomplete** que sugiere dosis, núm registro y plazo de
  seguridad: ¿los valores son razonables?
- [ ] El aviso de "uso fuera de etiqueta" (cultivo no autorizado para esa
  sustancia activa): ¿se dispara cuando debería? ¿O da falsos positivos?

### Cuaderno PAC

- [ ] El PDF generado: ¿incluye todos los campos del cuaderno de
  explotación del RD 1311/2012?
- [ ] ¿El formato es similar a lo que aceptaría un técnico OCA en
  inspección presencial?
- [ ] ¿Falta exportación XML SIEX / CUE para envío telemático? (Se
  decidió diferir porque la spec cambia por campaña, validar es
  trabajo de asesor humano).
- [ ] El cuaderno digital obligatorio (RD 34/2025, vigor 2027): ¿la
  arquitectura actual permite adaptarlo cuando llegue?

### Identificación con IA

- [ ] Probar identificación de varias plagas con foto.
- [ ] ¿La precisión de la IA en plagas comunes (mildiu, oídio, fuego
  bacteriano, procesionaria, picudo rojo) es razonable?
- [ ] ¿El **manejo cultural** propuesto es agronómicamente correcto?
- [ ] ¿Cuáles son los falsos positivos / negativos más típicos que
  detectas?

### Libro de ingresos / gastos REAGP

*Asesor fiscal especialmente bienvenido.*

- [ ] ¿Las categorías de ingreso (venta cosecha, ayuda PAC, alquiler...)
  cubren los casos reales del agricultor?
- [ ] ¿Las categorías de gasto cubren?
- [ ] **REAGP 12 % de compensación**: ¿el cálculo es correcto?
- [ ] **Modelo 347** (terceros >3.005,06 €/año): ¿el umbral y el formato
  son los vigentes?
- [ ] **Foto de factura** opcional: ¿debería ser obligatoria por
  trazabilidad fiscal?

### Sugerencias estructurales

- [ ] ¿Qué funciones críticas para el día a día del agricultor faltan?
  (avisos de plazos legales, gestión del riego, fertilización por
  análisis foliar / suelo, cuadernos de bodega…)
- [ ] ¿Se debería integrar BBDD pública SIGPAC para validar referencias
  contra catastro?
- [ ] ¿La fenología BBCH actual cubre los cultivos importantes?
- [ ] **Voz manos libres** (planificado F5): ¿útil para anotar en campo
  con manos sucias?

**Comentarios libres del agrónomo**:


---

## Feedback general

Aquí espacio libre para lo que no encaje en los bloques anteriores:
funcionalidades que faltan, flujos que mejorarías, comparaciones con
otras apps que conoces (Agroptima, Croptracker, FruitForest, etc.),
prioridades de qué arreglar primero, etc.

**Comentarios libres**:


---

## Información del tester

- **Nombre / alias**:
- **Perfil** (agricultor / técnico OCA / agrónomo / asesor fiscal /
  programador / otro):
- **Cultivo(s) principales que conoces**:
- **Dispositivo**:
- **Versión Android**:
- **Fecha del informe**:
- **Tiempo aproximado dedicado al testeo**:
