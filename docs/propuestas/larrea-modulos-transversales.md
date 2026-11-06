# Larrea — módulos transversales (propuesta)

> **Estado**: propuesta, 2026-11-06. Sin aprobar.
> **Idea**: en vez de sumar verticales, construir **piezas que sirvan a todas a la vez** (agro, viticultura, apícola, arbolado, quesera, aceitera, ganadera futura y Zunbeltz). Cada módulo vive en `nuevo_ser_core` (cliente) y, si necesita servidor, en un plugin WP propio por cliente, como `solera-zunbeltz-sync`.

## Mapa rápido

| # | Módulo | Valor | Coste | Depende de | Recomendación |
|---|---|---|---|---|---|
| 1 | **Pasaporte del producto** (QR al consumidor) | ★★★ comercial | Medio | lotes en cada vertical, hosting público | **Primero** |
| 2 | **Venta directa unificada** | ★★★ ingresos del cliente | Medio | facturación del core (ya existe) | Segundo, junto al 1 |
| 3 | **Biodiversidad en la finca / eco-regímenes** | ★★ PAC + identidad Colección | Medio | motor de observaciones de *Naturaleza* | Tercero |
| 4 | **Maquinaria compartida (tipo CUMA)** | ★★ comunidad | Bajo-medio | sync multi-usuario (Zunbeltz) | Cuando haya un colectivo piloto |
| 5 | **Exportador SIEX / cuaderno digital** | ★★ defensivo | Medio-alto | definición oficial del formato | Vigilar; diseñar ya los modelos |
| 6 | **BD compartida `BaseDatosSolera`** | ★ interno | Medio | tests CRUD | Prerrequisito técnico (deuda R5) |

---

## 1. Pasaporte del producto

**Qué es**: un QR en la etiqueta (botella, tarro, queso, lata de aceite, pieza de cordero) que abre una **página pública** con la historia de ese lote: finca o colmenar de origen, fechas clave, prácticas (ecológico, DOP…), quién lo hace y cómo comprar más. La genera la app a partir de lo que **el productor ya registra para cumplir la normativa**: trabajo cero extra, que es justo el argumento de venta.

**Por qué es el primero**:
- Da valor comercial **visible** a 6-7 apps con un solo desarrollo. Convierte el «cuaderno obligatorio» en «marketing gratis».
- Encaja con el tono de la Colección: transparencia y circuito corto frente a la etiqueta opaca.
- Cada QR escaneado es un consumidor que ve «hecho con Larrea»: canal de adquisición.

**Qué ya existe**:
- Lotes con trazabilidad en quesera (`lote_produccion`, `simulacion_trazabilidad`), aceitera (libro de movimientos del aceite), viticultura, apícola (extracciones) y ganadera (movimientos y salidas a matadero).
- Generación de QR en arbolado urbano (chapa QR) y escáner en Zunbeltz.
- PDF y fotos en el core.

**Diseño propuesto**:
- **Modelo común** `PasaporteLote` en el core: `uid`, vertical, producto, fechas, origen (geometría reducida: **municipio o comarca, nunca coordenadas exactas** por defecto), hitos (lista de `{fecha, tipo, texto}` que rellena cada vertical con un *adapter*), sellos (ECO, DOP… **solo si el productor marca que los tiene**), fotos elegidas y contacto/venta.
- **El productor decide qué se publica**: vista previa obligatoria antes de publicar; nada sale sin pasar por ahí. Por defecto se publica lo mínimo.
- **URL estable** con formato compatible con [GS1 Digital Link](https://www.gs1.org/standards/gs1-digital-link) (`/01/<GTIN>/10/<lote>`) si el productor tiene GTIN, y `/p/<uid>` si no. Así el mismo QR podrá servir a la caja del súper si algún día lo necesita.
- **Hosting**: página estática generada por la app y subida a un endpoint (`POST /pasaporte`) del plugin WP Larrea, o servicio central Larrea. Esto **hay que decidirlo** (ver bloqueos). La página funciona sin JS y pesa poco (se abre en una feria con mala cobertura).
- **Etiqueta**: PDF de hoja de pegatinas con QR + lote + fecha, en los formatos de etiquetadora habituales (A4 de 21/24/65 por hoja, más rollo 50×30 en F2).

**Límites**:
- No es la etiqueta legal (Reglamento (UE) 1169/2011): **complementa**, no sustituye. Lo dice el PDF.
- No afirma lo que la app no puede saber: «ecológico» solo si el productor declara su certificado (código del operador). Nada de «sostenible» ni «km 0» automáticos.
- La trazabilidad legal (Reglamento (CE) 178/2002, art. 18: un paso atrás y un paso adelante) la cubre ya cada vertical. El pasaporte es la cara pública.

**Bloques**: TP-1 modelo + adapters (quesera y aceitera primero, que tienen lotes más maduros) · TP-2 generador de la página estática + vista previa · TP-3 endpoint de publicación + plugin · TP-4 etiquetas PDF · TP-5 estadística de escaneos (solo cuántos, sin rastrear a nadie).

---

## 2. Venta directa unificada

**Qué es**: clientes, pedidos, repartos y cobros para quien vende en la finca, en ferias, a grupos de consumo o a restaurantes. Sale de la factura del core (`facturacion/factura.dart`, ya común a 5 verticales) hacia arriba.

**Piezas**:
- **Catálogo propio** del productor (producto, formato, precio, IVA) **enlazado a lotes**: al vender se sabe qué lote salió, y se cierra la trazabilidad «un paso adelante» sin teclear dos veces.
- **Pedidos**: estado (pedido → preparado → entregado → cobrado), fecha y punto de entrega.
- **Rutas de reparto**: los pedidos de un día ordenados por zona, con hoja de reparto PDF. Sin optimización de ruta en F1.
- **Grupos de consumo / cestas**: suscripción periódica (semanal, quincenal) que genera los pedidos sola.
- **Modo feria**: venta rápida offline con importe, forma de pago (efectivo, Bizum apuntado a mano) y ticket simplificado.
- **Informe**: ventas por producto, canal y cliente. Alimenta el libro de ingresos REAGP de cada vertical.

**Normativa a vigilar**: RD 1086/2020 (flexibilización de higiene para la venta directa de pequeñas producciones) y la normativa autonómica de venta de proximidad. Factura simplificada y ticket según el RD 1619/2012 (ya cubierto en el core). **Verifactu**: ver si el cliente queda obligado según su régimen; el REAGP suele quedar fuera, pero **lo confirma el asesor fiscal** (bloqueo común).

**Fuera**: tienda online con pasarela de pago (F2 como mucho, y con un tercero: no queremos tocar pagos).

---

## 3. Biodiversidad en la finca / eco-regímenes

**Qué es**: registrar en el mapa de la finca los **elementos de biodiversidad** (setos, márgenes, charcas, islas de vegetación, cubiertas, cajas nido, hoteles de insectos, árboles aislados) y las **observaciones** de fauna auxiliar y polinizadores. Con eso se justifican prácticas de los eco-regímenes de la PAC y se prepara la certificación.

**Por qué**:
- **Puente natural con los cuadernos de campo**: el motor de observaciones de *Naturaleza* (especie, foto, punto, fecha, IA de identificación) se reutiliza tal cual dentro de Larrea. Es el primer caso real de aprovechar el código de los cuadernos en el producto comercial.
- Es la cara más «Colección Nuevo Ser» de Larrea: la finca como ecosistema, no como fábrica.
- Pagos PAC: los eco-regímenes son voluntarios y se renuevan cada año, y «espacios de biodiversidad», cubiertas y pastoreo extensivo pagan por encima de la línea base.

**Piezas**: capa de elementos en el mapa (polígono, línea o punto, con superficie y longitud calculadas: `geodesia.dart` de Zunbeltz) · checklist por eco-régimen y campaña · observaciones con la ficha de *Naturaleza* · informe PDF por campaña · en F2, conteos estandarizados (transecto de polinizadores en el formato de los programas de ciencia ciudadana, para que el dato sirva fuera).

**Riesgo**: los requisitos cambian cada campaña y por CA. **El checklist se carga desde catálogo** (CSV compilado, como el resto de la suite) y lleva el sello PROVISIONAL hasta que lo revise un técnico PAC. Nada de «cumples el eco-régimen»: como mucho, «tienes registrado esto».

---

## 4. Maquinaria compartida (tipo CUMA)

**Qué es**: reservas, horas de uso y reparto de costes de maquinaria o instalaciones compartidas (CUMA, cooperativa, comunidad de vecinos con una trilladora, la manga de manejo de un espacio test, la sala de extracción de miel o la quesería compartida).

**Piezas**: inventario de equipos · calendario de reservas con conflictos · parte de uso (horas o hectáreas, gasoil, incidencias) · mantenimiento (las **tareas recurrentes de Zunbeltz** encajan tal cual) · liquidación periódica por socio en PDF.

**Base**: sincronización multi-usuario con roles y panel WP de Zunbeltz. Es el segundo caso de uso de esa infraestructura y la justifica como producto.

**Cuándo**: solo con un colectivo piloto real. Sin él es fácil diseñar mal el reparto de costes, que en cada CUMA es distinto.

---

## 5. Exportador SIEX / cuaderno digital de explotación

**Contexto**: el RD 1054/2022 crea el SIEX y el cuaderno digital. Hoy es **voluntario** en general y las fechas de obligatoriedad están en discusión (fitosanitarios en 2027 por el retraso del Reglamento de Ejecución (UE) 2023/564; obligatoriedad completa en 2027-2028 según la fuente). Las CCAA recomiendan usarlo ya.

**Propuesta**: no construir todavía la integración (el formato de intercambio aún se mueve), pero **sí, ya**:
- revisar que los modelos de tratamientos, fertilización y cosecha de cada vertical guardan **todos los campos** que pide el CUE, aunque no se enseñen;
- tener un exportador intermedio propio (JSON/CSV) del que salga luego el formato oficial.

**Por qué importa**: cuando sea obligatorio, «Larrea exporta al SIEX» será **condición para seguir en el mercado**. Llegar tarde aquí es perder clientes.

---

## 6. Prerrequisito técnico: `BaseDatosSolera`

Los módulos 1-5 tocan la BD de 6-7 apps. Con el patrón actual (5 `base_datos.dart` copiados a mano, deuda **R5** de `docs/auditoria-2026-05-12.md`) cada módulo multiplica el trabajo y el riesgo. **Hacer el refactor R5 antes o junto al pasaporte**: clase base en `nuevo_ser_core/src/datos/` y que cada vertical aporte solo su esquema y sus migraciones. El bloqueo conocido (faltan tests CRUD que cubran el contrato) se ataca escribiendo esos tests primero, vertical por vertical.

---

## Orden recomendado

1. **R5 + tests CRUD** (base para todo lo demás).
2. **Pasaporte del producto** en quesera y aceitera (TP-1 a TP-4).
3. **Venta directa** enlazada a lotes y pasaporte (comparten catálogo de producto).
4. **Biodiversidad** reutilizando *Naturaleza*, junto con la F1 de Larrea Ganadera (comparten mapa de pastos y recintos SIGPAC).
5. **SIEX**: revisión de campos ya; el exportador cuando se publique el formato definitivo.
6. **CUMA** cuando aparezca el piloto.

## Bloqueos y decisiones abiertas

1. **Hosting del pasaporte**: ¿servidor central Larrea (lo gestiona Josu, como el de Zunbeltz) o plugin WP en la web de cada productor? Recomendación: central, con dominio propio y página estática. Lo segundo exige que cada productor tenga WordPress.
2. **Modelo de cobro**: ¿el pasaporte entra en la licencia o es un extra? Ojo: si es central, tiene coste de servidor recurrente.
3. **Protección de datos**: el pasaporte publica nombre y ubicación aproximada del productor, así que hace falta consentimiento explícito y la posibilidad de despublicar. Revisar con asesoría RGPD.
4. **Asesor fiscal** (común): venta directa, Verifactu y REAGP.
5. **Técnico PAC**: checklist de eco-regímenes por campaña y CA.

---

Fuentes consultadas el 2026-11-06:
- [GS1 Digital Link](https://www.gs1.org/standards/gs1-digital-link)
- [Eco-regímenes PAC 2026 (Aragón)](https://www.aragon.es/pac-2026/eco-regimenes) · [presentación eco-regímenes 2026 (Castilla-La Mancha)](https://apliagri.castillalamancha.es/sites/default/files/2026-02/PRESENTACIÓN_Ecorregímenes_2026_smd.pdf)
- [Cuaderno digital y voluntariedad (Interempresas)](https://www.interempresas.net/Grandes-cultivos/610490-Cuaderno-Digital-de-Explotacion-en-Espana-(CUE)-mucho-mas-que-un-'excel'-obligatorio.html) · [SIEX (Banco Santander)](https://www.bancosantander.es/blog/pymes-negocios/siex) · [desarrollo del SIEX (MAPA)](https://www.mapa.gob.es/en/prensa/ultimas-noticias/detalle_noticias/el-ministerio-de-agricultura--pesca-y-alimentacion-desarrolla-los-principales-elementos-del-sistema-de-informacion-de-explotaciones-agricolas-y-ganaderas--siex---/0e801a7a-1b6d-4d0b-9621-4225440e225a)
- Los RD 1086/2020 y 1619/2012 y los Reglamentos 1169/2011 y 178/2002 se citan de memoria: **verificar el texto vigente en el BOE/EUR-Lex** antes de usarlos en un PDF.
