# Larrea (agro) — Bloqueos pendientes (decisión humana)

Tracker de decisiones humanas que bloquean el cierre a producción de cada fase. Mantener actualizado: añadir cada vez que aparezca un bloqueo, marcar resuelto cuando entre el dato/asesoramiento.

Convenciones:
- **Bloqueo** = título corto + qué falta + quién lo resuelve + qué fase desbloquea.
- Sustituciones diegéticas/temporales documentadas aquí también, por si el agrónomo asesor o el inspector cambian de criterio.

---

## F3.5 — Libro económico (ingresos/gastos + modelo 347 + extracto anual)

**Estado**: ✅ con datos provisionales. Funcional end-to-end pero el formato del libro registro y del extracto está pendiente de firma de asesor fiscal antes de presentar nada en una declaración.

**Asunciones aplicadas en v1 provisional** (registradas para que el asesor fiscal las revise línea a línea):

1. **Régimen fiscal v1** soporta REAGP (compensación 12%, dominante en agricultor pequeño/mediano) y Estimación directa simplificada / normal. **Módulos NO está soportado** — el asesor fiscal debe pedirlo explícitamente y validar el formato del extracto antes de añadirlo. **Importante para agro**: módulos sigue siendo más usado en agricultura que en otras actividades, así que es probable que el asesor lo pida en cuanto vea la app. La pantalla de Configuración fiscal lo deja claro al usuario.
2. **IVA repercutido en venta de cosecha** = 4% por defecto en régimen general (alimento de primera necesidad, art. 91.1.1.1.º LIVA — aceite, frutas, hortalizas, cereales, vino sin DOP/IGP). Excepciones que el usuario debe sobrescribir manualmente: vino con DOP/IGP 21%, trufa 10%, madera 21%. La app sugiere 4% y el usuario corrige cuando proceda.
3. **IVA en venta de leña/madera** = 21% general autocalculado (no es alimento de primera necesidad).
4. **IVA en alquiler de terreno** = 0% por defecto (uso agrícola exento, art. 20.1.23 LIVA). Si el alquiler es para uso no agrícola (cazadero, evento, almacén) el usuario sobrescribe con 21%. La app no puede inferir el uso final.
5. **IVA en gastos** autocalculado por categoría según práctica habitual:
   - **Insumos agrarios** (semillas, plantones, fertilizantes, abonos): 4% reducido por defecto. Algunos van al 10% (ciertos abonos orgánicos) o al 21%; el usuario sobrescribe cuando difiera.
   - **Seguros**: 0% (exentos, art. 20 LIVA).
   - **Mano de obra agrícola**: 0% por defecto (típicamente no lleva IVA cuando es jornalero régimen general SS agraria).
   - **Riego / agua**: 10% reducido (suministro de agua para riego).
   - **Maquinaria, fitosanitarios, combustible, transporte, veterinario, certificación, otros**: 21% general por defecto.
6. **IVA soportado en REAGP** marcado como NO recuperable; se computa como mayor coste en el extracto (caso normal en agricultor mediano).
7. **Modelo 347** se calcula sobre el importe **total** (base + IVA + compensación REAGP) por NIF y año, umbral fijo en 3.005,06€. Es la regla AEAT actual; verificar antes de cada release que la AEAT no la modifica.
8. **Reparto proporcional por hectárea** de gastos imputados a `cultivo_general` entre las parcelas con ese cultivo NO está calculado en v1. Los apuntes con esa imputación se listan en el extracto con el importe íntegro asignable al cultivo, y la nota final del PDF lo señala. Calcular el reparto real requiere conocer la superficie cultivada de cada parcela en la fecha del gasto — está modelado pero no implementado todavía. Cuando el asesor fiscal valide el método de reparto (lineal por hectáreas vs por número de plantas activas), el cálculo se mueve al generador.
9. **Apuntes sin NIF** (mercado local, vecino sin factura) se permiten guardar pero el extracto los lista en una tabla aparte con aviso porque NO entran al modelo 347. La AEAT permite ingresos sin NIF si están justificados por libro de caja diaria o similar — verifica práctica con tu asesor.
10. **Sinergia con cuaderno MAPA**: en v1 el `tratamientoId` del ApunteGasto está modelado y se preserva en BD, pero la generación automática del apunte de gasto desde la pantalla de tratamiento NO está cableada (el agricultor da de alta el gasto manualmente). Cuando el flujo se cablee, el apunte de tratamiento del cuaderno preguntará "¿también lo registramos como gasto?" y creará el ApunteGasto vinculado.
11. **Ayudas PAC y subvenciones autonómicas** se separan del ingreso ordinario en el extracto (no son rendimiento ordinario fiscalmente). En agro la PAC suele ser una porción significativa de ingresos totales — separarla evita inflar artificialmente la rentabilidad por hectárea.
12. **Gestión de fotos de factura**: una foto por apunte (no varias páginas — si el documento tiene varias hojas, el usuario las junta con la app del móvil). Si el asesor pide adjuntar varias páginas por apunte, el modelo `rutaFotoFactura: String` cambia a `rutasFotosFactura: List<String>` codificado JSON (cambio aditivo no destructivo en BD v7).

**Resuelve**: asesor fiscal humano (gestoría de confianza del titular o gestoría especializada en agricultura). Pasos antes de quitar provisional:

- **Paso 1**: el asesor revisa la pantalla de Configuración fiscal y confirma que los regímenes ofrecidos son los apropiados. **Si pide módulos**, registrarlo aquí y añadir la opción.
- **Paso 2**: el asesor genera un extracto anual de ejemplo y lo coteja contra cómo monta él el libro registro de ingresos/gastos para una explotación agrícola que ya gestiona. Anota qué columnas faltan/sobran.
- **Paso 3**: el asesor confirma que el cálculo del modelo 347 (operaciones >3.005,06€/NIF/año, sumando ingresos y gastos del mismo NIF) es la regla actual y que el umbral no ha cambiado.
- **Paso 4**: el asesor valida el método de reparto proporcional por hectárea para gastos `cultivo_general` o pide que se mantenga como está (importe íntegro asignable, sin reparto por parcela) hasta que se decida.
- **Paso 5**: registrar el nombre + nº de colegiado del asesor en el banner provisional. Cambiar el banner a "Validado por [Nombre], [Colegiado]".

**Desbloquea**: cuando los 5 pasos están firmados, el banner amarillo "PROVISIONAL" se desactiva y la app pasa a producción para esta funcionalidad. Hasta entonces, el usuario sabe que es herramienta de apoyo, no documento oficial.

**Pendiente acoplado**:
- **Cableado de la sinergia con cuaderno MAPA** (asunción 10): cuando el asesor fiscal valide el formato del libro registro, F3.5.1 cablea el flujo "tratamiento → apunte de gasto" con preguntar/confirmar.
- **Reparto proporcional por hectárea** (asunción 8): cuando el asesor valide el método.
- Si la AEAT publica formato digital del libro registro equivalente al CUE (RD 34/2025 vigor 2027), F3.5.2 añade el endpoint de exportación digital.

---

## Pendientes diferidos (no bloquean v0.3)

- **Validación del catálogo de plagas/enfermedades** (`catalogo_plagas.dart`) por agrónomo asesor antes de publicación pública.
- **Validación del catálogo de fitosanitarios** (`catalogo_fitosanitarios.dart`) por agrónomo.
- **Validación del PDF del cuaderno MAPA** por inspector real (técnico de Conselleria/Junta) — el formato cubre los apartados del RD 1311/2012 pero conviene confirmar lo que esperan ver en una visita real.
- **Export XML SIEX/CUE oficial**: validar la spec XSD vigente con el MAPA o asesor antes de implementar.
- **F4 Backend nube**: 3 decisiones humanas pendientes (stack / auth / monetización) — registradas en CLAUDE.md.
- **Logo y branding visual** definitivo para "Larrea".
- **`applicationId` final** (`com.josu.agro` actual vs rebrand a `com.josu.solera` antes de Play Store).
- **Marketplace fitosanitarios** (v2 — necesita alianzas).
