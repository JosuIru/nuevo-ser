# Larrea Frutal — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge `scripts/pendientes/`.

## Asesores humanos (para retirar sellos PROVISIONAL)

- **Asesor de gestión integrada de plagas** (con ROPO): validar el formato del
  cuaderno de explotación (`generador_cuaderno_explotacion_pdf.dart`) frente al
  modelo de la comunidad autónoma y si basta un PDF o hace falta el registro
  electrónico (SIEX). Firma en `revisado_por` con `asesor:`.
- **Técnico de la cooperativa o del seguro agrario**: validar el parte de
  cosecha y rendimientos (`generador_parte_cosecha_pdf.dart`) y si el apunte de
  heladas y pedrisco sirve como memoria del siniestro.
- **Asesor fiscal**: confirmar el régimen (REAGP o general), el 12 % de
  compensación (Ley 37/1992 art. 130.Cinco), el IVA del 4 % en la venta de
  frutos secos y fruta (y el del **pistacho**, que no figura en el Código
  Alimentario 3.22.07), las categorías de gasto y si hace falta emitir facturas
  (`generador_extracto_economico_pdf.dart`, `modelos/configuracion_fiscal.dart`).
- **Asesor de gestión integrada de plagas**: revisar y firmar los catálogos
  (`content/frutal/`, con `scripts/auditoria`): plagas y umbrales (las filas de
  nogal y castaño no tienen guía leída), sustancias activas y plazos de
  seguridad (`revision-ia:`, no firma), variedades (autocompatibilidad, épocas
  de floración y **grupos de incompatibilidad**, hoy vacíos), fenología
  (meses, estados sensibles y **temperaturas críticas**, hoy vacías) y
  colmenas por hectárea (la única cifra es de 1985).

## Catálogos: lo que no se pudo contrastar

- Guías GIP de nogal, castaño, pistachero y frutales de hueso y pepita: no se
  pudieron descargar (www.mapa.gob.es falla el certificado y la Wayback dio
  429). Sus plagas van sin umbral y sin revisar; hueso y pepita, sin plagas.
- Sustancias que se dejaron fuera: «aceite de parafina» sin CAS (no se sabe
  cuál es), aceite de parafina CAS 97862-82-3 (la EU Pesticides DB lo da
  aprobado con caducidad 31/12/2021: incoherente), *Bacillus amyloliquefaciens*
  FZB24 (no está en la base UE).
- Aprobaciones UE que caducan en 2027 (ditianona, azadiractin, caolín,
  parafina 64742-46-7, protioconazol, kresoxim-metil, clorantraniliprol,
  azufre, D747, *Aureobasidium*, *Beauveria*): revisar el catálogo en 2027.
- Pistachero: sin usos extraídos del registro (pulgones, *Labidostomis*,
  *Botryosphaeria* existen) ni plagas en el catálogo.

## Registro electrónico (SIEX) desde el 1-1-2027

- El registro de tratamientos debe ser electrónico desde el 1/1/2027 (RD
  1311/2012 art. 16.1, mod. RD 1039/2025). La app genera un PDF PROVISIONAL y
  no exporta al SIEX ni a los cuadernos autonómicos: depende del módulo
  transversal T4 (calle N). Hasta entonces, avisar a las explotaciones piloto.
- Pedir a la calle N que `content/solera/plazos.csv` recoja este plazo
  (fuera de las rutas de esta vertical).

## Revisión nativa eu/ca/gl

- Textos de `content/solera/traducciones/frutal.csv` (borrador, 2026-11-07).

## Bloqueos técnicos
