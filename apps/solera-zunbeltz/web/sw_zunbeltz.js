'use strict';
// Service worker de la versión web: guarda la app en el navegador para que
// se abra sin cobertura (en el iPhone, añadida a la pantalla de inicio).
// Los datos no van aquí: viven en IndexedDB y salen al servidor al
// sincronizar. La API del WordPress, las teselas del mapa y lo demás
// pasan sin tocar.
//
// La versión y la lista los pone tool/preparar_web_sin_conexion.dart tras
// compilar; sin ellos no se instala.

const VERSION = '__VERSION_SIN_CONEXION__';
const FICHEROS = /*FICHEROS_SIN_CONEXION*/[];

const PREFIJO_CACHE_APP = 'larrea-app-';
const CACHE_APP = PREFIJO_CACHE_APP + VERSION;
// Lector de códigos del escáner (CDN, versión fija) y tipos de letra de
// respaldo de Flutter: no cambian para una misma dirección.
const CACHE_EXTERNO = 'larrea-externo-v1';
const ORIGENES_EXTERNOS = [
  'https://cdn.jsdelivr.net/npm/zxing-wasm@',
  'https://unpkg.com/@zxing/library@',
  'https://fonts.gstatic.com/',
];
// Con cobertura floja, a los 4 s se abre la guardada.
const ESPERA_PAGINA_MS = 4000;

const ambito = self.registration.scope;
const urlDe = (ruta) => new URL(ruta, ambito).href;
const esDeLaApp = (url) =>
  url.startsWith(ambito) && !url.startsWith(urlDe('descargar/'));
const esExterno = (url) => ORIGENES_EXTERNOS.some((origen) => url.startsWith(origen));
const esMotorCanvasKit = (url) => url.startsWith(urlDe('canvaskit/'));

self.addEventListener('install', (evento) => {
  evento.waitUntil((async () => {
    if (FICHEROS.length === 0) throw new Error('service worker sin preparar');
    // El motor que ya usaba este navegador (p. ej. el de Chrome) se vuelve a
    // bajar: si no, tras actualizar la app no se abriría sin cobertura.
    const motoresEnUso = new Set();
    for (const nombre of await caches.keys()) {
      if (!nombre.startsWith(PREFIJO_CACHE_APP) || nombre === CACHE_APP) continue;
      for (const peticion of await (await caches.open(nombre)).keys()) {
        if (esMotorCanvasKit(peticion.url)) motoresEnUso.add(peticion.url);
      }
    }
    const urls = new Set([...FICHEROS.map(urlDe), ...motoresEnUso]);
    const cache = await caches.open(CACHE_APP);
    // `reload`: del servidor, no de la caché HTTP (podría ser la anterior).
    await cache.addAll([...urls].map((url) => new Request(url, { cache: 'reload' })));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (evento) => {
  evento.waitUntil((async () => {
    for (const nombre of await caches.keys()) {
      if (nombre.startsWith(PREFIJO_CACHE_APP) && nombre !== CACHE_APP) {
        await caches.delete(nombre);
      }
    }
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (evento) => {
  const peticion = evento.request;
  if (peticion.method !== 'GET') return;
  const url = peticion.url;
  if (peticion.mode === 'navigate') {
    if (esDeLaApp(url)) evento.respondWith(abrirPagina(peticion));
    return;
  }
  if (esDeLaApp(url)) {
    evento.respondWith(primeroGuardado(peticion, CACHE_APP));
  } else if (esExterno(url)) {
    evento.respondWith(primeroGuardado(peticion, CACHE_EXTERNO));
  }
});

// La página, de la red si contesta pronto (así se ve enseguida un cambio
// de index.html); si no, la guardada.
async function abrirPagina(peticion) {
  const guardada = await (await caches.open(CACHE_APP)).match(urlDe('index.html'));
  const deLaRed = fetch(peticion);
  if (!guardada) return deLaRed;
  const espera = new Promise((resolver) => setTimeout(resolver, ESPERA_PAGINA_MS));
  try {
    const respuesta = await Promise.race([deLaRed, espera]);
    if (respuesta && respuesta.ok) return respuesta;
  } catch (_) {
    // Sin red: la guardada.
  }
  return guardada;
}

// Lo guardado manda (cada versión trae su caché entero); lo que falte se
// baja y se guarda.
async function primeroGuardado(peticion, nombreCache) {
  const cache = await caches.open(nombreCache);
  const guardada = await cache.match(peticion, { ignoreSearch: nombreCache === CACHE_APP });
  if (guardada) return guardada;
  const respuesta = await fetch(peticion);
  if (respuesta.ok) await cache.put(peticion, respuesta.clone());
  return respuesta;
}

// La página avisa de lo que ha cargado antes de que este service worker la
// controlara (la primera vez): así se guarda también el motor de CanvasKit
// que usa este navegador.
self.addEventListener('message', (evento) => {
  const datos = evento.data || {};
  if (datos.tipo !== 'guardar' || !Array.isArray(datos.urls)) return;
  evento.waitUntil((async () => {
    for (const url of datos.urls) {
      if (typeof url !== 'string' || url.endsWith('.symbols')) continue;
      const nombreCache = esDeLaApp(url) ? CACHE_APP : esExterno(url) ? CACHE_EXTERNO : null;
      if (!nombreCache) continue;
      const cache = await caches.open(nombreCache);
      if (await cache.match(url, { ignoreSearch: nombreCache === CACHE_APP })) continue;
      try {
        const respuesta = await fetch(url);
        if (respuesta.ok) await cache.put(url, respuesta);
      } catch (_) {
        // Sin red: ya se guardará la próxima vez.
      }
    }
  })());
});
