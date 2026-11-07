# V3 — Larrea Frutal (frutos secos y fruta) · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de V3 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-frutal/` · `scripts/nueva_vertical.sh frutal "Larrea Frutal" 7A4E2D F5EFE2 frut Frutal` · prefijo de commits `solera-frutal:`.

## Para quién

Explotaciones pequeñas y medianas de **almendro, avellano, nogal, castaño, pistacho** y frutal de hueso y pepita, muchas en secano y en zonas de nueva plantación. **Fuera**: centrales hortofrutícolas y cooperativas grandes.

## Diferencial

La competencia que se ve es de propósito general (p. ej. [Farmable](https://farmable.tech/es/category/pest-disease-management-es/), integrada con el SIEX). Larrea Frutal compite en lo de siempre: offline en el campo, las cuatro cooficiales, precio y **especialización por especie**:

| Pieza | Base |
|---|---|
| Parcelas, árboles o filas, variedades y **polinizadoras** (el almendro autoincompatible necesita variedad polinizadora y colmenas) | Agro (planta con identidad) |
| Calendario fenológico por especie y zona, con avisos de heladas en floración | `calendario_olivar` de aceitera + meteo |
| **Colmenas de polinización**: contrato con el apicultor, colmenas por hectárea, fechas | puente con Larrea Apícola |
| Plagas clave con su seguimiento: avispilla del almendro (*Eurytoma amygdali*), gusano cabezudo, balanino del avellano, carpocapsa del nogal y la castaña | catálogos + IA |
| Cosecha por parcela: kg en cáscara, rendimiento en grano, calibre, humedad | agro |

## Normativa (verificar el texto vigente antes de cada PDF)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| RD 1311/2012 (uso sostenible de fitosanitarios) y cuaderno de explotación | Cuaderno de tratamientos, como agro | Modelos oficiales de referencia: [Andalucía v8 (jul-2025)](https://cdn.juntadeandalucia.es/sites/default/files/inline-files/2025/07/20250703_MODELO_DE_CUADERNO_DE_EXPLOTACION_v8.pdf), [Aragón](https://www.aragon.es/sanidad-y-certificacion-vegetal/control-de-medios-de-produccion/cuaderno-de-explotacion) |
| Cuaderno digital / SIEX (RD 1054/2022): registro electrónico de fitosanitarios **aplazado al 1-ene-2027** según [agronews](https://www.agronewscastillayleon.com/aplazamiento-cuaderno); **verificar en BOE** | Modelos con todos los campos del CUE (módulo transversal T4) | — |
| Guías de gestión integrada de plagas del MAPA: [almendro](https://www.mapa.es/es/agricultura/temas/sanidad-vegetal/guiadealmendroweb_tcm30-57951.pdf), [avellano](https://servicio.mapa.gob.es/es/agricultura/temas/sanidad-vegetal/guiadeavellanoweb_tcm30-57953.pdf) | **Fuente pública de los catálogos de plagas** (bloque 10) | — |
| Seguro agrario de frutos secos ([orden 2026 en consulta, ENESA](https://www.mapa.gob.es/dam/mapa/contenido/enesa/participacion-publica/participacion_publica_2026/julio/om_frutos-secos_2026.pdf)) | Fechas de garantía y siniestros apuntados (helada, pedrisco) como recordatorio | Solo recordatorio; la app no tramita |

## Bloques (particularidades)

| Bloque | Contenido |
|---|---|
| 2 | `Explotacion`, `Parcela` (especie, marco, riego o secano), `FilaArboles` o `Arbol`, `Variedad` (con grupo de polinización), `ContratoPolinizacion`, `Tratamiento`, `Riego`, `Cosecha` (kg en cáscara, rendimiento, calibre, humedad), `Helada` |
| 4 | Cuaderno de explotación (tratamientos, abonados, riegos), copiado de agro con los campos del modelo andaluz v8 |
| 5 | Parte de cosecha y rendimientos por campaña y parcela, PROVISIONAL |
| 6 | `especies_frutal.csv`, `variedades_frutal.csv` (con compatibilidades de polinización), `plagas_frutal.csv`, `fitosanitarios_frutal.csv` (solo sustancias activas), `fenologia_frutal.csv` |
| 7 | IA de plagas y enfermedades por especie con el cliente del core |
| 9 | REAGP, como agro |
| Branding | **cáscara de almendra `#7A4E2D` + crema `#F5EFE2`** |

## Hard limits

Los de la suite: nada de marcas ni dosis; el cuaderno no sustituye la firma del asesor; los avisos de helada son orientativos.

## Bloqueos humanos previstos

Asesor de gestión integrada de plagas (cuaderno y catálogos) · asesor fiscal · 2-3 explotaciones piloto (almendro de secano, avellano, castaño) · revisión nativa eu/ca/gl.
