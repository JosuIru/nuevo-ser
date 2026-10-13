# Material de Zunbeltz — 2026-10-13

Correo de **Dinamiza Zunbeltz ETA-NTG** (Pablo) con material para la app. Originales en `~/Documentos/zunbeltz-app/cuestionesavanzadasapp/` (fuera del repo: contienen datos de una persona tester).

Leyenda: ✅ ya existe · 🟡 existe a medias · ❌ no existe.

## Qué llegó

| Archivo | Contenido |
|---|---|
| `Ganado.docx` | Tareas de **Ganado** (11) e **Instalaciones** (~12, con subtipos), cada una marcada Rutinaria / Puntual / Periódica / Estacional. Al final, los conceptos de gasto que usan en sus Excel. |
| Hoja de seguimiento de un test real (.xlsx) | Seguimiento real de un test avícola: 300 pollos, 4 meses (1-jun → 1-oct-2026). Hoja de gastos/ingresos + hoja de listado de amortizaciones. |
| Logo de Zunbeltz, logo de RETA | En color y con buena resolución. |
| Guía gráfica de la Fundación Carasso (PDF) | Solo la guía, sin el logo. |

**No llegó**: el logo de Carasso (versión en español) ni el del Gobierno de Navarra. **Decisión (Josu, 2026-10-13)**: usar los logos del footer de zunbeltz.com (bloques Impulsan / Apoyan / Colaboran / Miembro de). Están en verde salvia monocromo, tal como se ven en la web. Fotos aéreas de las fincas: las mandarán más adelante, todas juntas.

## La hoja de seguimiento

### Estructura de gastos

Seis **bloques fijos** (filas amarillas; Pablo: «las partidas generales son fijas, las otras variarán según proyecto»):

1. **I. Costes directos** — Animales · Compra de alimento (forraje, concentrados, transporte de concentrados) · Productos zoosanitarios y otros suministros · Inseminación · Vacunas + veterinario · Tasas CPAEN · Costes asociados al animal (luz, calefacción) · Semillas y manejo de pastizales · Canon de arrendamiento. En el test avícola aparecen además cama, limpieza/desinfección, agua y luz, transporte.
2. **II. Costes maquinaria** — Trabajos realizados · Combustibles · Reparaciones y repuestos de cercados.
3. **III. Coste de transformación** — Transporte · Tasa sanitaria · Sacrificio · Deshuese/despiece · Trabajos de elaboración/obrador · Envasado · Bolsas de envasado · Transporte de venta · Comercialización.
4. **IV. Costes mano de obra** — Asalariada · No asalariada.
5. **V. Costes indirectos** — Intereses, gastos financieros e impuestos · Mano de obra familiar.
6. **VI. Amortización** — Instalaciones (aprisco, caseta vestuario, corral móvil, placas solares…) · Material ganadero (abrevaderos, manga, comederos, bidón de 1000 L, pastor eléctrico…) · Adecuaciones (cierres, puertas, muro seco, desbroces…).

**Ingresos**: venta de ganado y productos ganaderos · venta de transformado · subvenciones directas.

Cada línea se calcula como **cantidad × precio**, con unidades distintas según la línea: kg por animal y día × cabezas × días × €/kg (alimentación), km × €/km (transporte), cabezas × €/cabeza (sacrificio).

### Reparto tester / Zunbeltz

En el Excel, la persona tester asume animales + alimentación + zoosanitarios (`I3 = G3+G6+G7`), y Zunbeltz el resto (cama, limpieza, transporte, transformación, mano de obra, amortizaciones). ✅ Coincide con `asumidoPorDefecto` (convenio, art. 7).

**Fianza = 10 % de los costes que asume Zunbeltz** (`J4 = I4*0.1`). ✅ Coincide con `BalanceConvenio.fianzaReferenciaCentimos`.

### Hoja de amortizaciones

Inventario de bienes: precio por unidad · unidades · subtotal · total con IVA del 21 % · meses de vida útil · cuota mensual (total con IVA ÷ vida útil) · **cuota × meses que dura el test** = lo que se imputa al proyecto. Agrupado en Instalaciones / Material ganadero (por especie: porcino, equino/vacuno, ovino, avícola) / Adecuaciones de finca. Incluye la tabla de coeficientes máximos de Hacienda (edificaciones 5 %/20 años, instalaciones 15 %/10 años, material ganadero 15 %/6 años…).

La mano de obra asalariada se imputa como **porcentaje de un coste compartido**: el 2 % de 4 meses de un sueldo (`(2455*4)*0.02`).

### Errores en su Excel (lo que la app evita)

- `I4` («Costes Zunbeltz-Fianza») tiene **`#REF!`**: la fianza no se calcula.
- El test dura **4 meses** (`B51`), pero las amortizaciones se multiplican por **3** (`I4 = H4*3`…) y las adecuaciones de finca por **10** (`I45 = H45*10`).
- `H35` divide entre `G36` en vez de `G35`. Da lo mismo de casualidad, porque ambas valen 72.
- Ingresos vacíos y, aun así, la nota dice «Rentabilidad > 9,73 €/animal».
- Nota «FALTA EL CONVERSOR». ✅ Es la calculadora de transformación.

### Ojo: contenido generado por IA

Las capturas pegadas bajo la hoja (ración casera para pollos, calendario de temperaturas, estirpes de crecimiento lento) son respuestas de un asistente de IA, con citas a The Poultry Site, Facebook y la Junta de Andalucía. **No se usan como datos de referencia en la app** (hard limit: no inventar datos sanitarios/agronómicos sin fuente verificable).

## Implica para la app

| | Qué | Estado |
|---|---|---|
| 1 | **Gastos en dos niveles**: los 6 bloques fijos + partida variable con sugerencias. Informe con subtotales por bloque, como su Excel. | ✅ hecho 2026-10-13 |
| 2 | Ingresos: separar venta en vivo / transformado / subvenciones. | ✅ hecho 2026-10-13 |
| 3 | **Inventario de bienes amortizables** mantenido por coordinación (panel WP). Cada proyecto marca qué usa, cuántas unidades y qué porcentaje, y la cuota se calcula sola con los meses del test. | ✅ hecho 2026-10-13 |
| 4 | Imputar un **porcentaje de un coste compartido** (mano de obra asalariada). | 🟡 resuelto para bienes amortizables (porcentaje por uso); para gastos corrientes, hoy se apunta el importe ya imputado |
| 5 | Líneas de presupuesto con fórmula (cantidad × precio con unidades). | ❌ |
| 6 | Especies: **aves y porcino** además de bovino y ovino. Tipos de punto nuevos: aprisco, placas solares, vestuario, bebedero móvil, pastor eléctrico, isotermo, molino. | ❌ |
| 7 | **Plantillas de tarea** a partir de `Ganado.docx` (grupo · tarea · subtipo · periodicidad sugerida); las tareas de «Compra» podrían generar el gasto. | ❌ |
| 8 | Logos de impulsores, apoyos y colaboradores en la app y en los informes. | ✅ hecho 2026-10-13 |

## Preguntas abiertas para Pablo

1. Las tareas **rutinarias**, ¿cada cuánto se hacen (diarias, semanales)? Y las **estacionales**, ¿en qué meses?
2. ¿La fianza es **siempre** el 10 % de lo que asume Zunbeltz?
3. ¿Las amortizaciones se calculan **siempre con el IVA incluido**? La app lo deja elegir por bien; por defecto, sí.
4. ¿El inventario de bienes es **común a todos los proyectos**, para mantenerlo una sola vez?
5. Además de bovino y ovino, ¿habrá testers de **aves y porcino** (el inventario ya tiene material de porcino)?
6. ¿Os sirven los logos de la web (verde monocromo) o preferís los oficiales en color? La guía de Carasso pide el logo con su mención legal y un tamaño mínimo de 20 mm.
