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

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/vivero.csv` (borrador, 2026-11-07).

## Bloqueos técnicos
