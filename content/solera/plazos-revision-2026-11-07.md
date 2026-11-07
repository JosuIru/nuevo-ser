# Revisión de `plazos.csv` — 2026-11-07

Revisión de Claude (`revision-ia:`), no es firma. Se leyó el texto consolidado del BOE de cada norma, artículo a artículo, y su ficha de análisis («referencias posteriores») para descartar modificaciones. No se cambió ninguna fecha: las 12 coinciden con la redacción vigente.

## Veredicto por fila

| Plazo | Veredicto | Redacción vigente comprobada |
|---|---|---|
| `pac_solicitud_unica` | Correcto; nota ampliada (art. 108.3, fuera de plazo con −1 %/día hábil) | RD 1048/2022 art. 108.2 (RD 147/2023); consolidado 08/07/2026 |
| `pac_modificacion_solicitud_unica` | Correcto; la excepción de Andalucía era solo para 2026 (DT 4.ª, RD 537/2026) | art. 112.1 (RD 1177/2023) |
| `infovi_declaracion_cosecha` | Correcto; nota precisa «cooperativa o agrupación» y que se presenta ante la CA | RD 739/2015 art. 3; consolidado 30/07/2025 |
| `infovi_proveedores_justificantes` | Correcto; se presenta ante la CA, no en INFOVI | art. 6.2 (RD 683/2025, vigente desde 31/07/2025) |
| `infovi_declaracion_mensual` | Correcto; se declara aunque todo sea cero (art. 5.6) | art. 5.2 y 5.5 |
| `infovi_declaracion_agosto` / `_diciembre` | Correcto. La apertura el día 1 se deduce de «en los meses de…» | art. 5.3 |
| `aica_declaracion_mensual` | Correcto; nota amplía meses sin actividad y sistemas autonómicos | RD 861/2018 arts. 4.1, 12.3-12.5; consolidado 02/07/2025 |
| `aica_declaracion_anual_almazara` | Correcto | art. 4.1 (párrafo del RD 564/2025; vigor 01/10/2025 en aceite) |
| `rega_censo_apicola` | Correcto; se añade RD 479/2004 art. 4.3 a la cita | RD 209/2002 art. 7.5 (RD 930/2017), sigue vigente |
| `aeat_iva_303_trimestral` | **Corregido**: verticales y nota | RIVA art. 71.4; LIVA arts. 124-129 |
| `aeat_irpf_pago_fraccionado` | Correcto; nota amplía declaración negativa, forestal y subvenciones | RIRPF arts. 109-111 (sin cambios desde 2018) |

## Modelo 303 y régimen especial agrario (REAGP)

- La exención no está en el reglamento sino en la **Ley del IVA, art. 129.Uno**: el titular en REAGP no liquida IVA por esa actividad. Excepciones (art. 129.Dos): importaciones, compras intracomunitarias e inversión del sujeto pasivo, que van a una declaración no periódica (modelo 309).
- **Quedan fuera del REAGP** (art. 124.Dos LIVA): sociedades mercantiles, cooperativas y SAT, quien supera límites o renuncia a módulos o al simplificado, y lo que se **transforma** (art. 126.Uno.1.º; el art. 45 RIVA aclara que lo artesanal no cambia nada).
- Consecuencia: quesera y aceitera, bien incluidas. **Viticultura faltaba** (elaborar vino es transformar). Agro y apícola se añaden con la nota de que, si están en REAGP, no lo presentan.
- Apicultura: está en REAGP (art. 44.3 RIVA, «ganadería, incluida la… apicultura»). La consulta DGT V1869-20 solo se leyó en un resumen de terceros: **no confirmado** en fuente oficial.

## Lo que tiene que mirar el asesor fiscal

1. **Límite de compras para 2026.** La ley consolidada dice 150.000 € (art. 124.Dos.6.º); las prórrogas de 250.000 € (RDL 9/2024, 16/2025, 2/2026) se derogaron en el Congreso, pero la nota de la AEAT de 01/04/2026 dice que en 2026 se mantienen los límites de 2016-2024. Ley y Administración no coinciden: por eso la nota de la app no da cifras.
2. **Almazara que muele aceituna de terceros a maquila**: se ha razonado que es servicio no accesorio y queda fuera del REAGP (art. 126.Dos.4.º), sin doctrina leída.
3. Modelos 130/131: los fija una orden ministerial que no se leyó.

## No cubierto

- Convocatorias autonómicas de PAC de cada año (la nota lo avisa).
- Cambios publicados en el BOE después de la última actualización de cada consolidado.

## Para retirar el sello

Quien firme lee este informe y el CSV y, si lo da por bueno:

```
cd scripts/auditoria
dart run bin/auditoria.dart firmar ../../content/solera/plazos.csv --firma "Nombre (cargo, fecha)" --como persona   # o asesor
```

Recomendación: la fila `aeat_iva_303_trimestral` y la `aeat_irpf_pago_fraccionado`, mejor firmadas por el asesor fiscal (`--ids`).
