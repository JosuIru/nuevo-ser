# Fichas imprimibles

Fichas A4 para el aula sin pantallas, una por habilidad de Uno Roto, generadas a partir de `apps/uno-roto/assets/data/skills.json`. Cada ficha tiene una explicación con una línea «Ejemplo: …», tres ejercicios con renglones y una pregunta de «Explícalo con tus palabras». Hay ficha para 102 de las 106 habilidades: las otras cuatro (GEO.07, EST.02, FUN.02 y FUN.03) necesitan un dibujo que v0.1 no genera.

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd scripts/fichas && dart pub get

dart run bin/fichas.dart listar                         # qué habilidades tienen ficha
dart run bin/fichas.dart generar FR.10 DEC.04           # una ficha por PDF, en fichas_pdf/
dart run bin/fichas.dart generar --dominio FR --un-pdf  # un dominio entero en un solo PDF
dart run bin/fichas.dart generar FR.10 --semilla 2      # otra semilla, otros ejercicios
```

La misma semilla da siempre la misma ficha. Hay ejemplos en `muestras/` (semilla 1).

## Convenciones

- Coma decimal; sin separador de miles hasta 9999 y con espacio desde 10 000 (norma RAE); signo menos tipográfico (−).
- Multiplicar: `×` en Primaria y `·` en ESO, según el curso de la habilidad en `skills.json`. Dividir: `:`.
- Euros con dos decimales cuando no son enteros (52,50 €).
- Lo comprueban los tests del grupo «reglas comunes de la revisión» (`test/generadores_test.dart`), junto con los del grupo «soluciones recalculadas desde el enunciado», que recalculan cada solución con 3000 semillas por un camino distinto al del generador.

## Pendiente

- **Fracciones apiladas.** Hoy se escriben en línea con barra (`(1/3 + 3/6) : 4/5`); en Primaria se escriben una encima de otra. Es un cambio del maquetador (`lib/src/maquetador_pdf.dart`), aún sin hacer.
- **Solucionario.** Las soluciones existen en el código (`Ejercicio.solucion`) pero no se imprimen.
- **Hueco para dibujar.** Cuando EST.01 pide dibujar un gráfico de barras, el hueco son renglones; una cuadrícula sería mejor.
- **Revisión docente.** Las explicaciones y los ejemplos los escribió una IA y los revisó otra (ver `revision-2026-11-07.md`); falta la revisión de una persona docente.
