# Larrea Ganadera — ficha de proyecto (propuesta)

> **Estado**: propuesta, 2026-11-06. Sin aprobar. No hay código propio todavía.
> **Hallazgo que cambia la ficha**: el ~70 % de la F1 **ya existe** dentro de `apps/solera-zunbeltz/` (FZ-4: rebaños, animales con crotal y escáner del DIB, movimientos entre piezas, eventos de manejo, supresión, ecológico, UGM, libro de explotación y hoja de movimiento en PDF, import/export Excel). Larrea Ganadera **no se construye desde cero**: se **extrae** la Capa A de Zunbeltz a una vertical autónoma. Es justo la opción que recomendaba `apps/solera-zunbeltz/BLOQUEOS-PENDIENTES.md` §A punto 2 («vertical ganadera autónoma + módulo ETA encima»).

## 1. Para quién

- **Ganadería extensiva pequeña y mixta**: 20-400 cabezas de ovino, caprino, vacuno de carne o porcino extensivo, a menudo **varias especies a la vez** y con pastos repartidos en muchas piezas, comunales o arrendados.
- Perfil: explotación familiar, incorporación reciente (jóvenes, personas que vienen de un espacio test como Zunbeltz) y ecológico o en conversión.
- **Fuera de alcance**: intensivo (porcino o avícola industrial), leche de vacuno con robot de ordeño o integradoras. Ese mercado ya tiene software caro y bien asentado.

## 2. El problema y la competencia (decirlo de frente)

Ya hay cuadernos de vacuno baratos y buenos: VacApp desde 4 €/mes, offline y multiplataforma (comprobado el 2026-10-06, BLOQUEOS Zunbeltz §G 26). **Competir en «llevar el censo» no tiene sentido.** El diferencial tiene que estar en lo que no hacen:

| Diferencial | Por qué importa | Base existente |
|---|---|---|
| **El pasto como centro**, no el animal: dónde está cada rebaño, carga UGM/ha por pieza y días de pastoreo | El ovino y caprino extensivo se maneja por rebaños y por piezas, no animal a animal | `zonaActualDeLote`, `carga_ganadera.dart`, `PlanoPieza` |
| **Justificar el eco-régimen de pastoreo extensivo de la PAC** con los movimientos reales | Es el eco-régimen con más superficie de España (~6,4 M ha en 2024, informe FEGA). Exige carga mínima (0,1 UGM/ha en pasto mediterráneo, 0,2 en húmedo, campaña 2026) y periodo de pastoreo. Hoy se justifica en papel o de memoria | movimientos + UGM + recintos SIGPAC (`recinto_sigpac.dart`) |
| **Multiespecie y ecológico de serie**: plazo doble de supresión y límite anual de tratamientos | VacApp es de vacuno; el pequeño extensivo mezcla especies | `ganado_ecologico.dart` |
| **Las 4 cooficiales** (es/eu/ca/gl) y offline total en el monte | Público rural del norte peninsular | i18n del core |
| **Puente a la venta directa** (cordero, cabrito, ternera en canal o por piezas) con trazabilidad al consumidor | Es el margen real de la explotación pequeña | módulos transversales (ver `larrea-modulos-transversales.md`) |

## 3. Normativa que digitaliza (a validar por veterinario asesor)

| Norma | Qué cubre la app | Estado |
|---|---|---|
| **RD 787/2023** (trazabilidad, identificación y registro; en vigor desde el 02/01/2024, modificado en dic-2024). Sustituye al RD 685/2013 (ovino-caprino) y al RD 205/1996 | Capítulo 5, **libro de registro de explotación**: entradas, salidas, censo. Capítulo 4, **documentos que acompañan al movimiento** | Generador PDF provisional en Zunbeltz; **falta cotejar con el anexo vigente** |
| **RD 479/2004** (REGA) | Código REGA de la explotación en cabeceras y PDF | Trivial |
| **RD 666/2023** (medicamentos veterinarios), art. 41 | **Registro de tratamientos y visitas veterinarias**. Apuntar lo que pone la receta, nunca recomendar | Hecho en Zunbeltz con este *hard limit*. La norma está en revisión (proyecto de modificación en audiencia): vigilar |
| **SITRAN** | La app **no** comunica movimientos a SITRAN (lo hace la OCA o el ganadero en la sede de su CA). Prepara los datos para teclearlos o exportarlos | Decisión: no integrar en F1 |
| **Reglamento ecológico (UE) 2018/848** | Plazo doble de supresión (mínimo 48 h) y límite de tratamientos alopáticos | Hecho en Zunbeltz |
| **Eco-régimen de pastoreo extensivo (PEPAC)** | Informe por recinto: días de pastoreo, UGM/ha media y mínima | **Nuevo**, diferencial de la F1 |
| **SIEX / cuaderno digital (RD 1054/2022)** | Voluntario en general hasta 2027, con fechas en discusión (2027-2028). La parte ganadera del CUE está menos definida que la agrícola | Vigilar; diseñar el modelo para poder exportar |

Cada comunidad autónoma puede añadir su formato de libro (decretos forales en Navarra, Euskadi…), así que **la F1 sale con el sello PROVISIONAL** en todos los PDF, igual que en el resto de la suite.

## 4. Alcance de la F1 (propuesta por bloques)

Formato de bloque igual que en el resto de verticales (`F1G-n`):

| Bloque | Contenido | Origen |
|---|---|---|
| **F1G-1** | Esqueleto Flutter+Melos `apps/solera-ganadera/`, i18n es/eu/ca/gl, branding (propuesta: **pardo-lana + crema**, acento rojo de marcaje `#B8402A` heredado) | nuevo |
| **F1G-2** | **Extraer el dominio de ganado** de Zunbeltz a `nuevo_ser_core/src/ganado/` (o paquete `larrea_ganado`): `LoteGanado`, `Animal`, `MovimientoGanado`, `EventoGanado`, `carga_ganadera`, `ganado_ecologico`, `crotal`, `historial_animal`, `importar_animales`. Zunbeltz pasa a depender del paquete. **Tests de Zunbeltz verdes sin tocar = criterio de cierre** | extracción |
| **F1G-3** | Modelo de **explotación** (REGA, titular, especies autorizadas) y **piezas de pasto** con contorno, recinto SIGPAC, tipo de pasto (mediterráneo/húmedo) y titularidad (propio / arrendado / comunal) | nuevo + `zona_finca` |
| **F1G-4** | BD sqflite v1 con migraciones aditivas (patrón de la suite; **no** el modelo sincronizable de Zunbeltz en F1) | patrón |
| **F1G-5** | Pantallas: Hoy · Rebaños · Mapa de pastos · Animales · Manejo. Reutilizar `ganado_visual.dart`, `formularios_ganado.dart` y el escáner del DIB | extracción |
| **F1G-6** | **Libro de explotación** y **documento de movimiento** en PDF, cotejados con el RD 787/2023 consolidado | extracción + revisión |
| **F1G-7** | **Informe del eco-régimen de pastoreo**: por recinto y campaña, los días con ganado, UGM/ha media, mínima y máxima, y alerta de «por debajo de la carga mínima». Lógica pura con test | **nuevo, diferencial** |
| **F1G-8** | **Calendario sanitario**: saneamientos, desparasitaciones planificadas por el veterinario y vencimiento de supresiones como avisos locales | nuevo (avisos del core) |
| **F1G-9** | Economía REAGP ganadera (ventas de corderos y terneros, piensos, veterinario) + facturas (`facturacion/` del core) | patrón suite, **PROVISIONAL** fiscal |
| **F1G-10** | Target Android `com.coleccionnuevoser.solera_ganadera`, APK release y releases como el resto | patrón |

**Fuera de la F1**: sincronización multi-dispositivo (la de Zunbeltz se podrá ofrecer como F2), pesos y GMD con básculas Bluetooth, lectura de bolos y crotales electrónicos RFID (lectores de bastón por Bluetooth, F2: el bovino electrónico se vuelve obligatorio), IA visual (cojeras y condición corporal, F3 y con mucha cautela), cercado virtual o collares GPS.

## 5. Hard limits (heredados y nuevos)

1. **La app no recomienda medicamentos, dosis ni diagnósticos.** Apunta la receta y avisa de los plazos. Los catálogos llevan sustancias activas, nunca marcas.
2. **No sustituye las comunicaciones oficiales** (SITRAN, OCA, PRESVET). Lo dice en pantalla y en el PDF.
3. **El informe del eco-régimen es de ayuda, no una declaración.** Manda la tabla UGM del trámite (los coeficientes de Zunbeltz son de la Junta de Andalucía; la PAC usa las suyas, así que hay que llevar **tablas UGM por trámite**).
4. Los datos son del ganadero: export completo CSV/Excel siempre disponible.

## 6. Relación con Zunbeltz

- Zunbeltz queda como **Larrea Ganadera + capa ETA** (proyectos de test, convenio, rentabilidad por tester, panel WP). La deuda que nace con la extracción es buena: hoy el ganado está acoplado a `PoliticaEspacio` y a la sincronización. Para extraerlo hay que separar **dominio** (puro) de **permisos/sync** (de Zunbeltz).
- **Riesgo**: tocar Zunbeltz en plena entrega (publicación el 31-oct ya pasada; uso real empezando). Mitigación: la extracción se hace con la suite de tests de Zunbeltz como red, en rama, y se publica en Zunbeltz solo cuando la ganadera ya esté estable.
- **Oportunidad comercial**: cada persona que termina un test en Zunbeltz y se instala por su cuenta es usuaria natural de Larrea Ganadera, **con su histórico**. Exportar de Zunbeltz e importar en Ganadera debería ser un botón.

## 7. Bloqueos humanos (antes de retirar sellos)

1. **Veterinario asesor**: formato del libro y del documento de movimiento según el RD 787/2023 vigente y las variantes autonómicas (Navarra primero); catálogos de especies, razas y sustancias activas.
2. **Técnico PAC / OCA**: lectura correcta del eco-régimen de pastoreo de la campaña 2026 (RD 916/2025 según la presentación de Castilla-La Mancha; **verificar en BOE**), tabla UGM aplicable y cómo cuentan comunales y pastos arrendados.
3. **Asesor fiscal**: REAGP ganadero (bloqueo común de la suite).
4. **Ganaderos piloto** (2-3, mejor fuera de Zunbeltz para no sesgar): ovino de leche, caprino y vacuno de carne.
5. **Revisión nativa** eu/ca/gl de la terminología ganadera (larre-saila, askatokia…).

## 8. Estimación orientativa

Por ser extracción, la F1 completa son **~3-4 semanas** de trabajo efectivo, frente a las ~6-8 de una vertical desde cero. El bloque caro es F1G-2 (extraer sin romper Zunbeltz). F1G-7 (eco-régimen) es pequeño en código pero depende del bloqueo 2.

## 9. Siguiente paso propuesto

Antes de crear la app: **spike de F1G-2** en rama. Mover `modelos/ganado*.dart` + `carga_ganadera.dart` + `crotal.dart` a un paquete y ver cuánto se arrastra (sobre todo `constantes.dart`, `PoliticaEspacio` y los catálogos generados para PHP). Ese spike dice si la estimación se sostiene.

---

Fuentes consultadas el 2026-11-06:
- [RD 787/2023 consolidado (BOE)](https://www.boe.es/eli/es/rd/2023/10/17/787/con/20241224) · [modificación dic-2024 (BOE-A-2024-26927)](https://boe.es/boe/dias/2024/12/24/pdfs/BOE-A-2024-26927.pdf)
- [RD 685/2013, derogado (BOE)](https://www.boe.es/eli/es/rd/2013/09/16/685/con/20231103)
- [SITRAN (MAPA)](https://www.mapa.gob.es/es/ganaderia/temas/trazabilidad-animal/sitran)
- [RD 666/2023 consolidado (BOE)](https://www.boe.es/buscar/pdf/2023/BOE-A-2023-16727-consolidado.pdf) · [protestas y proyecto de modificación (Abogacía)](https://www.abogacia.es/publicaciones/blogs/blog-de-derecho-de-los-animales/veterinarios-en-pie-de-guerra-el-impacto-del-real-decreto-666-2023/)
- [Eco-regímenes 2026 (Castilla-La Mancha)](https://apliagri.castillalamancha.es/sites/default/files/2026-02/PRESENTACIÓN_Ecorregímenes_2026_smd.pdf) · [informe FEGA sobre la superficie de pastoreo extensivo (Agronews CyL)](https://www.agronewscastillayleon.com/?p=202038) · [eco-regímenes PAC 2026 (Aragón)](https://www.aragon.es/pac-2026/eco-regimenes)
- [Voluntariedad del cuaderno digital (Interempresas)](https://www.interempresas.net/Grandes-cultivos/610490-Cuaderno-Digital-de-Explotacion-en-Espana-(CUE)-mucho-mas-que-un-'excel'-obligatorio.html) · [SIEX (Banco Santander)](https://www.bancosantander.es/blog/pymes-negocios/siex)
