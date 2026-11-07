# Revisión de `materias_activas.csv` — 2026-11-07

Revisión de Claude (`revision-ia:`), no es firma. Fuentes leídas el 2026-11-07:

- **Registro de Productos Fitosanitarios del MAPA**, exportación completa con fecha **06/11/2026**: https://servicio.mapa.gob.es/regfiweb (Resúmenes). Se contaron los usos codificados en Vid, Vid de mesa y Vid de vinificación.
- **EU Pesticides Database** (API completa): https://api.datalake.sante.service.ec.europa.eu/sante/pesticides/active-substances?format=json&api-version=v3.0
- **Reglamento de Ejecución (UE) 2021/1165**, consolidado 01/01/2026, anexo I: https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:02021R1165-20260101
- **Reglamento de Ejecución (UE) 2018/1981** (cobre): https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32018R1981

Criterio de PS: la columna lleva el **máximo** del registro para un producto con esa sustancia en vid (también en mezclas), salvo en folpet, que lleva 28 con el aviso de la vid de mesa en la nota. La nota da el rango. La etiqueta del producto concreto manda siempre. `fecha_revision` pasa a 2026-11-07.

## Veredicto por fila

| id | Veredicto | Qué se cambió |
|---|---|---|
| `azufre` | **Grave, corregido** | PS 0 → 28. Lo habitual es no procede–5, pero un producto lleva 7 y otro 28. «T>28 °C» pasa a «temperaturas elevadas»: las etiquetas no dan cifra. |
| `sulfato_cobre` | Corregido | Nombre: sulfato cuprocálcico (caldo bordelés). La nota del límite ya no habla de «media móvil»: son 28 kg Cu/ha en 7 años y los Estados miembros pueden fijar ≤4 kg/ha/año. |
| `hidroxido_cobre` | Corregido | PS 21 → 28 (7–21 en productos solo con hidróxido; 28 en alguna mezcla). |
| `oxicloruro_cobre` | Corregido | PS 21 → 28 (15–21 en productos solo con oxicloruro; 28 en alguna mezcla). |
| `folpet` | **Grave, corregido** | PS 28, como se pidió; la nota avisa «vid de mesa hasta 56/70» (56 solo, 70 en mezclas). Renovado hasta 2039. |
| `fosetil_aluminio` | Correcto | PS 28. |
| `dimetomorfo` | **Grave, eliminada** | No renovado (Reg. 2024/1207). Caducó el 20/05/2024 y el periodo de gracia acabó el 20/05/2025. Ningún producto vigente. |
| `azoxistrobin` | Corregido | PS 21 → 28 (21 solo; 28 en mezclas). |
| `miclobutanil` | **Grave, eliminada** | No aprobado desde el 31/05/2021. Ningún producto vigente. |
| `tebuconazol` | Corregido | PS 21 → 28 (7–21 solo; 28 en mezclas). «Bajo revisión UE» pasa a «candidato a sustitución, prorrogado hasta 31/07/2028». |
| `penconazol` | Corregido | PS 28 → 14 (todos los productos). |
| `boscalid` | **Grave, corregido** | En vid solo está autorizado contra el **oídio**, no contra la botritis. PS 21 → 28. |
| `fluopiram` | **Grave, corregido** | PS 21 → 28 (3–28 según producto). |
| `pirimetanil` | **Grave, eliminada** | Aprobado en la UE, pero ningún producto vigente en España tiene uso en vid. La nota de `ciprodinil` que lo citaba se reescribió. |
| `ciprodinil` | Corregido | PS 21 → 28 (21 en vinificación, 7 en mesa, 28 en mezcla con tebuconazol). |
| `fludioxonil` | Corregido | La nota dice que solo existe en mezcla con ciprodinil (21 en vinificación, 7 en mesa). |
| `bacillus_thuringiensis_kurstaki` | Correcto | — |
| `spinosad` | Corregido | La nota decía «autorizado en ecológico con condiciones»: el anexo I lo recoge sin condiciones; la toxicidad para abejas es mitigación de etiqueta. |
| `aceite_parafinico` | Corregido | PS 0 → 1. Se quitó «aplicar fuera del periodo de floración», que no se pudo comprobar. |

Las 16 filas que quedan llevan en `revisado_por` la anotación `revision-ia:` y conservan la cita previa.

## No confirmado

- `tipo_accion` (contacto, translaminar, sistémico) de cada fila: no se contrastó con las fichas.
- Las notas agronómicas sobre resistencias y mezclas habituales.
- Si España fija un máximo anual de cobre por hectárea por debajo de lo que dice el Reglamento 2018/1981.

## Lo que tiene que mirar el agrónomo

1. **El criterio del máximo** sube varios PS por mezclas (azufre 28, cobres 28, azoxistrobin, tebuconazol y ciprodinil 28). Decidir si la app enseña el máximo o el valor habitual con aviso.
2. **Folpet en vid de mesa**: 28 días es corto para ese uso (56–70). Valorar una columna o una fila aparte para la vid de mesa.
3. Alternativas para botritis tras quitar pirimetanil y boscalid: quedan fluopiram, ciprodinil y fludioxonil (y tebuconazol en algunos productos).
4. En el registro también tienen uso en black-rot azoxistrobin, tebuconazol y fosetil (en mezclas), pero en el CSV `black_rot` solo figura en folpet. Valorar si se añade.

## Para retirar el sello

```
cd scripts/auditoria
dart run bin/auditoria.dart firmar ../../content/viticultura/materias_activas.csv --firma "Nombre (agrónomo, nº colegiado, fecha)" --como asesor
```
