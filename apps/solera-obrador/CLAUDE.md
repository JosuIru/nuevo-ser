# Larrea Obrador — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/obrador.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 9 modelos, 11 tablas en la v1, `ComposicionReceta`; 16 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas: Hoy, Recetas, Ingredientes (con lotes recibidos), Autocontrol, Ajustes. Desde la cabecera de Hoy: Hornadas (propone las piezas pedidas y el código de lote; marca los lotes usados de los ingredientes directos), Pedidos fijos y Masa madre. 19 tests, 3 de pantalla |
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Documentos: cuaderno de autocontrol del mes (una tabla por tipo + incidencias y acciones correctoras) y cartel de alérgenos del mostrador. Ficha técnica desde cada receta (ingredientes por peso con los de alérgeno en MAYÚSCULAS, %, sal estimada). Datos en funciones puras con test; PDF con `informe_periodico` del core. 25 tests |
| 6 Catálogos | ✅ 2026-11-07 | `content/obrador/`: alérgenos (Reglamento 1169/2011 anexo II), denominaciones del pan (RD 308/2019 consolidado, con artículo y sal máxima), ingredientes base y controles tipo (sin revisar). Autocompletado de ingredientes, denominación en la receta con aviso de sal, sugerencias de control y banner en Hoy. 30 tests |
| 7 IA visual | ✅ 2026-11-07 | Ingrediente → «Leer etiqueta con IA»: foto de la etiqueta o ficha del proveedor → propuesta (ingredientes, alérgenos, trazas) con salida estructurada limitada a los 14; la persona la ve y decide. Modelo equilibrado del core (`modeloClaudeEquilibrado`), clave BYO en `estado/clave_anthropic_obrador.dart`. La foto se borra al terminar. 33 tests |
| 8 Branding + GPS | ✅ 2026-11-07 (placeholder) | Logo ImageMagick (hogaza tostada sobre crema) en `assets/`, iconos de lanzador generados, logo en la cabecera de Hoy. **GPS: no aplica** (el obrador no trabaja con parcelas) |
| 9 Economía | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Ingresos y gastos: apuntes con base, tipo de IVA (0/4/10/21) y cuota; resumen del mes (resultado, IVA repercutido y soportado orientativos) y extracto PDF con sello. Precio de venta por receta y margen sobre el coste de ingredientes. **No es REAGP** ni liquidación de impuestos. 37 tests |
| 10 Revisión con fuente pública | ✅ en parte (2026-11-07) | Alérgenos y denominaciones ya citan su norma (`fuente_publica`). Ingredientes base y controles tipo quedan sin revisar a propósito: el alérgeno real es el de la ficha del proveedor y los límites, los del plan de cada obrador. El banner sigue hasta la firma humana |
| 11 APK + ayuda | ✅ 2026-11-07 | Ayuda in-app (7 apartados, 4 idiomas, con «lo que la app no hace»), README, APK release de 65 MB (copia en `~/larrea-apks/solera-obrador-release.apk`). 38 tests. **Release de GitHub sin publicar**: necesita push de `main` antes |

**Siguiente acción**: F1 completa salvo lo humano (BLOQUEOS). Pendientes técnicos menores: hornada de una base o relleno (lotes de subrecetas), selector de fecha en los apuntes y controles (hoy se apuntan con la fecha actual), y facturas cuando el asesor fiscal fije el régimen.

## Encuadre

Panaderías artesanas, obradores caseros, repostería y conservas. Diferencial,
normativa con fuentes y hard limits: **`docs/plan-verticales/obrador.md`** (es la
referencia; no se duplica aquí). Lo esencial que no se toca: la app **no declara
un producto apto** para alérgicos ni celíacos, y la sal y los nutrientes son
**estimaciones**.

## Decisiones tomadas sin consultar

- **2026-11-07 — Un solo registro de autocontrol** (`registros_autocontrol` con
  `tipo`) en vez de las cinco tablas `control_*` de la quesera: el cuaderno
  mensual sale de una consulta y añadir un tipo no exige migración.
- **2026-11-07 — La v1 se amplió en el bloque 2** en lugar de añadir una v2: no
  había ninguna instalación (nada publicado).
- **2026-11-07 — Subrecetas** desplegadas en proporción a los gramos usados
  (`ComposicionReceta`); una receta que se contiene a sí misma es un error.
- **2026-11-07 — Integridad**: no se puede borrar un ingrediente ni un lote en
  uso (`ON DELETE RESTRICT`); borrar una receta se lleva sus líneas.
- **2026-11-07 — Lotes en la hornada**: solo se ofrecen los de los ingredientes *directos* de la receta; los de una base se apuntan al hacer la base (pendiente: hornada de subreceta).
- **2026-11-07 — Alérgenos destacados en MAYÚSCULAS** en la lista de ingredientes de la ficha: la tabla del `informe_periodico` no admite negrita. Comprobar con el técnico si basta.
- **2026-11-07 — IA con el modelo equilibrado** y no el rápido: un error de lectura de alérgenos tiene consecuencias para una persona alérgica.
- **2026-11-07 — Economía mínima**: un solo libro de apuntes (sin terceros como entidad ni facturas) mientras el asesor fiscal no fije el régimen; ingreso por defecto al 4 % (pan común) y gasto al 21 %, editables.
- **2026-11-07 — Importes en céntimos** (como aceitera), no en REAL como la quesera.
- **2026-11-10 — Guía del obrador** (Hoy → icono de libro; Recetas → «Recetas de la guía»; apartado en la Ayuda). 10 recetas base en porcentaje panadero y 41 fichas (fermentación 9, tiempos 6, cocción 7, harinas 6, trucos 13) en `content/obrador/guia_*.csv`, todas con `fuente` y `revisado_por = revision-ia: 2026-11-10` (no es firma: aviso fijo «pendiente de revisión por una persona experta»). **El contenido va solo en castellano en la v1** (la interfaz, en los 4 idiomas: `content/solera/traducciones/obrador_guia.csv`, claves `obra.guia_*`). Decisiones: la guía **no cuenta** para `catalogosCompletamenteRevisados` (tiene su propio aviso); «Copiar a mis recetas» pide peso de harina o de masa, casa los ingredientes por nombre con los del obrador y crea los que falten desde `ingredientes_base.csv` con una nota para revisar la ficha del proveedor; `dominio/guia_obrador.dart` comprueba que ningún nombre prometa una denominación o mención del RD 308/2019 que la receta no cumpla (integral, de centeno, masa madre ≥ 5 % y levadura ≤ 0,2 %, solo ingredientes de pan común, sal estimada) y un test lo pasa por las 10. Sal de las recetas de pan común en 1,6-1,8 % sobre harina para quedar bajo 1,31 g/100 g con la merma estimada. Conservas: solo se remiten a AESAN y al APPCC (test: ninguna cifra). Calculadora de la temperatura del agua en su ficha (× 3, o × 4 con prefermento; King Arthur Baking). Sin fotos en la v1.
- **2026-11-10 — Planificador hacia atrás y avisos** (BD **v2**, paso aditivo: tablas `tiempos_receta` y `planes_hornada`, columna `masas_madre.recordatorio_horas`). «Planificar hornada» desde la ficha de una receta (icono de reloj) y desde cada receta de la guía; el plan en curso sale en Hoy («Hornadas planificadas», siguiente fase y su hora). Lógica pura en `dominio/planificador_hornada.dart` (hacia atrás desde la hora de «listo»; punto medio del rango y se enseña el rango; **precalentar el horno va en paralelo** con la fermentación final; fermentación en nevera de noche como alternativa por fase; marcar una fase hecha mueve las siguientes —salvo el horno—; las fechas son instantes, así que cruzar medianoche o el cambio de hora no altera duraciones). Tiempos de las 10 recetas en `dominio/tiempos_guia.dart` (un test comprueba que los rangos de autólisis, fermentaciones y cocción están escritos en `guia_recetas.csv`; autólisis solo donde la guía la da por «recomendable»; amasado, formado, enfriado y el refresco 4-8 h son **estimaciones de la app**, dicho en pantalla y en la ayuda; si la persona apunta las horas hasta el pico de sus refrescos, se usa su media ±25 %). Recetas propias: la persona pone min/máx por fase (y si va en nevera), guardado en `tiempos_receta` como JSON. **Regla de temperatura** (orientativa, en pantalla): tiempo × 2^((referencia − cocina)/9 °C), solo para fermentaciones a temperatura ambiente, acotada a 16-32 °C con aviso fuera; fuente: Peter Reinhart en el blog de Forno Bravo («How to control when your dough doubles in size», 17 °F ≈ 9 °C); otras fuentes dan 5-8 °C (Weekend Bakery). Avisos con `packages/nuevo_ser_avisos` (canal `obrador_avisos`, inexactos, claves `obrador.plan.<id>.<índice de fase>` y `obrador.masa_madre.<id>`; `servicios/avisos_obrador.dart`, sustituible en tests); sin permiso, todo sigue en pantalla. Masa madre: icono de alarma con «cada 12 h / 24 h / 2 o 3 días / semana», contado desde el último refresco y reprogramado al apuntar uno. Textos `obra.plan_*` en `content/solera/traducciones/obrador_plan.csv` (eu/ca/gl borrador) y `avisos.*` en `avisos.csv`; apartado nuevo en la Ayuda.

## Datos técnicos

- Paquete `solera_obrador`, BD `solera_obrador.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/obrador.csv` (claves `obra.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Recarga entre pestañas: `estado/cambios_datos.dart` (`avisarCambioDatos()` tras guardar).
- **Ojo**: `setState(() => _futuro = cargar())` devuelve el Future y Flutter lo rechaza; usar cuerpo con llaves. Lo cazó el test de pantalla.
- Lógica pura en `lib/dominio/` (sin Flutter, con tests).
- Catálogos: `content/obrador/` → `dart run tool/compilar_catalogos.dart` (también los tres de la guía, con `_compilarGuia`).
