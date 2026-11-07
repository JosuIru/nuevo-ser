# Larrea Ganadera — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge `scripts/pendientes/`.

## Asesores humanos (para retirar sellos PROVISIONAL)

- **Veterinario asesor** (Navarra primero): formato del libro de registro
  (`generador_libro_registro_pdf.dart`) y del documento de movimiento
  (`generador_documento_movimiento_pdf.dart`) frente al modelo aprobado por cada
  comunidad (RD 787/2023 art. 23.1: «de formato aprobado por la autoridad
  competente»); registro de tratamientos (RD 666/2023 art. 41); catálogos de
  razas y sustancias activas; reglas de ecológico copiadas de Zunbeltz.
- **Técnico PAC / OCA**: lectura del eco-régimen de pastoreo
  (`dominio/informe_ecoregimen.dart`): fechas de cómputo y reducciones de la
  campaña en cada comunidad, si la hembra vacuna adulta cuenta 0,8 o 1,0, cómo
  tratar la cerda de cría sin peso y cómo cuentan comunales y arrendados.
- **Asesor fiscal**: REAGP ganadero (porcentaje de compensación vigente, Ley
  37/1992 art. 130; cuándo conviene el régimen general), tipos de IVA de la venta
  directa de carne, categorías del libro y si hacen falta facturas
  (`generador_extracto_economico_pdf.dart`).

## Catálogos

- `razas.csv`: comprobar contra la versión vigente del Catálogo Oficial de Razas
  (el anexo I del RD 45/2019 se actualiza por orden; se leyó el consolidado de
  21/06/2023) y firmar las cuatro razas añadidas sin fuente.
- `sustancias_activas.csv`: el contraste con CIMA Vet solo mira que haya
  medicamentos autorizados; un veterinario debe confirmar la lista y la clase
  (alopático/antiparasitario) a efectos del Reglamento (UE) 2018/848.
- `tabla_ugm.csv` (filas de Andalucía): sin revisar en esta vertical.

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/ganadera.csv` (borrador, 2026-11-07).

## Bloqueos técnicos
