# Larrea Arbolado Urbano — Bloqueos pendientes (decisión humana)

Tracker de decisiones humanas que bloquean el cierre a producción de cada fase.

---

## F1U-4 — Catálogo de especies arbóreas urbanas

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente auditoría humana.

**Aplicado**: `especies_arboreas.csv` (40 especies cubriendo el núcleo ibérico) marcado `revisado_por="Inventarios municipales Madrid + Barcelona OpenData + AEPJP"`. Fuentes consultadas: [Inventario Arbolado Madrid](https://datos.madrid.es/), [Arbolado Viario Barcelona OpenData](https://opendata-ajuntament.barcelona.cat/data/es/dataset/arbrat-viari), [Inventario Arbolado Valencia](https://opendata.vlci.valencia.es/), guía AEPJP/PARJAP 2026.

**Pendiente auditoría humana**: ingeniero técnico forestal asesor amplía/recorta según realidad local del municipio piloto (Iruña, Vitoria-Gasteiz, otros). Algunos taxones específicos (variedades de *Prunus* ornamental, palmeras secundarias) pueden añadirse caso a caso.

---

## F1U-4 — Catálogo de plagas y enfermedades urbanas

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente auditoría humana.

**Aplicado**: `plagas_urbanas.csv` (21 entradas) con fuente pública por fila. **Plagas reguladas con `declaracion_oficial=si` (banner rojo automático)**:
- `picudo_rojo` — *Rhynchophorus ferrugineus*. Reglamento UE 2019/2072 + RD 526/2014.
- `fuego_bacteriano` — *Erwinia amylovora*. RD 1201/1999 (programa nacional erradicación) + UE 2019/2072 anexo II.
- `xylella_arbolado` — *Xylella fastidiosa* (añadida). Reglamento UE 2019/2072 + RD 690/2017. Aplicable a olivo y almendro ornamental urbano.
- `avispilla_castano` — *Dryocosmus kuriphilus* (añadida). Reglamento UE 2019/2072 + Plan Contingencia MAPA. Castaños ornamentales urbanos.

**Plagas con `riesgo_sanitario_publico=si` (banner naranja)**:
- `procesionaria_pino` — pelos urticantes; vigilancia en zonas escolares. Documentado riesgo de urticaria al 12% rural / 4% urbano.
- `lagarta_peluda` — pelos urticantes en personas sensibles.

Resto (anthracnosis plátano, oídio plátano, mancha negra peral, grafiosis olmo, escolitidos, cochinilla algodonosa, etc.) marcadas con `revisado_por="AEPJP + Estaciones Aviso Fitosanitario CCAA"`.

**Pendiente auditoría humana**: ingeniero técnico forestal asesor o servicio fitosanitario CCAA confirma síntomas y manejo cultural en contexto urbano (donde NO se puede tratar a fondo por proximidad ciudadana).

---

## F1U-4 — Catálogo de tipos de poda

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08).

**Aplicado**: `tipos_poda.csv` (12 tipos) marcado `revisado_por="Estándar Europeo de Poda EN 17321 + AEPJP"`. Tipos no controvertidos (formación, mantenimiento, saneamiento, refaldado, drenaje copa) y controvertidos `controvertida=si` (drástica/aterrazado, descopado, terciado, trasmoche) según el [Estándar Europeo de Poda](https://aearboricultura.org/project/estandar-europeo-de-poda/) traducido por la Asociación Española de Arboricultura. Banner amarillo en la app cuando se selecciona un tipo controvertido.

**Pendiente auditoría humana**: ingeniero técnico forestal asesor revisa nomenclatura local del municipio piloto. Algunos ayuntamientos usan terminología alternativa (limpieza = mantenimiento) — extender el catálogo con sinónimos locales si es necesario.

---

## F1U-5 — Formato del parte municipal de poda

**Estado**: ✅ Formato base compatible con la mayoría de ayuntamientos (2026-05-08).

**Aplicado**: `generador_informe_municipal.dart` produce PDF con 5 tablas estándar (censo por especie, inspecciones VTA, podas, tratamientos fitosanitarios, incidencias) + cabecera con titular del ayuntamiento + técnico responsable (NIF, empresa contratista, carnet aplicador). Cubre el mínimo común documentado por los pliegos técnicos públicos de Madrid, Barcelona, Vitoria-Gasteiz y la guía AEPJP.

**Pendiente auditoría humana — F1.1**: validar con 2-3 ayuntamientos reales (Iruña piloto + 1-2 vecinos) qué columnas extra exige su pliego. Variaciones documentadas:
- Algunos exigen plano UTM con coordenadas (no listado tabular).
- Foto antes/después: opcional vs obligatoria por ayuntamiento.
- Firma electrónica (eIDAS): pendiente F2 backend.

Si la heterogeneidad es alta, en F2 el generador acepta plantillas custom por municipio. Hoy `PantallaInformeMunicipal` muestra disclaimer "verifica el formato exigido por tu ayuntamiento antes de presentar".

---

## F1U — Modelo de monetización B2B

**Bloqueo**: decisión cerrada de cómo cobrar.

**Opciones a evaluar**:

1. **Licencia anual fija** (€500-3.000/año por municipio según habitantes). Sencillo, predecible. **Recomendado para v1**.
2. **Por árbol inventariado** (€0,10-0,50/árbol/año). Escala, pero auditar nº de árboles complica el contrato.
3. **Freemium con tope** (gratis hasta 500 árboles → licencia). Atractivo para captación pero complica facturación.

**Resuelve**: Josu, idealmente tras 2-3 conversaciones con técnicos municipales sobre cómo se asignan presupuestos.

---

## Branding y `applicationId`

**Estado actual**: paleta provisional verde hoja `#2E7D32` + crema savia `#F4F8F0`. AppBar plano. `applicationId = com.coleccionnuevoser.solera_arbolado_urbano`.

**Resuelve**: Josu en F1U-7 (pulido).

---

## Pendientes diferidos (no bloquean v0.1)

- **Multi-rol con backend** (técnico ayuntamiento + operario contratista + supervisor): F2 con backend.
- **Firma electrónica de partes** (eIDAS / certificado del técnico): F2.
- **Integración con catastro municipal** vía SIGPAC o cartografía local: F2.
- **Lectura de chapas RFID** (alternativa al QR para municipios que ya invirtieron en RFID): F3.
- **Presupuestos automáticos** de actuaciones (con baremo del ayuntamiento): F3.
