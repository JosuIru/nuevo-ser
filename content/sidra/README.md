# content/sidra/

Catálogos de Larrea Sagardoa (`apps/solera-sidra`). CSV en UTF-8 con `,`; las
líneas que empiezan por `#` son comentarios y el compilador las salta.

| CSV | Contenido | Revisión (2026-11-07) |
|---|---|---|
| `variedades_manzana.csv` | Variedades de los pliegos de Euskal Sagardoa (54 principales + 138 restantes) y Sidra de Asturias (76, con su clasificación tecnológica) | `fuente_publica:` copiadas del texto del pliego |
| `variedades_uva_txakoli.csv` | Variedades recomendadas y autorizadas de las tres DO de txakoli | `fuente_publica:` ap. 6 de cada pliego |
| `plagas_manzano.csv` | 18 plagas y enfermedades del manzano | `revision-ia:` nombre común y científico contra los agentes del registro del MAPA. **Los síntomas no están contrastados** |
| `fitosanitarios_manzano.csv` | 61 sustancias activas con uso vigente en manzano contra esas plagas | `revision-ia:` registro del MAPA + EU Pesticides DB + Reg. 2021/1165 |
| `dop_sidra_txakoli.csv` | Límites de cada producto que la app compara (no certifica) | `fuente_publica:` pliegos |

**Solo cuenta como firma humana** un `revisado_por` que empiece por `asesor:` o
`persona:`. `fuente_publica:` y `revision-ia:` son revisión documental: el
indicador `catalogosCompletamenteRevisados` sigue en `false` y la app enseña el
banner de datos provisionales.

## Cómo se hizo `fitosanitarios_manzano.csv`

1. Se descargó la exportación «Productos autorizados para el Cuaderno de
   Explotación» del Registro de Productos Fitosanitarios del MAPA, con fecha
   06/11/2026 (2.095 productos; https://servicio.mapa.gob.es/regfiweb →
   Resúmenes).
2. Se tomaron los usos de los productos **vigentes** en los cultivos «Manzano»,
   «Frutales de pepita» y «Frutos de pepita» cuyo agente coincide con una plaga
   de `plagas_manzano.csv` (por nombre científico).
3. Por sustancia (las cepas de un mismo microorganismo, las feromonas de
   lepidópteros y los aceites de parafina se agrupan): plagas objetivo, número de
   productos y **plazo de seguridad máximo** de todos sus usos, mezclas incluidas
   (vacío si todos dicen «no procede»).
4. Se cruzó con la EU Pesticides Database (07/11/2026): solo entran sustancias
   «Approved» con expiración posterior al 07/11/2026. **Fuera**: esfenvalerato
   (en la base expira el 31/05/2026; puede haber prórroga sin publicar: BLOQUEOS).
5. `ecologico = si` cuando la sustancia está en el anexo I del Reglamento (UE)
   2021/1165 (consolidado 01/01/2026), incluidos los microorganismos del punto 3.
   El producto concreto y la certificadora mandan.

No entran herbicidas ni productos de poscosecha (no son del cuaderno de la
pomarada en esta versión). La app **nunca** muestra marcas ni dosis.

## Regenerar

```bash
cd apps/solera-sidra
dart run tool/compilar_catalogos.dart
dart format lib/datos/catalogos_generados
flutter test
```
