# Larrea Monte — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge `scripts/pendientes/`.

## Asesores humanos (para retirar sellos PROVISIONAL)

- **Técnico forestal de la comunidad autónoma** (Navarra, Euskadi, Galicia y
  Asturias primero): qué trámite pide cada aprovechamiento en su comunidad
  (declaración responsable, comunicación o autorización; Ley 43/2003,
  arts. 36.3 y 37.2), umbrales propios de menor cuantía, y formato del
  **parte de aprovechamientos** (`generador_parte_aprovechamientos_pdf.dart`)
  y del **estado del plan** (`generador_estado_plan_pdf.dart`). Revisar los
  nombres comunes de `content/monte/especies_forestales.csv` (los que no da el
  IFN4 son de uso corriente) y las plagas que faltan en su zona. Confirmar la
  **época de peligro** y las revisiones obligatorias de infraestructuras
  (`generador_revision_incendios_pdf.dart`).
- **Secretaría de una junta vecinal, concejo o comunidad de montes piloto**
  (Navarra o Galicia): el procedimiento del **sorteo de leña** (lista cerrada
  con huella, semilla pública posterior, sorteo con SHA-256) y el **acta**
  (`generador_acta_sorteo_pdf.dart`); si la ordenanza o los estatutos piden
  más (arraigo, cuantía máxima de las suertes: TRRL art. 75.4).
- **Asesor fiscal**: régimen de cada figura (particular en REAGP o general,
  comunidad de montes vecinales, entidad local); IVA de madera y leña (21 %
  propuesto en general, por verificar); si la madera en pie o un lote vecinal
  es «entrega de productos naturales» (REAGP 12 %, Ley 37/1992,
  art. 130.Cinco.1.º); si pastos, caza, setas y cuotas de lotes son entregas
  o arrendamientos. Extracto en `generador_extracto_economico_pdf.dart`.
- **Normativa autonómica sin leer** (por verificar): leyes forestales e
  instrucciones de ordenación de Navarra, territorios históricos de Euskadi,
  Galicia (Lei 13/1989 de montes vecinais en man común y ley de montes) y
  Asturias; prohibiciones y épocas de peligro de incendios de cada comunidad.
- **Certificación PEFC / FSC**: qué registros pide cada estándar vigente; la
  app solo guarda el sistema y el código del certificado.
- **Sustancias activas contra plagas forestales**: el catálogo no las trae a
  propósito (habría que contrastar cada una con el Registro de Productos
  Fitosanitarios del MAPA por uso forestal). La app no recomienda
  tratamientos; si algún día se apuntan, con texto libre de la etiqueta.

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/monte.csv` (borrador, 2026-11-07),
  exportables a ARB con `scripts/traducciones/`. Ojo a la terminología
  forestal («rodal», «estéreo», «señalamiento», «cortafuegos», «suertes»).

## Bloqueos técnicos

- **`scripts/auditoria` y `scripts/pendientes` no conocen la vertical**: la
  lista de verticales está fija en
  `scripts/auditoria/lib/src/lista_comprobacion.dart`, fuera de la calle de
  esta vertical. Darla de alta (`solera-monte`, `monte`, con el técnico
  forestal como responsable de catálogos y el asesor fiscal) es trabajo de la
  integración.
- **Plazo del art. 37.4 no está en `content/solera/plazos.csv`**: el encargo
  limita los cambios fuera de la app a `content/monte/`; el plazo (un mes
  desde el fin del aprovechamiento, si se vende) vive en
  `lib/dominio/aprovechamientos.dart`. La integración puede llevarlo al CSV
  común.
- **Aviso para otras verticales**: la letra del tema PDF del core no tiene la
  raya «—», la semirraya «–» ni «…» (salen como un cuadro al renderizar).
  Monte usa guion corto; otras verticales (p. ej. Aromáticas) escriben «—» en
  celdas vacías. No se toca fuera de esta calle.
- **Un monte por instalación**: una junta con varios montes los separa por
  código de rodal o usa una instalación por monte. Si un piloto lo pide,
  migración aditiva.
