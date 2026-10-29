# Plantilla de informe de bug / observación

Copia esta plantilla por cada incidencia que encuentres. Una incidencia por
bloque facilita mucho que se pueda arreglar rápido. **Mejor 10 reportes
cortos que uno larguísimo con todo mezclado.**

---

## [App vX.Y.Z] Título corto y descriptivo

**Severidad**: crítica / alta / media / baja
**Reportado por**: [nombre / alias]
**Fecha**: [YYYY-MM-DD]
**Bloque de la guía**: [p. ej. "Fósiles · Bloque 4 · Nuevo hallazgo"]

### Pasos para reproducir

1. Abro la app en …
2. Toco …
3. Veo …

### Resultado esperado

Lo que debería haber pasado.

### Resultado obtenido

Lo que pasó realmente.

### Captura / vídeo

(adjuntar imagen aquí o enlace)

### Dispositivo

- Marca y modelo:
- Versión Android:
- Conexión durante el bug (Wi-Fi / 4G / sin red):

### Notas adicionales

(¿Solo te ha pasado una vez o se repite? ¿Pasó tras alguna otra acción?
¿Hay algo más que quieras anotar?)

---

# Ejemplos del formato

## [Fósiles 1.0.2] Marker de hallazgo no aparece tras crearlo desde el mapa

**Severidad**: alta
**Reportado por**: Juan Tester
**Fecha**: 2026-05-14
**Bloque**: Fósiles · Bloque 3 · Modo Marcar punto

### Pasos para reproducir

1. Abrir mapa.
2. Activar modo "Marcar punto".
3. Tocar un punto del mapa → se abre formulario "Nuevo hallazgo".
4. Rellenar campos y guardar.
5. Volver al mapa.

### Resultado esperado

El hallazgo guardado aparece como marker en el mapa, en la posición que toqué.

### Resultado obtenido

El hallazgo se ha guardado correctamente (aparece en la lista) pero el
marker no se pinta en el mapa. Si cierro y vuelvo a abrir la app, sí aparece.

### Captura

(captura adjunta)

### Dispositivo

- Xiaomi Redmi Note 8
- Android 11
- Wi-Fi

### Notas

Pasa siempre. Tras el guardar, parece que el mapa no se refresca hasta
que reabres la pantalla.

---

## [Larrea 0.3.1] La meteo no carga si Open-Meteo va lento

**Severidad**: media
**Reportado por**: Juan Tester
**Fecha**: 2026-05-14
**Bloque**: Larrea · Bloque 1 · Pantalla Hoy

### Pasos para reproducir

1. Abrir Larrea con red lenta (3G o Wi-Fi débil).
2. Esperar 30 segundos.

### Resultado esperado

Carga la previsión meteo, o muestra un mensaje de "no se pudo cargar,
toca para reintentar".

### Resultado obtenido

La tarjeta se queda con "Cargando previsión meteo…" indefinidamente.
No hay timeout visible para el usuario.

### Captura

(captura adjunta)

### Dispositivo

- Samsung Galaxy A50
- Android 11
- Wi-Fi débil (1 barra)

### Notas

Probado dos veces, mismo resultado. Si vuelvo a Wi-Fi rápida y matar
y abrir la app, carga bien.
