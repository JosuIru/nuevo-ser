# Ilustración del mapa

La ciudad a la hora azul, renderizada con flavor3d. Contenido del juego:
CC-BY-SA 4.0.

```bash
python3 generar_mapa.py && flavor3d run specs/mapa.yaml && python3 copiar.py
```

- Cada distrito se levanta en su `(xMapa, yMapa)` de
  `lib/dominio/catalogo_distritos.dart`. Si se mueve un nodo, hay que
  moverlo también en `CENTROS` y regenerar.
- Cámara ortográfica a 55°: la relación suelo → pantalla es lineal y el
  render cae bajo los letreros aunque el lienzo se estire.
- Sin preset de estilo: `arcane` dejaba manchas en el suelo y `ghibli`
  aplanaba la noche. Variables `ESTILO`, `SALIDA` y `ESCALA_RES` para
  comparar a baja resolución.
- Salida: `assets/mapa/fondo.jpg` (1080×2000, JPEG, ~100 KB).
