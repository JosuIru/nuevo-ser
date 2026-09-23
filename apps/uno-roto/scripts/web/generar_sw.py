#!/usr/bin/env python3
"""Genera build/web/sw_uno_roto.js: el service worker que deja Uno Roto
entero en la caché del navegador para jugar sin conexión.

- Al instalarse, descarga todos los archivos del build (lista generada
  aquí) en una caché con versión = huella del contenido.
- Archivos grandes (assets, canvaskit): de la caché primero.
- index.html, arranque y código: de la caché al instante y se refrescan
  en segundo plano si hay red.
- Cada despliegue con cambios crea una caché nueva y borra las viejas.
"""
import hashlib
import json
import os
import sys

CARPETA = sys.argv[1] if len(sys.argv) > 1 else 'build/web'
SALIDA = 'sw_uno_roto.js'
EXCLUIDOS = {SALIDA, 'flutter_service_worker.js'}

archivos = []
huella = hashlib.sha256()
for raiz, _, nombres in os.walk(CARPETA):
    for nombre in sorted(nombres):
        ruta = os.path.join(raiz, nombre)
        relativa = os.path.relpath(ruta, CARPETA).replace(os.sep, '/')
        if relativa in EXCLUIDOS:
            continue
        archivos.append(relativa)
        with open(ruta, 'rb') as f:
            huella.update(relativa.encode())
            huella.update(hashlib.sha256(f.read()).digest())
archivos.sort()
version = huella.hexdigest()[:12]

sw = f"""// GENERADO por scripts/web/generar_sw.py — no editar a mano.
const CACHE = "uno-roto-{version}";
const ARCHIVOS = {json.dumps(['./'] + archivos, indent=0)};
// Se refrescan en segundo plano (cambian con cada versión).
const REFRESCAR = new Set(["./", "index.html", "flutter_bootstrap.js", "main.dart.js",
  "version.json", "manifest.json"]);

self.addEventListener("install", (evento) => {{
  evento.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(ARCHIVOS)).then(() => self.skipWaiting())
  );
}});

self.addEventListener("activate", (evento) => {{
  evento.waitUntil(
    caches.keys()
      .then((claves) => Promise.all(
        claves.filter((c) => c.startsWith("uno-roto-") && c !== CACHE).map((c) => caches.delete(c))))
      .then(() => self.clients.claim())
  );
}});

self.addEventListener("fetch", (evento) => {{
  const peticion = evento.request;
  if (peticion.method !== "GET") return;
  const url = new URL(peticion.url);
  const base = new URL(self.registration.scope);
  if (url.origin !== base.origin || !url.pathname.startsWith(base.pathname)) return;
  const relativa = url.pathname.slice(base.pathname.length) || "./";

  evento.respondWith(caches.open(CACHE).then(async (cache) => {{
    const guardada = await cache.match(peticion, {{ ignoreSearch: true }});
    if (guardada && !REFRESCAR.has(relativa)) return guardada;
    const deRed = fetch(peticion).then((respuesta) => {{
      if (respuesta.ok) cache.put(peticion, respuesta.clone());
      return respuesta;
    }});
    if (guardada) {{
      deRed.catch(() => {{}});
      return guardada;        // al instante; se refresca detrás
    }}
    return deRed;
  }}));
}});
"""
with open(os.path.join(CARPETA, SALIDA), 'w', encoding='utf-8') as f:
    f.write(sw)
print(f'{SALIDA}: {len(archivos)} archivos, versión {version}')
