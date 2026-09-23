# Solera Zunbeltz — Esquema de la primera fase

Documento para revisar con el equipo de Zunbeltz Elkartea. Recoge **todo lo que la app hace hoy**, sección a sección. Os pedimos que lo repaséis y nos digáis **qué os encaja, qué sobra y qué echáis en falta**. Al final de cada sección hay unas preguntas para orientar la revisión.

Características generales:
- Funciona **sin cobertura** (todo se guarda en el móvil; solo la previsión del tiempo necesita internet).
- **Castellano y euskera** (el euskera está pendiente de revisión por una persona nativa).
- Uso en **un solo dispositivo** por ahora: todavía no hay usuarios, roles ni sincronización entre móviles.
- Los PDF que genera llevan el sello **PROVISIONAL** hasta que se valide su formato.

La app tiene **4 pestañas** abajo: **Hoy · Fincas · Proyectos · Ajustes**.

---

## 1. Hoy

Pantalla de resumen al abrir la app.
- Tiempo del día.
- Número de tareas de mantenimiento abiertas → botón **Ver tareas**.
- Acceso a la **Ayuda**.

> ¿Qué os gustaría ver nada más abrir la app? (avisos, próximas tareas, lo último registrado…)

---

## 2. Fincas (módulo de apoyo)

### 2.1 Mapa de las fincas
- Zunbeltz y La Planilla sobre el mapa (capas: mapa / satélite).
- Botón **GPS** para situarse.
- **Previsión del tiempo** de varios días con avisos: helada, lluvia, viento fuerte, calor, buen día de manejo.

### 2.2 Puntos de infraestructura
Se añaden tocando el mapa, con el GPS del móvil o en el centro del mapa.
- **Tipo**: abrevadero · manga de manejo · cierre/alambrada · refugio/cabaña · cuadra · almacén · balsa/punto de agua · comedero · cargadero · parcela de pasto.
- **Datos**: finca, nombre, estado (operativo / revisar / averiado), notas, fotos, coordenadas.
- **Ficha del punto**: sus tareas, recolocarlo en el mapa, borrarlo.

### 2.3 Tareas de mantenimiento
Se crean desde la ficha de un punto o para la finca en general.
- **Datos**: título, descripción, responsable, prioridad (baja / media / alta), estado (pendiente / en curso / hecha / bloqueada), fecha objetivo, fotos antes y después, coste.
- **Tablero de tareas**: todas las tareas, con filtros por finca y por estado.
- **Parte de mantenimiento en PDF**.

> ¿Faltan tipos de infraestructura? ¿Quién debe poder crear y asignar tareas? ¿Queréis avisos de tareas vencidas? ¿Os sirve el parte en PDF o necesitáis otro formato?

---

## 3. Proyectos (núcleo: seguimiento del proceso de test)

### 3.1 Lista de proyectos de test
- Un proyecto por cada persona tester.
- **Datos del proyecto**: nombre, persona tester, actividad/vertical, finca que usa (opcional), fechas de inicio y fin.
- **Comparativa de proyectos en PDF** (todos los proyectos lado a lado).

### 3.2 Ficha del proyecto
**Resumen de rentabilidad** arriba, filtrable por periodo (todo / este año / este trimestre / trimestre anterior):
- Ventas · otros ingresos · gastos · balance · margen · **proyección anual**.

Cuatro pestañas:

**a) Producción**
- Registros de actividad: alimentación (kg), pariciones (crías), producto obtenido (uds).
- Cada registro: fecha, cantidad, lote/rebaño, notas.

**b) Comercialización**
- Ventas: fecha, producto, canal, cantidad, unidad, precio unitario, IVA → ingreso.
- **Canales**: venta directa · mercado/feria · tienda/grupo de consumo · online · mayorista/distribuidor · restauración · otro.

**c) Validación de producto**
- Pruebas de producto: qué se valida, resultado (validado / ajustar / descartar), valoración, notas.

**d) Económico**
- Apuntes de ingreso o gasto: concepto, importe, IVA, categoría, notas.
- **Categorías de gasto**: alimentación · sanidad/veterinario · insumos/materiales · mano de obra · alquiler/cesión · maquinaria/combustible · servicios · otros.
- **Categorías de ingreso**: venta · ayuda/prima · otros.
- **Desglose de gastos** por categoría, IVA soportado y repercutido (orientativo, no es declaración fiscal).

### 3.3 Salidas del proyecto
- **Informe del proyecto en PDF**.
- **Exportar a CSV** (se abre en Excel).
- **Enviar al coordinador** por correo.

> ¿Estos cuatro bloques (producción, comercialización, validación, económico) reflejan cómo evaluáis un test? ¿Qué indicadores usáis que no estén? ¿Faltan canales o categorías? ¿Qué debe llevar el informe para la persona tester, para el coordinador y para la entidad que financia?

---

## 4. Ajustes

- Idioma: castellano / euskera.
- **Correo del coordinador** (para enviar informes).
- **Exportar todo el espacio a CSV**.
- Cargar datos de demostración.
- Ayuda paso a paso.
- Acerca del Espacio Test Zunbeltz.
- Aviso de versión preliminar.

> ¿Falta algo de configuración? (varios coordinadores, logo, datos de la entidad en los informes…)

---

## Lo que queda fuera de esta primera fase

Para que lo tengáis presente al valorar (se abordaría en fases siguientes, y siempre co-diseñado con vosotras):
- **Usuarios y roles** (tester, mentor, coordinación) y **sincronización** entre móviles.
- **Cuaderno ganadero**: animales, lotes, pesajes, partos, tratamientos, movimientos, escáner del DIB.
- **Libro de explotación**, cuaderno PAC y trazabilidad ecológica (CPAEN).
- **Acompañamiento**: convocatorias, cesiones, tutorías, hitos y evaluación de viabilidad.
- **Banco de tierras** y trazabilidad hasta **La Venta de Zunbeltz**.

---

**Preguntas generales**
1. ¿Hay algo del día a día del Espacio Test que no aparezca en ninguna sección?
2. ¿Qué es imprescindible para vosotras y qué podría esperar?
3. ¿Quién va a usar la app en la práctica y desde qué dispositivo?
