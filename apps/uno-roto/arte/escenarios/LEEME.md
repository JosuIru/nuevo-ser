# Escenarios de los distritos

Renders propios con flavor3d, vista frontal ortográfica y **fondo
transparente**: el juego pinta detrás su cielo animado (lunas, estrellas,
niebla y lluvia del clima) y encima los Fragmentos. Contenido del juego:
CC-BY-SA 4.0.

```bash
python3 generar_escenarios.py
for s in specs/*.yaml; do flavor3d run $s; done   # ~15 s cada uno
python3 copiar.py     # → assets/escenarios/<distrito>_{off,on}.webp
```

- Moodboard: doc 11, "Distritos". La Montaña siempre al fondo.
- Dos versiones con la misma geometría (semilla estable por nombre):
  `off` con pocas ventanas y `on` con muchas. `PintorEscenario` las
  funde según `nivelRestauracion`: la ciudad se enciende al avanzar.
- Si la imagen no carga, el escenario se pinta como antes (por código).
- En memoria sólo quedan Tejados y el último distrito (~5 MB por imagen).
