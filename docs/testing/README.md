# Guía para testers — Colección Nuevo Ser

Gracias por testear estas apps. Este documento explica cómo organizar la sesión
de prueba, cómo reportar lo que encuentres y dónde están las guías específicas
de cada app.

## Documentos en esta carpeta

- **`README.md`** (este archivo) — cómo testear, cómo reportar, qué esperamos.
- **`uno-roto-guia-testeo.md`** — guía detallada de testeo del juego Kids
  **Uno Roto** (matemáticas 9-12). Incluye sección extra para profesorado
  de matemáticas.
- **`las-versiones-guia-testeo.md`** — guía detallada de testeo del juego
  Kids **Las Versiones** (pensamiento histórico 10-14). Incluye sección
  extra para profesorado de historia / pensamiento crítico.
- **`el-cuaderno-guia-testeo.md`** — guía detallada de testeo del juego
  Kids **El Cuaderno** (observación del medio 9-13). Incluye sección
  extra para naturalistas y biólogos divulgadores.
- **`el-descifrador-guia-testeo.md`** — guía detallada de testeo del juego
  Kids **El Descifrador** (prototipo, oficio civil 11-14). Incluye sección
  extra para profesorado de lengua / L2 / cuatro cooficiales.
- **`fosiles-guia-testeo.md`** — guía detallada de testeo de la app **Fósiles**
  (cuaderno de campo paleontológico, adulto aficionado). Incluye una sección
  extra para perfil geólogo profesional.
- **`agro-guia-testeo.md`** — guía detallada de testeo de la app **Larrea**
  (gestor de fincas agrícolas).
- **`plantilla-informe-bug.md`** — formato estándar para reportar incidencias.

## Cómo prepararse

### Material necesario

- Móvil Android (la app se ha probado en Redmi Note 8, Android 11). Cualquier
  móvil Android 7+ debería funcionar.
- GPS activable, datos móviles o Wi-Fi al menos en parte de la sesión.
- Cámara funcional (algunas funciones piden foto).
- Espacio libre en disco: ~200 MB por app (la app + caché de mapas + fotos).

### Instalar

Descarga el APK de la app que vayas a testear desde la última release de GitHub:

> https://github.com/JosuIru/nuevo-ser/releases/latest

Al instalar Android pedirá permiso para "instalar apps de fuente desconocida".
Concédelo solo a la app desde la que abres el APK (navegador o explorador de
archivos), no a todo el sistema.

### Permisos al primer arranque

Las apps piden estos permisos. Acéptalos todos para poder testear todo:

- **Ubicación** (mapa, GPS, tracks)
- **Cámara** (fotos de hallazgos, identificación por IA)
- **Almacenamiento / fotos** (guardar fotos)
- **Notificaciones** (track GPS en background)

Si una app falla porque le falta un permiso, anota qué permiso pidió que no
encontraste y reporta como bug.

## Qué buscamos

Por orden de prioridad:

1. **Cosas que se rompen** — la app se cierra, una pantalla no carga, un botón no responde.
2. **Cosas que no se entienden** — un texto confuso, un icono que no se sabe qué hace, una pantalla que parece vacía sin razón.
3. **Cosas que funcionan mal** — el botón hace algo pero no lo esperado.
4. **Cosas que parecen lentas o se atascan** — esperas largas sin explicación, mapa que se congela.
5. **Cosas que te molestan aunque "funcionen"** — flujos largos, pasos innecesarios.
6. **Ideas y propuestas** — todo lo que pienses que falta, sobra o se podría hacer mejor.

### Lo que **no** buscamos en esta ronda

- Errores de ortografía o redacción menor — anótalos en una lista al final si
  te apetece pero no son prioridad.
- Opiniones sobre el icono o el color del fondo — el branding está pendiente.

## Cómo trabajar la sesión

1. **Lee primero la guía de la app** que vas a testear. Cada bloque tiene una
   lista de pasos y casillas para marcar. No hace falta seguirlos en orden,
   pero sí cubrirlos todos.
2. **Marca cada paso** con `[x]` si funciona como esperas, `[!]` si hay algo
   raro, o déjalo `[ ]` si no llegaste a probarlo.
3. **Anota incidencias** en el reporte (ver más abajo). Es mucho mejor reportar
   diez bugs cortos que uno larguísimo con todo mezclado.
4. **Captura pantallazos** cuando algo se rompa o sea confuso. En Android se
   hace con volumen-bajar + encendido a la vez.
5. **No tengas miedo de tocar cosas raras** — son apps en pruebas, lo peor que
   puede pasar es que cierres y vuelvas a abrir. Si algo te asusta (un botón
   que dice "borrar todo"), pregúntanos antes.

## Cómo reportar

Usa la plantilla en `plantilla-informe-bug.md`. Resumen:

```
## [App vX.Y.Z] Título corto del problema

**Severidad**: crítica / alta / media / baja

**Pasos**:
1. Abro la app
2. Toco X
3. Veo Y

**Esperado**: Z
**Obtenido**: W

**Pantalla / captura**: (si aplica)
**Dispositivo**: marca y modelo, Android X
```

Manda los reportes a Josu por:
- WhatsApp con captura adjunta para cosas urgentes (la app se cierra).
- Email o documento compartido para el informe final.
- GitHub issues si tienes cuenta: https://github.com/JosuIru/nuevo-ser/issues

Si vas a hacer un informe largo, **agrupa los bugs por app y por bloque**
(igual que están en la guía), no por fecha.

## Niveles de severidad

- **Crítica** — la app se cierra, se pierden datos, no se puede usar una
  funcionalidad principal.
- **Alta** — algo importante no funciona pero hay alternativa (p. ej. no se
  guarda la foto pero sí el resto del hallazgo).
- **Media** — algo se ve raro o se comporta mal pero no impide usar la app.
- **Baja** — detalle estético o cosmético.

## Confidencialidad

Estas apps son material de trabajo. Cuanto pruebes y los datos que generes
durante el testeo son confidenciales hasta que se publiquen. Si por algún
motivo necesitas compartir una captura con datos sensibles, tápalos antes.

## Tras la sesión

Cuando termines tu informe:

1. Comparte el documento con Josu.
2. Si has generado hallazgos o datos de prueba útiles, dilo en el informe;
   puede que queramos conservar el backup.
3. Si vas a seguir testeando, no desinstales — las próximas versiones se
   actualizan encima sin perder tus datos.

Gracias.
