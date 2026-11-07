# Revisión de `fitosanitarios_olivar.csv` — 2026-11-07

Revisión de Claude (`revision-ia:`), no es firma. Fuentes leídas el 2026-11-07:

- **Registro de Productos Fitosanitarios del MAPA**, exportación completa «Productos autorizados para el Cuaderno de Explotación» con fecha **06/11/2026** (2.095 productos vigentes con sus usos): https://servicio.mapa.gob.es/regfiweb (Resúmenes). Se contaron solo los usos codificados en Olivo, Olivo de almazara y Olivo de verdeo (más los genéricos Leñosas / Frutales / Especies vegetales cuando se dice).
- **EU Pesticides Database** (API completa, estado y fecha de caducidad de cada sustancia): https://api.datalake.sante.service.ec.europa.eu/sante/pesticides/active-substances?format=json&api-version=v3.0
- **Reglamento de Ejecución (UE) 2021/1165**, consolidado 01/01/2026, anexo I: https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:02021R1165-20260101
- **Reglamento de Ejecución (UE) 2018/1981** (cobre): https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32018R1981

Criterio de plazo de seguridad (PS): la columna lleva el **máximo** que aparece en el registro para un producto con esa sustancia en olivo (también en mezclas); la nota da el rango. La etiqueta del producto concreto manda siempre.

## Veredicto por fila

| id | Veredicto | Qué se cambió |
|---|---|---|
| `spinosad` | **Grave, corregido** | Fuera `prays_olivo`: el único producto en olivo es un cebo autorizado solo contra la mosca (PS 7). |
| `deltametrina` | Corregido | PS 21 → 7 (7 en pulverización, 3 en un producto de verdeo, «no procede» en trampas). Aprobada en la UE hasta 30/06/2028. |
| `caolin` | **Grave, corregido** | PS 0 → 28 (un producto lleva 28; otro, no procede). Se añade `prays_olivo` (autorizado). |
| `proteina_hidrolizada` | Corregido | La nota explica que el PS es el del insecticida con que se mezcla (en la etiqueta figura «*»). Sigue en el anexo I (234 A). |
| `oxicloruro_cobre` | Corregido | La nota decía que el límite de cobre era solo de ecológico y anual: es de **toda** la producción y son **28 kg Cu/ha en 7 años** (Reg. 2018/1981). |
| `hidroxido_cobre` | **Grave, corregido** | Fuera `emplomado` (sin uso autorizado); entran `tuberculosis_olivo` y `antracnosis_olivo`. |
| `sulfato_cobre` | **Grave, corregido** | El «sulfato de cobre» simple no está aprobado: pasa a caldo bordelés / sulfato tribásico. PS 15 → 20 (tres productos llevan 20). Se añaden tuberculosis y antracnosis. |
| `dodina` | **Grave, corregido** | Fuera `emplomado`; entra `antracnosis_olivo`. PS 21 → 7. |
| `mancozeb` | **Grave, eliminada** | No renovado (Reg. 2020/2087); periodo de gracia acabado el 04/01/2022. Ningún producto vigente. |
| `azufre_micronizado` | Corregido | PS 5 → 14 (no procede–3 en productos solo con azufre; 14 en mezclas con cobre). La nota aclara que actúa contra la negrilla, no contra la cochinilla. |
| `piretrinas_naturales` | **Grave, corregido** | PS 3 → 5. Fuera `cochinilla_tizne`: un único producto, autorizado solo contra el prays. |
| `azadiractina` | **Grave, eliminada** | Sin ningún uso autorizado en olivar en producción: solo viveros («Leñosas») y plantas madre para propagación. |
| `bacillus_thuringiensis` | Correcto | Nota mínima (PS no procede). |
| `beauveria_bassiana` | **Grave, corregido** | Fuera `cochinilla_tizne`: un único producto (cepa ATCC 74040), autorizado contra la mosca. |
| `glifosato` | **Grave, corregido** | PS 0 → 60 (7–28 en productos solo con glifosato; 60 en mezclas con MCPA). Se quitó «restringido en cubiertas vegetales activas», que no se pudo comprobar. |
| `oxifluorfen` | **Grave, corregido** | PS 0 → 21 (7 sin aceituna en el suelo y 14–21 con aceituna caída). Es candidato a sustitución. Se quitó «pre-emergencia / verificar en olivar adulto». |
| `mcpa` | Corregido | PS 0 → 60 por el criterio del máximo (no procede en productos solo con MCPA; 60 en mezclas con glifosato). |
| `acido_pelargonico` | Corregido | `ecologico` si → **no**: no está en el anexo I de 2021/1165, cuya entrada de ácidos grasos (230 A) excluye el uso herbicida. PS 0 → 1. |
| `aceite_invierno` | **Grave, corregido** | Fuera `ceratoceria` (*Parlatoria oleae*: ningún producto la cubre); entra `algodoncillo` (autorizado). |
| `fosfonato_potasico` | **Grave, corregido** | PS 7 → 15 (los 4 productos llevan 15). `ecologico` si → **no**: no figura en el anexo I. |

Las 18 filas que quedan llevan en `revisado_por` la anotación `revision-ia:` y conservan la cita previa (`fuente: fuente_publica`).

## No confirmado

- La nota del azufre: «precaución con temperaturas altas» (las etiquetas dicen «temperaturas demasiado elevadas», sin cifra).
- La nota del sulfato: «precaución por fitotoxicidad en hojas jóvenes».
- La nota de las piretrinas: «fotodegradación rápida».
- La nota de la *Beauveria*: «eficacia dependiente de humedad».
- La nota del MCPA: «usar sin viento».
- La nota del aceite de invierno: «aplicar en parada vegetativa».
- La nota de la deltametrina: restricciones de las DOP sobre residuos (no se leyó ningún pliego).
- Para azufre, glifosato, oxifluorfen y MCPA el máximo puede venir de un producto que no tenga uso para la misma plaga de la fila.

## Lo que tiene que mirar el agrónomo

1. **El criterio del máximo**. Glifosato y MCPA quedan en 60 días solo por las mezclas. Decidir si la app enseña el máximo o el valor habitual con aviso.
2. **`plagas_olivo.csv`, `arañuela_amarilla`** (no se ha tocado): figura como «Arañuela del olivo, *Tetranychus urticae*». El arañuelo del olivo suele ser el trips *Liothrips oleae*; *Tetranychus* es la araña roja. Del id depende que la fila del azufre case con el uso del registro (autorizado en *Tetranychus*).
3. `cochinilla_tizne` junta la cochinilla (*Saissetia*) y la negrilla (*Capnodium*). El registro las trata por separado (azufre en negrilla; deltametrina y aceite en *Saissetia*). Valorar si conviene separarlas.
4. El caolín y la deltametrina son de uso habitual con ciertas DOP y en integrada: revisar las restricciones de cada pliego.
5. Fuera del CSV, la landing `wp-theme/gailu-xare/inc/solera-verticales.php` enseña «Cobre + Mancozeb» como ejemplo de tratamiento. No se ha tocado (el tema tiene cambios de otra sesión).

## Para retirar el sello

```
cd scripts/auditoria
dart run bin/auditoria.dart firmar ../../content/aceitera/fitosanitarios_olivar.csv --firma "Nombre (agrónomo, nº colegiado, fecha)" --como asesor
```
