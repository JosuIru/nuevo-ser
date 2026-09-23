"""Copia el render del mapa a assets/mapa/fondo.jpg (sin alfa: JPEG)."""
import os

from PIL import Image

os.makedirs('../../assets/mapa', exist_ok=True)
imagen = Image.open('out/mapa.png').convert('RGB')
imagen.save('../../assets/mapa/fondo.jpg', quality=86, optimize=True, progressive=True)
print(imagen.size, os.path.getsize('../../assets/mapa/fondo.jpg') // 1024, 'KB')
