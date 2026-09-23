"""Recorta cada sprite a su contenido (canal alfa) y lo copia a
assets/sprites/."""
import os

from PIL import Image

destino = '../../assets/sprites'
os.makedirs(destino, exist_ok=True)
for nombre in sorted(os.listdir('out')):
    origen = f'out/{nombre}/{nombre}_vista_0001.png'
    if not os.path.exists(origen):
        continue
    imagen = Image.open(origen).convert('RGBA')
    recorte = imagen.crop(imagen.getbbox())
    recorte.save(f'{destino}/{nombre}.png', optimize=True)
    print(nombre, recorte.size, os.path.getsize(f'{destino}/{nombre}.png') // 1024, 'KB')
