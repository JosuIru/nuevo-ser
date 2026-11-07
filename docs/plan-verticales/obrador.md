# V1 — Larrea Obrador · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de la vertical V1 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-obrador/` · `applicationId com.coleccionnuevoser.solera_obrador` · prefijo de commits `solera-obrador:`.

## Para quién

Panaderías artesanas de 1 a 6 personas, obradores caseros y de pequeñas producciones, repostería y pastelería artesana, conservas y mermeladas. El trabajo empieza de madrugada, se hace con las manos manchadas de harina y lo lleva una sola persona que también vende. **Fuera**: industria y franquicias con varios puntos de venta.

## Competencia (consultada el 2026-11-07)

Existe software de recetas, alérgenos y APPCC para obradores: Melba, de unos 49 €/mes según una comparativa ([hackceleration](https://hackceleration.com/es/labs/mejor/software-panaderia)), y ERP grandes como [Aptean](https://www.aptean.com/es-US/industries/food-and-beverage-software/bakery-software). **No hay que competir en las fichas de receta.** El diferencial:

| Diferencial | Base |
|---|---|
| **El cuaderno de autocontrol flexible del obrador pequeño**: los registros justos que piden las guías de prácticas correctas de higiene autonómicas, no un APPCC de fábrica | registros de la quesera (`control_temperatura`, `control_limpieza`, `control_plagas`, `formacion`, `incidencia`) |
| **Móvil, offline y a una mano**: apuntar la temperatura de la cámara o del horno en dos toques | patrón de la suite |
| **Masa madre**: refrescos, proporciones, temperatura, horas hasta el pico, historial | nuevo, lógica pura |
| **Escandallo vivo**: el coste por pieza y por hornada se recalcula al cambiar el precio de la harina | `receta` de la quesera + nuevo |
| **Harina con nombre**: trazabilidad hasta el agricultor o molino (puente con Larrea agro y el pasaporte T1) | `lote_produccion`, T1 |
| **Pedidos fijos** de bares, tiendas y comedores → plan de hornadas del día | T2 venta directa (mientras tanto, en `lib/provisional_core/`) |
| **es/eu/ca/gl** | i18n del core |

## Normativa (verificar el texto vigente antes de cada PDF)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| Reglamento (CE) 852/2004 (higiene) y su flexibilidad para pequeñas empresas | Cuaderno de autocontrol | Guías de referencia: [panadería y pastelería artesanal](https://seguridadycalidadalimentaria.fundacionusal.es/wp-content/uploads/guias/panaderia/16Guia_Higiene_Panaderia.pdf), [APPCC estándar del País Vasco](https://seguridadycalidadalimentaria.fundacionusal.es/wp-content/uploads/guias/ccaa/estandar_appcc_pais_vasco.pdf), [panaderías de Galicia](https://seguridadycalidadalimentaria.fundacionusal.es/wp-content/uploads/guias/ccaa/GPCH_panaderias_galicia.pdf), [obradores de Aragón](https://aragon.es/documents/20127/674325/GUIA+PRACTICAS+OBRADORES.PDF/7579fd55-503f-a24d-213e-9bb598586ec4). **Empezar por la vasca** |
| Reglamento (UE) 1169/2011 (información al consumidor) | 14 alérgenos por receta (heredados de los ingredientes y subrecetas), etiqueta y cartel de alérgenos para el producto sin envasar | Verificar en EUR-Lex |
| [RD 308/2019, norma de calidad del pan](https://www.boe.es/buscar/pdf/2019/BOE-A-2019-6994-consolidado.pdf) | Denominaciones (común, especial, integral, de masa madre…) y **sal** | Límite obligatorio desde el 1-abr-2022: 1,31 g/100 g por determinación de cloruros, 1,66 g si se mide el sodio total ([MAPA](https://www.mapa.gob.es/dam/mapa/contenido/prensa/notas-de-prensa/documentos/documentos-2022/220401normadesalenelpan.pdf)). **Comprobar en el artículo del BOE** cuál aplica. La app **estima** la sal por receta y avisa; **nunca certifica** |
| Reglamento (CE) 178/2002, art. 18 (trazabilidad) | Lote de harina e ingredientes → hornada → cliente | — |
| Registro sanitario (RGSEAA o registro autonómico de pequeñas producciones) | Número de registro en cabeceras y etiquetas | Un campo |
| Verifactu (RD-ley 15/2025) | Obligatorio para autónomos desde el **1-jul-2027** ([infoautonomos](https://www.infoautonomos.com/blog/verifactu-cuando-es-obligatorio-a-quien-afecta/)). La F1 **no** emite facturas Verifactu: deja el ticket y la factura del core con aviso PROVISIONAL y lo apunta en BLOQUEOS | Asesor fiscal |

## Bloques (particularidades sobre el estándar del plan §4)

| Bloque | Contenido específico |
|---|---|
| 2 Modelos | `Obrador` (titular, registro sanitario, CA) · `Ingrediente` (alérgenos, proveedor, precio por kg) · `LoteIngrediente` · `Receta` (con subrecetas, rendimiento, merma de cocción) · `MasaMadre` + `RefrescoMasaMadre` · `Hornada` (receta, lotes usados, piezas, horno, temperatura y tiempo) · `PedidoFijo` · los `control_*` de la quesera adaptados |
| 3 Pantallas | **Hoy** = plan de hornadas + controles pendientes del día + estado de la masa madre · Recetas · Ingredientes · Autocontrol · Ajustes |
| 4 PDF | **Cuaderno de autocontrol** del mes (temperaturas, limpieza, plagas, incidencias, formación) con sello PROVISIONAL |
| 5 PDF | **Ficha técnica de producto** (ingredientes en orden, alérgenos en negrita, sal estimada, lote, consumo preferente) + **cartel de alérgenos** del mostrador + hoja de etiquetas. PROVISIONAL |
| 6 Catálogos | `ingredientes_base.csv` (harinas, levaduras, grasas, azúcares, frutos secos, con sus alérgenos) · `alergenos.csv` (los 14) · `denominaciones_pan.csv` (RD 308/2019) · `controles_tipo.csv` (de la guía vasca) |
| 7 IA | **Leer la etiqueta o la ficha técnica del proveedor** (foto) → ingredientes y alérgenos propuestos. Siempre los **confirma** la persona. Hard limit: nunca da un producto por «sin gluten» ni «apto para…» |
| 9 Economía | **No es REAGP**. Ingresos y gastos con IVA general y reducido, y estimación objetiva o directa como opción. **Todo PROVISIONAL** |
| Branding | Propuesta: **tostado de corteza `#8A5A2B` + crema `#F5EFE2`**, acento trigo `#D4A84B` |

## Hard limits

1. La app **no declara un producto apto para alérgicos ni celíacos**. Muestra lo que lleva, lo que puede contener (contaminación cruzada declarada por la persona) y nada más.
2. La sal y los valores nutricionales son **estimaciones**. Solo valen como dato legal los de un laboratorio.
3. No sustituye la inspección sanitaria ni el registro: lo dice en la pantalla y en cada PDF.
4. Los datos son del obrador: exportación completa a CSV siempre disponible.

## Bloqueos humanos previstos (para `BLOQUEOS-PENDIENTES.md`)

Técnico de seguridad alimentaria (formato del autocontrol y del cartel de alérgenos) · asesor fiscal (régimen y Verifactu) · 2-3 obradores piloto (una panadería de masa madre, una pastelería, una conservera) · revisión nativa eu/ca/gl.
