# Larrea Vivero — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge `scripts/pendientes/`.

## Asesores humanos (para retirar sellos PROVISIONAL)

- **Técnico de sanidad vegetal de la comunidad autónoma**: validar la
  etiqueta del pasaporte (`generador_pasaporte_pdf.dart`) frente al
  Reglamento de Ejecución (UE) 2017/2313 (tamaño, bandera, orden A-D, si el QR
  con «A=…|B=…|C=…|D=…» vale como soporte del código de trazabilidad), el
  registro de pasaportes y trazabilidad (RD 1054/2021, art. 20) y la lógica de
  «necesita pasaporte» (`dominio/pasaporte.dart`: usuario final, venta a
  distancia, zona protegida, traslado propio). Las condiciones del art. 83.2
  del Reglamento 2016/2031 para omitir el código de trazabilidad no se
  aplican: **por verificar**.
- **Asesor de gestión integrada de plagas** (con ROPO): validar el cuaderno de
  tratamientos (`generador_cuaderno_tratamientos_pdf.dart`) frente al modelo de
  la comunidad y si basta un PDF (registro electrónico desde el 1-1-2027).

- **Asesor fiscal**: decidir si el vivero entra en el REAGP (Ley 37/1992,
  art. 124-126: ¿«obtener directamente productos naturales vegetales» incluye
  criar planta de semilla o esqueje comprados?, ¿y la reventa de planta
  comprada?) o va al régimen general; confirmar el 10 % de IVA en plantas
  vivas, semillas y esquejes (art. 91.Uno.1.3.º y 8.º), el 12 % de
  compensación (art. 130.Cinco.1.º), las categorías de gasto y si hacen falta
  facturas (`modelos/configuracion_fiscal.dart`,
  `generador_extracto_economico_pdf.dart`).

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/vivero.csv` (borrador, 2026-11-07).

## Catálogos: lo que no se pudo contrastar

- Versión consolidada vigente de los anexos IV, XIII y XIV del Reglamento de
  Ejecución (UE) 2019/2072: se leyó la versión adoptada (legislation.gov.uk);
  EUR-Lex no devolvió el texto completo en la consulta.
- Zonas protegidas de España (anexo III del 2019/2072) para las especies del
  anexo XIV: no leídas; la persona marca si el destino es zona protegida.
- Huéspedes de las plagas prioritarias (la lista de *Xylella* es de la
  Comisión) y síntomas de todas las plagas: orientativos.
- Material forestal de reproducción: el RD 289/2003 (mod. RD 1220/2011) se
  da por vigente sin comprobar si hay norma posterior; regiones de
  procedencia sin catálogo (texto libre).
- *Trichoderma asperellum* T25: aprobación UE hasta el 30/11/2026; revisar.
- Firmas: `scripts/auditoria` no tiene la vertical «vivero» en su lista
  (código de otra calle). Pedir a la calle N que la añada.

## Bloqueos técnicos
