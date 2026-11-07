# Larrea Vivero — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/vivero.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh vivero "Larrea Vivero" 3F6B4A F5EFE2 vive Vivero`. Encuadre y normativa verificada abajo. 3 tests |
| 2 Modelos + BD | pendiente | |
| 3 Pantallas | pendiente | |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 2.

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

## Datos técnicos

- Paquete `solera_vivero`, BD `solera_vivero.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/vivero.csv` (claves `vive.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/vivero/` → `dart run tool/compilar_catalogos.dart`.
