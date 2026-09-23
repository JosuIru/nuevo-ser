"""Recorta los renders a la máquina y los deja en assets/maquinas/."""
import os
from PIL import Image

destino = '../../assets/maquinas'
os.makedirs(destino, exist_ok=True)
for fichero in sorted(os.listdir('out')):
    if not fichero.endswith('.png'):
        continue
    imagen = Image.open(f'out/{fichero}').convert('RGB')
    recorte = imagen.crop((80, 64, 480, 592))  # 400×528, la máquina entera
    recorte.save(f'{destino}/{fichero}', optimize=True)
    print(fichero, os.path.getsize(f'{destino}/{fichero}') // 1024, 'KB')
