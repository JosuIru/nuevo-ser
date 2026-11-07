# Larrea Ganadera

Vertical de la suite Larrea (Colección Nuevo Ser) para la **ganadería extensiva
pequeña y mixta**: ovino, caprino, vacuno de carne y porcino extensivo, con el
**pasto en el centro**. Offline, de un solo dispositivo, en castellano, euskera,
catalán y gallego (estos tres, borrador).

## Qué hace

- **Pastos**: piezas con superficie, recinto SIGPAC, tipo de pasto (mediterráneo o
  húmedo) y titularidad; contorno con el GPS y mapa. Carga en UGM/ha de cada pieza.
- **Rebaños y animales**: dónde está cada rebaño (por sus movimientos), animales
  identificados, altas y bajas parciales, historia de cada animal.
- **Manejo**: tratamientos con lo que pone la receta (art. 41 del RD 666/2023),
  tiempos de espera dobles en ecológico y límite anual de tratamientos
  (Reglamento (UE) 2018/848), calendario sanitario y registro de visitas.
- **Documentos PDF (PROVISIONALES)**: libro de registro (anexo V del RD 787/2023),
  documento de movimiento y **informe del eco-régimen de pastoreo**
  (art. 30.2 del RD 1048/2022), con la tabla UGM del trámite.
- **IA con clave propia**: transcribe la foto de una receta veterinaria.
- **Economía**: ingresos y gastos con REAGP o IVA, extracto PDF.
- **Exportación completa** en CSV.

## Lo que no hace

No recomienda medicamentos, dosis ni diagnósticos; no comunica nada a SITRAN, la
OCA ni PRESVET; no presenta ni declara nada de la PAC; no liquida impuestos.

## Desarrollo

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd apps/solera-ganadera
flutter pub get
flutter analyze && flutter test
dart run tool/compilar_catalogos.dart        # content/ganadera/*.csv → lib/datos/catalogos_generados/
flutter build apk --release                  # con flock /tmp/larrea-build-apk.lock
```

Traducciones: `content/solera/traducciones/ganadera.csv` → `cd packages/nuevo_ser_core
&& dart run tool/compilar_traducciones_solera.dart`.

Estado, decisiones y regla Z (el dominio de ganado se copió de Zunbeltz, que no
se toca): `CLAUDE.md`. Lo que espera a una persona: `BLOQUEOS-PENDIENTES.md`.
