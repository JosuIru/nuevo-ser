# Larrea Vivero — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/vivero.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh vivero "Larrea Vivero" 3F6B4A F5EFE2 vive Vivero`. Encuadre y normativa verificada abajo. 3 tests |
| 2 Modelos + BD | ✅ 2026-11-07 | 11 modelos (vivero, zona de cultivo, lote de material, bandeja con QR, siembra, partida de planta, repicado, salida, pasaporte emitido, tratamiento, inspección de plagas), 11 tablas en la v1 (`sentenciasEsquemaViveroV1`). Dominio puro: `stock.dart` (disponibles y resumen por especie/variedad/formato), `trazabilidad.dart` (de la partida al lote, con repicados), `pasaporte.dart` (necesidad de pasaporte por salida y datos A-D con lo que falta). 34 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas: Hoy (primeros pasos, avisos de inspección sin notificar, salidas sin pasaporte y plazos de seguridad, accesos a siembra, tratamiento, inspección y Cuaderno; Ajustes en la barra), Material (lotes y ficha con sus siembras), Bandejas (lista, alta con el siguiente código QR, ficha con partidas y siembras; zonas en la barra), Plantas (stock por especie y formato, partidas, ficha con disponibles, merma, repicado, salida, trazabilidad hasta el lote, tratamientos e inspecciones), Salidas (año, estado del pasaporte; ficha con la necesidad de pasaporte, letras A-D, lo que falta y registro de pasaportes con anulación). Sembrar crea la partida. Altas en hojas inferiores (`formularios.dart`). 40 tests, 6 de pantalla |
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | **Cuaderno de tratamientos** del año (datos generales, zonas con nº de orden, tratamientos, inspecciones de plagas; aviso del registro electrónico desde el 1-1-2027) y **registro de pasaportes y trazabilidad** (origen: material comprado con proveedor, ROPVEG y pasaporte recibido; destino: salidas; pasaportes preparados con su estado) en Salidas → PDF o Ajustes → Documentos. **Etiqueta del pasaporte** (10 × 6,5 cm) por registro, desde la ficha de la salida: recuadro, bandera en blanco y negro, título bilingüe, letras A-D (y ZP), QR con A-D; fuera del recuadro, PROVISIONAL y, si toca, BORRADOR «no válido como pasaporte». Tablas puras con test. 49 tests |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 6 (catálogos).

## Encuadre

Viveros pequeños y medianos de planta hortícola, forestal, frutal y
ornamental, incluidos los de semilla local y los de reforestación comunitaria.
Fuera: grandes viveros industriales con ERP propio.

**Diferencial**: trazabilidad de la semilla o la estaquilla a la planta
vendida, y los **datos del pasaporte fitosanitario** de cada salida sin papel,
con bandejas identificadas por QR. Ficha completa: `docs/plan-verticales/vivero.md`.

### Hard limits (no se tocan)

- La app **prepara los datos** del pasaporte fitosanitario para el operador
  autorizado; **no emite pasaportes en nombre de nadie**. Emitirlos exige la
  autorización de la comunidad autónoma (RD 1054/2021, art. 22). Si el vivero
  no tiene la autorización apuntada, la etiqueta sale como «borrador, no válida
  como pasaporte».
- La app **no da por sana una partida**: registra las inspecciones que hace la
  persona o el inspector, con su resultado.
- Nada de marcas ni dosis recomendadas: los catálogos llevan sustancias
  activas; producto y dosis los copia la persona de la etiqueta.
- No afirma que se «cumple» ninguna norma. Todos los PDF llevan PROVISIONAL.

## Normativa verificada (2026-11-07)

| Norma | Qué se usa | Enlace |
|---|---|---|
| **Reglamento (UE) 2016/2031** (sanidad vegetal) | Art. 79 (pasaporte para el traslado en la Unión), art. 81 (no hace falta en el suministro directo al usuario final, salvo venta a distancia y zonas protegidas), art. 83 (contenido y forma: «marca clara»; el código de trazabilidad puede no exigirse en ciertos vegetales para plantación listos para el usuario final — condiciones **por verificar** antes de aplicarlo), art. 84 y 89 (los expiden los operadores **autorizados**), art. 93 (sustitución), art. 69.4 (documentación 3 años) | https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32016R2031 |
| **Reglamento de Ejecución (UE) 2017/2313** de la Comisión, de 13 de diciembre de 2017 (DO L 331 de 14.12.2017, p. 44), **formato del pasaporte** | Anexo, partes A (traslado en la Unión), B (zona protegida, «ZP»), C y D (combinado con etiqueta de certificación). Elementos: título «Pasaporte fitosanitario» / «Plant Passport» (o «– ZP» / «– PZ»), bandera de la Unión (color o blanco y negro), **A** nombre botánico (y variedad, opcional), **B** código ISO del Estado (ES) + guion + nº de registro, **C** código de trazabilidad (si procede; admite código de barras, QR…), **D** Estado miembro o país tercero de origen; en ZP, nombre o código de la plaga de zona protegida. Art. 2: dentro de un rectángulo o cuadrado, legible sin ayuda óptica y separado del resto con una línea. Tamaño y letra del modelo «como meros ejemplos» | https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32017R2313 |
| **Reglamento de Ejecución (UE) 2019/2072** de la Comisión, de 28 de noviembre de 2019 | Anexo XIII: necesitan pasaporte **todos los vegetales para plantación salvo las semillas** (punto 1) y las semillas de ciertas especies (puntos 5-11: tomate, pimiento, cebolla, puerro, judía, guisante, haba, *Prunus*…). Anexo XIV: pasaporte «ZP» para coníferas (*Abies, Larix, Picea, Pinus, Pseudotsuga*), *Castanea*, *Vitis*, *Platanus*, *Eucalyptus*, palmeras y las rosáceas huésped del fuego bacteriano, entre otras. Anexo IV: plagas reguladas no cuarentenarias (RNQP) por género. Leído en la versión adoptada (legislation.gov.uk); **la versión consolidada vigente está por verificar** (hay modificaciones posteriores, p. ej. 2021/2285 y 2023/1787) | https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32019R2072 |
| **Reglamento Delegado (UE) 2019/1702** | Las 20 plagas prioritarias (*Xylella fastidiosa*, *Popillia japonica*, *Anoplophora*, *Bursaphelenchus xylophilus*, *Candidatus* Liberibacter…) | https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32019R1702 |
| **RD 1054/2021**, de 30 de noviembre (ROPVEG; BOE 16/12/2021) | Art. 8.1: nº de registro de diez caracteres, «ES» + guion + 2 dígitos de la comunidad + 2 de la provincia + 4 del operador. Art. 16: en la letra B del pasaporte va «ES-» y el nº sin el prefijo; no hace falta en venta directa al usuario final ni en traslados dentro de una instalación o **entre instalaciones del mismo operador en la misma comunidad** (16.6). Art. 20: registro de trazabilidad (de quién viene y a quién va, y los datos del pasaporte) **3 años**. Art. 22: autorización por la comunidad autónoma (conocimientos, plan contra plagas reguladas, medios, persona de contacto; inspección previa) y obligación de autoinspección de cuarentenarias y RNQP | https://www.boe.es/buscar/act.php?id=BOE-A-2021-20730 · PDF: https://boe.gob.es/boe/dias/2021/12/16/pdfs/BOE-A-2021-20730.pdf |
| Trámite de autorización (Aragón, ejemplo) | Requisitos prácticos de la ficha | https://www.aragon.es/tramitador/-/tramite/autorizacion-expedicion-pasaportes-fitosanitarios |
| **RD 289/2003**, de 7 de marzo, comercialización de los **materiales forestales de reproducción** (modificado por el RD 1220/2011; consolidado del 22/09/2011, sin derogación a la vista) | Perfil forestal: el lote lleva etiqueta y documento del proveedor (art. 10, anexo IX) con categoría (identificado, seleccionado, cualificado, controlado; colores amarillo, verde, rosa y azul), **región de procedencia** (nombre y código) en identificado y seleccionado, tipo de material de base y nº de certificado patrón. **Por verificar** que no haya norma posterior que lo sustituya (hay propuesta de reglamento UE de material de reproducción) | https://www.boe.es/buscar/act.php?id=BOE-A-2003-4785 |
| RD 1311/2012 y cuaderno de explotación | Cuaderno de tratamientos (como Frutal; registro electrónico desde el 1-1-2027 por el RD 1039/2025, visto en Frutal) | https://www.boe.es/buscar/pdf/2012/BOE-A-2012-11605-consolidado.pdf |

## Decisiones tomadas sin consultar

- **2026-11-07 — Fuente del formato del pasaporte**: el Reglamento de Ejecución
  (UE) 2017/2313 (13/12/2017). Es el que pide la ficha («diciembre de 2017»).

- **2026-11-07 — `Vivero` hace de `Titular`** (tabla `viveros`, una fila): una
  instalación = un vivero, con el ROPVEG, la autorización de pasaporte y la
  persona de contacto fitosanitaria (RD 1054/2021, art. 22.1.d).
- **2026-11-07 — Se añadió `ZonaCultivo`** (nave, invernadero, umbráculo o
  parcela exterior con GPS): la ficha pide ubicación de bandejas y GPS de las
  parcelas exteriores.
- **2026-11-07 — Repicar crea una partida nueva** (otro formato, otro código)
  y un `Repicado` que la enlaza con la de origen; el stock se calcula
  (inicial − mermas − repicadas − salidas), no se guarda. Así la cadena hasta
  el lote no se pierde.
- **2026-11-07 — Integridad = trazabilidad**: lotes, bandejas, siembras,
  partidas y salidas con algo colgando no se borran (`RESTRICT`); las bandejas
  se retiran (`activa`) y los pasaportes se **anulan**, nunca se borran (art. 20
  del RD 1054/2021: tres años).
- **2026-11-07 — El pasaporte guardado es una foto** de las letras A-D en el
  momento de prepararlo; es borrador si el vivero no tiene la autorización
  apuntada o faltan datos.
- **2026-11-07 — Necesidad de pasaporte, conservadora**: zona protegida → «ZP»;
  traslado propio en la misma comunidad → no; usuario final en persona → no
  (art. 81.1); a distancia → sí; si el catálogo no lo dice → «por verificar»,
  nunca «no hace falta». La decisión es del operador.
- **2026-11-07 — QR de la etiqueta del pasaporte** con las letras A-D separadas
  por «|» (formato propio): **por verificar** si sirve de soporte oficial.
- **2026-11-07 — Códigos propios**: bandejas `VIV-B-0001…` (el QR lleva el
  código tal cual, como Arbolado) y partidas `P26-0001…` por año.

- **2026-11-07 — Cinco pestañas** (Hoy, Material, Bandejas, Plantas, Salidas);
  Ajustes y el Cuaderno se abren desde Hoy para no pasar de cinco.
- **2026-11-07 — Sembrar crea la partida a la vez** (transacción): la partida
  nace con una planta por alveolo, que se corrige con las mermas. Así no hay
  partidas sin origen salvo que se den de alta a mano.
- **2026-11-07 — La necesidad de pasaporte de una salida no depende de la
  especie**: toda planta para plantación salvo la semilla lo necesita
  (2019/2072, anexo XIII.1); deciden las marcas de destino.
- **2026-11-07 — Los controladores de las hojas se liberan con un segundo de
  retraso**: la animación de cierre los repinta después de que
  `showModalBottomSheet` vuelva (en Frutal no se notaba).
- **2026-11-07 — Tests de pantalla sin `pumpAndSettle`**: mientras la BD real
  carga, el indicador de progreso no deja asentarse; se bombea con pausas.

- **2026-11-07 — Los dos documentos oficiales** son el cuaderno de
  tratamientos (RD 1311/2012) y el registro de pasaportes y trazabilidad
  (RD 1054/2021, art. 20); la etiqueta del pasaporte es un tercer PDF por
  registro. Todos con PROVISIONAL.
- **2026-11-07 — La etiqueta lleva PROVISIONAL impreso** (fuera del recuadro):
  mientras la autoridad no valide el formato, la etiqueta no debe pasar por un
  pasaporte definitivo. Retirarlo es decisión humana (BLOQUEOS).
- **2026-11-07 — Bandera en blanco y negro** dibujada a mano (12 estrellas):
  el anexo del 2017/2313 la admite y evita depender de una imagen.

## Datos técnicos

- Paquete `solera_vivero`, BD `solera_vivero.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/vivero.csv` (claves `vive.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/vivero/` → `dart run tool/compilar_catalogos.dart`.
