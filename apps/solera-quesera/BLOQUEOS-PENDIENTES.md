# BLOQUEOS-PENDIENTES — Larrea Quesera

Decisiones humanas y verificaciones externas necesarias antes de cada hito. Inspirado en el registro de bloqueos de `solera-viticultura` y `solera-apicola`.

## F1-4 / F1-5 Catálogos curados — validación pendiente

### Quesero asesor

- [ ] Validar los 23 tipos de queso (`tipos_queso.csv`): ¿faltan tipos? ¿los nombres son los habituales en el sector?
- [ ] Validar las 17 razas lecheras (`razas_lecheras.csv`): ¿razas correctas por DO? ¿nomenclatura precisa?
- [ ] Validar las 15 DO (`do_quesos.csv`): cada pliego de condiciones (curación mínima, razas permitidas, zona geográfica). **Revisar BOE de cada DO**.
- [ ] Validar los 18 defectos (`defectos_queso.csv`): ¿terminología correcta? ¿faltan defectos comunes?
- [ ] Validar los 14 parámetros analíticos (`parametros_analitica.csv`): límites legales vigentes conforme RGCE 2073/2005 y AESAN.

### Fuentes públicas a consultar antes de marcar `revisado_por=fuente_pública`

- [ ] BOE de cada DO (pliego de condiciones oficial)
- [ ] MAPA — Registro de Denominaciones de Origen Protegidas
- [ ] AESAN — Límites microbiológicos (RGCE 2073/2005 + modificaciones)
- [ ] Reglamento CE 853/2004 — Normas específicas de higiene para la leche cruda y los productos lácteos

## F1-4 Libro de Trazabilidad PDF — validación pendiente

- [ ] **Formato vigente del libro APPCC**: ¿qué espera ver exactamente un inspector de la CCAA? El PDF generado cubre las 7 secciones pero puede no ajustarse al formato exacto que cada autonomía exige.
- [ ] ¿Hace falta incluir registro de temperaturas de transporte de leche cruda? (CE 853/2004 Anexo III, Sección IX)
- [ ] ¿Es suficiente la simulación de trazabilidad o el inspector quiere verla en un formato específico?
- [ ] **Validar con un inspector real** antes de publicación pública. Backup: el PDF es una herramienta de organización interna; el inspector siempre puede pedir los datos en papel.

## F1-5 Perfiles DO — pendiente de implementación

- [ ] Definir el formato de "perfil DO": ¿JSON embebido en la app o descarga desde backend?
- [ ] Cada DO tiene su propio formato de contraetiqueta numerada; ¿la app gestiona el stock?
- [ ] La trazabilidad genética (AZTI para Idiazabal) ¿se integra como módulo o se omite?

## F1-6 IA Claude Vision — pendiente de implementación

- [ ] Definir el prompt curado quesero: lista canónica de defectos visibles en corte y corteza.
- [ ] Hard limit: la IA NO emite juicio sobre seguridad alimentaria. "Derivar a analítica si hay duda."
- [ ] Necesita fotos de entrenamiento/validación (queso con defectos reales). ¿Cómo se consiguen?

## F1-9 Libro ingresos/gastos — decisión humana

- [ ] **Asesor fiscal humano** antes de quitar provisional. Cuestiones acopladas:
  1. IVA del queso: ¿10% (alimento) o 21% (producto transformado)? Depende de si el quesero vende al por mayor (10%) o con manipulación/enoqueso (21%). Confirmar.
  2. REAGP de IVA con compensación: ¿aplica a la leche producida por el propio quesero? ¿Y a la comprada a terceros?
  3. Régimen de módulos en agricultura/ganadería: ¿el quesero puede estar en módulos por la producción de leche y en estimación directa por la transformación? Probablemente sí.
  4. Ayudas PAC al ovino/caprino de leche: categoría separada del ingreso ordinario.

## F1-10 Branding — decisión humana

- [ ] Logo definitivo: ¿rueda de queso, letra Q estilizada, silueta de oveja Latxa?
- [ ] Paleta de color: dorado queso `#C8923B` + crema leche `#FDF6E8` actuales, ¿se mantienen?
- [ ] `applicationId` final: `com.josu.solera_quesera` actual vs `com.coleccionnuevoser.solera_quesera`.

## Generales (pendientes de planificar)

- [ ] ¿Soporte para otros productos lácteos (yogur,requesón, cuajada, mantequilla) o solo queso?
- [ ] ¿Multi-quesería (varios establecimientos bajo la misma cuenta) en F2?
- [ ] ¿Sincronización con el Consejo Regulador para declaraciones de producción (DO)?
- [ ] ¿Sincronización con el MAPA para el libro de trazabilidad digital oficial?
- [ ] La app se llama "quesera" pero el sector lácteo artesanal incluye yogur, cuajada, requesón. ¿Ampliar a "Larrea Láctea" o mantener el foco en queso?
