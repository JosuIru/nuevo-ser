"""Copia los escenarios a assets/escenarios/<distrito>_{off,on}.webp."""
import os

from PIL import Image

destino = '../../assets/escenarios'
os.makedirs(destino, exist_ok=True)
for carpeta in sorted(os.listdir('out')):
    origen = f'out/{carpeta}/{carpeta}_frente_0001.png'
    if not os.path.exists(origen):
        continue
    imagen = Image.open(origen).convert('RGBA')
    ruta = f'{destino}/{carpeta}.webp'
    imagen.save(ruta, quality=88, method=6)
    print(carpeta, os.path.getsize(ruta) // 1024, 'KB')
