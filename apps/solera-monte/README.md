# Larrea Monte

Cuaderno del monte para propietarios de **montes particulares** pequeños y
para **juntas vecinales, concejos y comunidades de montes vecinales en mano
común** que gestionan el monte comunal: leña, madera, pastos, setas y
prevención de incendios. Parte de la suite Larrea (Colección Nuevo Ser).
Funciona sin cobertura y en castellano, euskera, catalán y gallego (las tres
últimas en borrador).

## Qué hace

- **Rodales** con especie principal (catálogo del IFN4), edad, estado de la
  masa y superficie; el **contorno se dibuja caminando la linde con el GPS**
  y la app calcula la superficie (orientativa). Superficie por especie y mapa.
- **Árboles singulares y parcelas de muestreo** con código para la chapa.
- **Plan de gestión**: actuaciones previstas por año y rodal y lo hecho;
  estado de cada una (hecha, en curso, pendiente, atrasada) y volumen
  previsto frente a aprovechado.
- **Aprovechamientos** de la campaña (los del art. 6 de la Ley de Montes)
  con su trámite ante la comunidad autónoma y avisos de la Ley 43/2003,
  art. 37 (menor cuantía, un mes para comunicar lo obtenido si se vende).
- **Sorteo de lotes de leña vecinal reproducible y verificable**: lista
  cerrada con huella SHA-256, semilla pública posterior, orden por
  SHA-256 de «semilla|nombre». Con los mismos datos cualquiera saca el mismo
  resultado (también con `sha256sum`); la app lo comprueba al abrirlo y saca
  el acta en PDF.
- **Incendios**: pistas, puntos de agua, cortafuegos y fajas, con su revisión
  antes de la época de peligro (que apunta la persona) y avisos en Hoy.
- **IA** (clave propia de Anthropic): propone plaga, enfermedad o daño por
  foto; avisa si puede ser una plaga prioritaria de la UE. Nunca tratamientos.
- **Documentos PDF** (PROVISIONALES): parte de aprovechamientos, estado del
  plan, revisión de incendios, acta del sorteo y extracto de ingresos y gastos.
- **Ingresos y gastos** del monte, con margen por rodal.

## Lo que no hace

No autoriza aprovechamientos ni dice que no necesiten autorización. No decide
quién tiene derecho a lote. No sustituye al técnico forestal en el
señalamiento ni en el plan. No recomienda productos ni tratamientos. No afirma
que se cumpla ninguna norma. Ver `CLAUDE.md` (normativa con enlaces) y
`BLOQUEOS-PENDIENTES.md`.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze && flutter test
dart run tool/compilar_catalogos.dart      # content/monte/*.csv → lib/datos/catalogos_generados/
```
