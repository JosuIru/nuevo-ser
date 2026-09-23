# Sprites de las máquinas

Renders propios con flavor3d (`sprite_sheet`, una vista, fondo
transparente). Contenido del juego: CC-BY-SA 4.0.

```bash
python3 generar_sprites.py
for s in specs/*.yaml; do flavor3d run $s; done
python3 copiar.py     # recorta por alfa → assets/sprites/<nombre>.png
```

- `carro` — Puentes. `fragmento` y `sombra` — Canales.
- Sin preset toon: con él la emisión no brilla (farol, núcleo, ojos).
- Tablones y barras se siguen dibujando por código: se estiran a
  cualquier medida y un sprite se deformaría.
