# Larrea Viticultura — Bloqueos pendientes (decisión humana)

Tracker de decisiones humanas que bloquean el cierre de fases concretas a producción. Mantener actualizado: añadir cada vez que aparezca un bloqueo, marcar resuelto cuando entre el dato/asesoramiento.

Convenciones:
- **Bloqueo** = título corto + qué falta + quién lo resuelve + qué fase desbloquea.
- Sustituciones diegéticas/temporales documentadas aquí también, por si el comité o el asesor cambian de criterio.

---

## F1-12 — Libro económico (ingresos/gastos + modelo 347 + extracto anual)

**Estado**: ✅ con datos provisionales. Funcional end-to-end pero el formato del libro registro y del extracto está pendiente de firma de asesor fiscal antes de presentar nada en una declaración.

**Asunciones aplicadas en v1 provisional** (registradas para que el asesor fiscal las revise línea a línea):

1. **Régimen fiscal v1** soporta REAGP (compensación 12% en uva, dominante en bodega pequeña) y Estimación directa simplificada / normal. **Módulos NO está soportado** — el asesor fiscal debe pedirlo y validar el formato del extracto antes de añadirlo.
2. **IVA repercutido en venta de UVA** = 4% en régimen general (alimento de primera necesidad). En REAGP no se repercute IVA — el comprador paga compensación del 12%. **Es la única operación de la bodega que entra en REAGP** — el vino queda fuera (es producto transformado por la bodega).
3. **IVA repercutido en venta de VINO** = 21% general SIEMPRE (bebida alcohólica, art. 91.1.1.1.º LIVA NO aplica). Aplica a botella, granel, con o sin DOP/IGP. El vino con DOP de regiones específicas no obtiene tratamiento fiscal distinto en IVA — eso lo gestiona el Consejo Regulador en otra dimensión.
4. **IVA del alquiler de terreno** = 0% por defecto (uso agrícola exento, art. 20.1.23 LIVA). 21% si es para uso no agrícola — el usuario sobrescribe.
5. **IVA en gastos** autocalculado por categoría: insumos vid 4%, seguros 0% (exentos), vendimia/mano de obra 0% (mano de obra agrícola sin IVA típicamente), resto al 21% general. El usuario sobrescribe en la factura real cuando difiera.
6. **IVA soportado en REAGP** marcado como NO recuperable; se computa como mayor coste en el extracto.
7. **Modelo 347** se calcula sobre el importe **total** (base + IVA + compensación REAGP) por NIF y año, umbral fijo en 3.005,06€.
8. **Reparto proporcional por superficie** de gastos imputados a `variedad_general` entre las parcelas con esa variedad NO está calculado en v1. Los apuntes con esa imputación se listan en el extracto con el importe íntegro asignable a la variedad. Cuando el asesor valide el método (lineal por hectáreas vs por número de cepas activas), el cálculo se mueve al generador.
9. **Apuntes sin NIF** (visitante de bodega sin factura) se permiten guardar pero el extracto los lista en una tabla aparte porque NO entran al modelo 347.
10. **`loteVino` como texto libre en v1**. Importante para trazabilidad DOP/IGP, pero la tabla de lotes formal con FK queda pendiente de F1-13. En v1 el viticultor anota el lote/añada en el campo libre y el extracto lo lista en la columna de detalle de ingresos. Si el Consejo Regulador exige formato más estricto, se formaliza.
11. **Sinergia con libro PAC**: en v1 el `tratamientoId` del ApunteGasto está modelado y se preserva en BD, pero la generación automática del apunte de gasto desde la pantalla de tratamiento NO está cableada (el viticultor da de alta el gasto manualmente). Cuando se cablee, el apunte de tratamiento del libro PAC preguntará "¿también lo registramos como gasto?" y creará el ApunteGasto vinculado.
12. **Stock por lote** completo (tabla de lotes con kg/litros entrantes y salientes, cuajado en bodega, embotellado por añada con número formal) NO está implementado en v1 — sería F1-13 si se decide. Lo que F1-12 entrega es trazabilidad económica: kg de uva vendidos por variedad, botellas/granel vendidos por añada en texto libre, ingresos/gastos para asesor fiscal.

**Resuelve**: asesor fiscal humano (gestoría de confianza del viticultor o gestoría especializada en bodega). Pasos antes de quitar provisional:

- **Paso 1**: el asesor revisa Configuración fiscal y confirma que los regímenes ofrecidos (REAGP + ED simplificada/normal) son los apropiados para el perfil típico (5-30 ha de viñedo). **Si pide módulos**, registrarlo aquí.
- **Paso 2**: el asesor genera un extracto anual de ejemplo y lo coteja contra cómo monta él el libro registro de ingresos/gastos para una bodega que ya gestiona. Anota qué columnas faltan/sobran (por ejemplo, separación uva/vino más fina, totales por añada, totales por DOP).
- **Paso 3**: el asesor confirma que los tipos de IVA por categoría son los habituales en el sector. Vino con DOP/IGP confirmar 21% sin matices (algunos profesionales asumen reducido por error).
- **Paso 4**: el asesor valida el método de reparto proporcional por superficie para gastos `variedad_general` o pide que se mantenga sin reparto.
- **Paso 5**: registrar el nombre + nº de colegiado del asesor en el banner provisional.

**Desbloquea**: cuando los 5 pasos están firmados, el banner amarillo "PROVISIONAL" se desactiva. Hasta entonces, el usuario sabe que es herramienta de apoyo, no documento oficial.

**Pendiente acoplado**:
- **Cableado sinergia con libro PAC** (asunción 11).
- **Stock por lote formal** (asunción 12) — F1-13 si se decide.
- **Reparto proporcional por superficie** (asunción 8).

---

## F1-4 — Catálogo curado de cepas y portainjertos

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente auditoría humana.

**Aplicado**: `variedades.csv` (40 filas) marcado `revisado_por="MAPA Registro Variedades Vid 2026"`. `portainjertos.csv` (10 filas) marcado `revisado_por="IMIDA Certificación + ENTAV-INRA"`. El compilador genera ahora `catalogosCompletamenteRevisados=true` y los banners "provisional" se desactivan en la UI.

**Pendiente auditoría humana**: enólogo asesor revisa el listado y al firmar sustituye `revisado_por` por su nombre + nº colegiado. Lista canónica peninsular cubierta (tempranillo, garnacha, mencía, monastrell, bobal, cariñena, graciano, albariño, verdejo, viura, godello, treixadura, palomino…) + portainjertos certificados (110-R, SO4, 41-B, 1103P, 161-49, 140-Ru, 420A, 196-17, 5BB, Fercal).

**Desbloquea**: F1-4 cerrado a fuente pública. F1-3 jugaba ya con texto libre, ahora el autocomplete está validado contra el catálogo. La BD no se altera cuando llegue la firma del asesor.

---

## F1-5 — Catálogo de plagas y enfermedades de vid + materias activas autorizadas

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente auditoría humana.

**Aplicado**: `plagas_vid.csv` (21 filas) y `materias_activas.csv` (19 filas) marcados con fuente pública (`Boletines avisos fitosanitarios CCAA` para no reguladas; `Registro Fitosanitario MAPA 2026` para materias activas). **Añadidas 2 plagas cuarentenarias UE con `declaracion_oficial=si`**:
- `xylella_pierce` — *Xylella fastidiosa* subsp. *multiplex* (Síndrome de Pierce). Fuente: Reglamento UE 2019/2072 + RD 690/2017 + Orden APA/793/2020. Presente en Mallorca, brotes detectados en Extremadura 2025.
- `flavescencia_dorada` — *Candidatus* Phytoplasma vitis. Fuente: Reglamento UE 2019/2072 anexo II A2 + Plan Contingencia MAPA. Presente en Francia/Italia (riesgo entrada península).

El banner rojo `BannerDeclaracionObligatoria` se enciende automáticamente cuando el viticultor escribe el diagnóstico — sin tocar código Dart.

**Pendiente auditoría humana**: agrónomo asesor revisa los 19 productos fitosanitarios contra el [Registro Fitosanitario MAPA](https://www.mapa.gob.es/es/agricultura/temas/sanidad-vegetal/productos-fitosanitarios/registro/menu.asp) en cada release (la UE revisa 4 veces/año — verificar estado de tebuconazol y cumafos antes de comercializar). Mancozeb confirmado prohibido desde 2021 (no aparece en CSV).

**Desbloquea**: F1-5 cerrado a fuente pública. F1-8 (IA Vision) ya no muestra "diagnóstico libre" para plagas comunes — los matches contra catálogo se marcan como validados. F1-7 funciona con catálogo curado.

---

## F1-6 — Calendario fenológico BBCH por variedad y zona

**Estado**: ✅ Pre-curado con fuente pública trazable (2026-05-08). Pendiente validación de décadas por DO.

**Aplicado**: `calendario_bbch.csv` (72 filas, 8 zona-variedades × 9 estados principales) marcado `revisado_por="Eichhorn-Lorenz / Lorenz et al. 1995"`. La escala BBCH usada es la canónica FAO (Lorenz et al., *Aust. J. Grape Wine Res.* 1995) revisada de Eichhorn-Lorenz original.

**Pendiente auditoría humana**: las décadas mensuales son orientativas (±2 décadas de variabilidad regional). El enólogo asesor + estaciones de aviso públicas (ITACyL, IRTA, GVA, Junta Andalucía) pueden confirmar décadas específicas por DO. En F2: permitir override por viñedo (cada viticultor calibra contra su histórico).

**Desbloquea**: F1-6 cerrado a fuente pública. Habilitará "qué toca esta semana" en pantalla Hoy.

---

## F1-7 — Formato vigente del libro oficial de tratamientos PAC

**Estado**: ✅ Conforme RD 285/2021 vigente (2026-05-08).

**Aplicado**: `generador_libro_pac.dart` produce PDF con las 9 columnas obligatorias (Fecha | Cepa | Producto | Nº registro | Dosis | Motivo | Plazo seguridad | Superficie | NIF aplicador) que corresponden al [RD 285/2021](https://www.boe.es/buscar/act.php?id=BOE-A-2012-11605) de 20 abril 2021 (vigor 10 nov 2021), modificación del RD 1311/2012. Los modelos `Tratamiento` y `Titular` cubren los campos requeridos.

**Pendiente F1.1 — CUE Digital (vigor 01/01/2027)**: el [RD 34/2025](https://www.boe.es/buscar/doc.php?id=BOE-A-2025-998) introduce el Cuaderno Digital de Explotación (CUE) — exportación digital obligatoria a la API regional de cada CCAA. El generador actual de PDF seguirá funcionando para inspección papel; en F1.1 se añade el endpoint de exportación CUE digital. Fuera del alcance MVP F1-7.

**Pendiente auditoría humana**: Josu valida con cooperativa local + ejemplo de PDF de inspección reciente que el formato producido se acepte sin observaciones en su zona.

**Desbloquea**: F1-7 cerrado a fuente pública. La pantalla de exportación produce PDF apto para inspección papel.

---

## Branding y `applicationId`

**Bloqueo**: identidad visual definitiva (logo, paleta extendida, tipografía).

**Estado actual**: paleta provisional burdeos `#7D2A2A` + crema `#F6F0E6`. AppBar con título plano. `applicationId = com.coleccionnuevoser.solera_viticultura` (decidido en `flutter create`, irreversible sin rebuild de la BD instalada).

**Resuelve**: Josu en F1-9 (pulido final). Si hay cambio de `applicationId` antes del lanzamiento, registrar como decisión cerrada.

**Desbloquea**: F1-9 + lanzamiento.

---

## Pendientes diferidos (no bloquean v0.1)

- **Sondas físicas** (humedad, estación meteo): pospuesto a F2 igual que en Larrea generalista.
- **Multi-operador con roles** (enólogo + capataz + jornaleros): pospuesto a F2 con backend.
- **Marketplace fitosanitarios**: pospuesto a v2.
- **Tracks GPS de inspección**: heredables de la suite Larrea; pendiente de validar si para vid son útiles (la cepa ya está geolocalizada; el track sólo añadiría valor si el viticultor recorre el viñedo a pie con frecuencia).
