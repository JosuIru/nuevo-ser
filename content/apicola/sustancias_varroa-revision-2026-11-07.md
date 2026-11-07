# Revisión de `sustancias_varroa.csv` — 2026-11-07

Revisión de Claude (`revision-ia:`), no es firma. Fuentes leídas el 2026-11-07:

- **AEMPS, CIMA Vet**: registro de medicamentos veterinarios autorizados (API REST) y la ficha técnica en PDF de cada medicamento. https://cimavet.aemps.es/cimavet/rest/medicamentos?nombre=colmena · fichas en https://cimavet.aemps.es/cimavet/pdfs/es/ft/<nº registro>/FT_<nº registro>.pdf
- **Reglamento (UE) 2018/848**, anexo II, parte II, punto 1.9.6.3 (consolidado 25/03/2025): https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:02018R0848-20250325
- **Real Decreto 666/2023** (medicamentos veterinarios; sustituye al RD 109/1995 que modificaba el RD 1132/2010 citado antes): https://www.boe.es/eli/es/rd/2023/07/18/666

En abejas solo se pueden usar medicamentos veterinarios autorizados y según su ficha técnica. La columna `plazo_seguridad_dias` lleva el tiempo de espera en miel más largo entre los medicamentos con esa sustancia.

## Medicamentos para varroa autorizados en España (CIMA Vet, 07/11/2026)

| Sustancia | Medicamentos (nº registro) | Forma | Espera miel |
|---|---|---|---|
| Ácido oxálico | API-BIOXAL solución (4045), API-BIOXAL polvo (3886), VARROXAL (4250), OXYBEE (EU/2/17/216), ECOXAL (1749, no comercializado) | goteo; el polvo de API-BIOXAL y VARROXAL también por vaporización/sublimación; VARROXAL además por pulverización | 0 |
| Ácido oxálico en tira | CALISTRIP BIOX (4306) | tira de polipropileno, glicerol como excipiente | 0 |
| Ácido fórmico | FORMICPRO (4021), MAQS (3031, no comercializado) | tira de gel, evaporación | 0 |
| Fórmico + oxálico | VARROMED (EU/2/16/203) | dispersión por goteo | ficha no leída |
| Timol | APIGUARD (1487, 4075), THYMOVAR (1962) | gel; tira de esponja | 0 |
| Amitraz | APIVAR (1283), APITRAZ (2782), AMICEL VARROA (3157), OPTIVAR (4510, no comercializado) | tiras | **7 en APIVAR**; 0 en el resto |
| Flumetrina | BAYVAROL (1713), POLYVAR (3526, no comercializado) | tiras | 0 |
| Tau-fluvalinato | APISTAN (2680) | tira | 0 |
| Ácido láctico | **ninguno** | — | — |

## Veredicto por fila

| id | Veredicto | Qué se cambió |
|---|---|---|
| `acido_oxalico` | Corregido | Se quitó «mejor vehículo: sublimación» (opinión). La nota exige un medicamento autorizado para vaporización, colonias sin cría y sin alzas, y recoge que la ficha no la recomienda en verano. |
| `acido_oxalico_goteo` | Corregido | Se quitó «más agresivo para abejas que la sublimación» (no confirmado). Sin alzas; colonias sin cría. |
| `acido_formico` | **Grave, corregido** | El vehículo era `nebulizacion`, uso **no autorizado**. Ahora `tira_polimero`, el valor más cercano que admite el compilador; la nota precisa «tira de gel por evaporación» y la temperatura de 10–29,5 °C. |
| `timol` | Corregido | Vehículo `tira_polimero` (el más cercano); la nota precisa gel o tira de esponja. Se quitó «plazo retirada antes de cosecha»: la ficha da espera 0 y prohíbe usarlo durante la mielada. |
| `amitraz` | Corregido | Espera 30 → **7** (máximo de las fichas: APIVAR). No usar durante el flujo de miel. |
| `flumetrina` | Corregido | Espera 30 → 0. Otros productos de la colmena no se consumen hasta la primavera siguiente. |
| `fluvalinato` | Corregido | Espera 30 → 0. La ventana se queda en `otono` (la columna admite un valor); la nota añade primavera antes de las mieladas. No reciclar la cera tratada. |
| `acido_lactico` | **Grave, eliminada** | Ningún medicamento autorizado en España. |
| `mezcla_oxalico_glicerol` | **Grave, corregido** | «Tira de cartón impregnada» describía la preparación casera, **no autorizada**. El único medicamento autorizado es una tira de polipropileno. Nombre: «Ácido oxálico en tira (excipiente glicerol)». 6 semanas, sin alzas, otoño antes de la piña invernal. |

**Cabecera**: la fuente es la AEMPS (CIMA Vet), no el MAPA; el RD 1132/2010 se sustituye por el RD 666/2023; se avisa de que en abejas solo valen medicamentos autorizados según su ficha. `revisado_por` pasa de «AEMPS CIMA Vet + RD 1132/2010» a «AEMPS CIMA Vet + RD 666/2023» y lleva encima la anotación `revision-ia:`. `fecha_revision`: 2026-11-07.

**Ecológico**: el punto 1.9.6.3 e) admite ácido fórmico, láctico, acético y oxálico, mentol, timol, eucaliptol y alcanfor. Los sintéticos (letra f) obligan a aislar el colmenar, cambiar toda la cera y pasar 12 meses de conversión: por eso quedan en `no`.

## No confirmado

- `eficacia_orientativa` de todas las filas.
- La ficha de VARROMED y la de OXYBEE (el PDF no se pudo descargar). Su autorización sí consta en CIMA Vet.
- El Reglamento (UE) 2020/464: no se leyó.
- Que el amitraz tenga «resistencias documentadas en Europa» y que los piretroides tengan resistencias (no se leyó bibliografía).
- La mezcla timol + eucaliptol + mentol + alcanfor (tipo Apilife Var): no aparece en CIMA Vet, así que no se añadió.

## Lo que tiene que mirar el veterinario

1. **Las columnas enumeradas del compilador** no tienen «gel» ni «evaporación». Fórmico y timol quedan como `tira_polimero` con la precisión en la nota. Valorar ampliar el enumerado (el compilador no se ha tocado).
2. **`ventana_aplicacion` admite un solo valor**: el tau-fluvalinato (primavera u otoño) y el oxálico (sin cría) quedan simplificados.
3. Si la app debe decir algo del uso por cascada (Reg. (UE) 2019/6, arts. 113–114) para sustancias sin medicamento autorizado, como el ácido láctico.
4. Que el tiempo de espera de 7 días de APIVAR, frente a 0 en los demás amitraz, se refleje bien al elegir el medicamento.

## Para retirar el sello

```
cd scripts/auditoria
dart run bin/auditoria.dart firmar ../../content/apicola/sustancias_varroa.csv --firma "Nombre (veterinario, nº colegiado, fecha)" --como asesor
```
