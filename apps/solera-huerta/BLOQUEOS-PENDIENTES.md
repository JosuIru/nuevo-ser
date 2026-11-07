# Larrea Huerta — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge `scripts/pendientes/`.

## Asesores humanos (para retirar sellos PROVISIONAL)

- **Organismo de control ecológico de la comunidad autónoma** (CPAEN, ENEEK,
  CCPAE, CRAEGA…): validar el formato del cuaderno de campo
  (`lib/servicios/generador_cuaderno_ecologico_pdf.dart`) frente al suyo, y si
  acepta un PDF o pide su plantilla o su plataforma. Firma con `asesor:`.
- **Asesor de gestión integrada de plagas** (ROPO): la tabla de tratamientos
  fitosanitarios del mismo cuaderno (RD 1311/2012) y si basta o hace falta el
  registro electrónico (SIEX) desde el 1-1-2027.
- **Asesor en venta directa / técnico de sanidad**: requisitos del RD 1086/2020
  y de la normativa autonómica de venta de proximidad para la hoja de cestas
  (`lib/servicios/generador_hoja_cestas_pdf.dart`): etiquetado, trazabilidad
  y registro sanitario. Hoy todo «por verificar».
- **Asesor fiscal**: confirmar el régimen (REAGP o general), la compensación
  del 12 % solo en ventas a empresarios (art. 130.Tres.1.º), el 4 % de las
  hortalizas, si la venta en mercado o en puesto fijo cambia el régimen, si
  las cuotas de las cestas pagadas por adelantado se apuntan al cobro o a la
  entrega, las categorías y si hace falta emitir facturas a restaurantes
  (`generador_extracto_economico_pdf.dart`, `modelos/configuracion_fiscal.dart`).
- **Técnico hortícola o asesor del organismo de control**: revisar y firmar
  los catálogos (`content/huerta/`, con `scripts/auditoria`): años mínimos de
  rotación por familia (hoy 4 en casi todas; ¿más con hernia de la col?),
  `semanas_cosecha` de todos los cultivos (estimación propia), ciclos para
  climas distintos del valle del Ebro, las 9 hortalizas y las 5 plagas o
  carencias sin fuente, y si el resumen de condiciones de los anexos I y II
  del Reglamento de Ejecución 2021/1165 es fiel y suficiente.

## Catálogos: lo que no se pudo contrastar

- Sin fuente leída: cultivos chirivía, perejil, cebolleta, guisante, kale, col
  de Bruselas, nabo, rúcula y canónigo; años de rotación de valerianáceas y
  boragináceas; mosca de la zanahoria (no hay guía GIP de umbelíferas) y las
  cuatro carencias (las hojas divulgadoras del MAPA no abrieron).
- www.mapa.gob.es falla el certificado: las guías GIP se leyeron en la Wayback
  Machine (enlaces en la nota de revisión).
- Las categorías del anexo I no se cruzaron con el Registro de Productos
  Fitosanitarios del MAPA (cada producto necesita además autorización en
  España para el cultivo): la app no lo comprueba y lo dice.

## Pilotos

- 2-3 huertas con cestas para probar el reparto (tamaños, pasos de 50 g,
  piezas) y el plan de rotación.

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/huerta.csv` (borrador, 2026-11-07).

## Bloqueos técnicos
