# Arte de las máquinas de Rexán

Renders propios hechos con [flavor3d](https://github.com/JosuIru/flavor3d)
(escenas 3D declarativas en Blender). Contenido del juego: CC-BY-SA 4.0.

- `generar_specs.py` escribe una spec YAML por máquina, encendida y
  apagada: mueble, marquesina, panel y, en la pantalla, el propio juego
  de la máquina (puente con carro, barras del Encaje, laberinto). Paleta
  de la guía visual (doc 11) y preset `arcane` (toon + contorno).
- `recortar.py` recorta cada render a la máquina y lo deja en
  `assets/maquinas/<id>_{on,off}.png`, que es lo que carga la app.

```bash
python3 generar_specs.py
for s in specs/*.yaml; do flavor3d run $s; done   # ~10 s cada una
python3 recortar.py
```

`specs/` y `out/` son intermedios y no se versionan.
