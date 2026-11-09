# Larrea Aromáticas — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge `scripts/pendientes/`.

## Asesores humanos (para retirar sellos PROVISIONAL)

- **Técnico de medio natural de la comunidad autónoma**: confirmar qué
  autorización hace falta para recolectar cada especie en monte público y
  privado, y el catálogo regional de flora protegida. Confirmar si la
  **Ley 8/2003 de Andalucía** está vigente (el BOE consolidado la da vigente a
  20/03/2026; el encargo pedía no usarla porque parecía derogada).
- **Asesor de regulación de aceites esenciales**: régimen del aceite esencial
  y del hidrolato según destino (alimentario: Reg. 1334/2008; cosmético:
  Reg. 1223/2009; químico: REACH/CLP y la revisión 2024/2865), umbral de
  registro REACH para un pequeño destilador y etiqueta CLP. Vigencia del
  RD 3176/1983 (infusiones) y cruce del catálogo con la Orden SCO/190/2004.
  Exenciones del anexo V de REACH para sustancias naturales no modificadas
  (no se pudo leer el anexo). Si el registro sanitario hace falta y para qué
  destinos.

- **Asesor GIP o técnico agrícola**: catálogo de sustancias activas con uso
  autorizado en aromáticas (Registro de Productos Fitosanitarios del MAPA,
  usos menores), sin el cual el tratamiento va con texto libre. Plagas de
  romero, orégano, menta y el resto de especies (sin fuente leída).
- **Técnico de medio natural**: cruzar `content/aromaticas/especies_pam.csv`
  con los catálogos autonómicos de flora amenazada y de recolección regulada;
  revisar la columna de confundibles y la época orientativa (sin fuente).
- **Persona botánica** (o técnico de medio natural): revisar
  `content/aromaticas/guia_especies.csv` (guía de especies, 2026-11-09):
  rasgos para reconocer cada especie y hábitat, escritos por Claude sin
  cotejar con Flora iberica ni claves regionales. Prioridad: los rasgos que
  separan genciana/vedegambre, hinojo/cicuta, manzanilla/Anthemis y los
  tomillos. Firmar con `persona:` en `revisado_por`.

- **Asesor fiscal**: si la destilación (aceite esencial, hidrolato) y el
  secado son transformación fuera del REAGP; tipos de IVA de la planta seca
  según destino (10 % propuesto, Ley 37/1992 art. 91.Uno.1.1.º, por
  verificar) y de lo destilado (21 % propuesto, por verificar); si hacen
  falta facturas (Verifactu) para la venta de lo destilado.

## Productores piloto (2: uno de cultivo y uno de recolección)

- Probar el flujo completo zona → cosecha → destilación → lote → pasaporte.
- Validar los intervalos de rendimiento orientativos en su zona y alambique,
  y la época de las 15 especies sin fuente.

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/aromaticas.csv` (borrador, 2026-11-07),
  exportables a ARB con `scripts/traducciones/`.

## Bloqueos técnicos

- **`scripts/auditoria` y `scripts/pendientes` no conocen la vertical**: la
  lista de verticales está fija en
  `scripts/auditoria/lib/src/lista_comprobacion.dart`, fuera de la calle de
  esta vertical. Darla de alta (`solera-aromaticas`, `aromaticas`, con los
  responsables técnico de medio natural, asesor de aceites esenciales y
  asesor fiscal) es trabajo de la integración.
- **Pasaporte del lote sin el T1 del core**: QR con texto plano; sustituir
  por el pasaporte común cuando exista.
