'use strict';
// Avisos al momento en la versión web (Web Push): pedir permiso, suscribirse
// en el navegador y mandar la suscripción al WordPress
// (includes/push-web.php del plugin). Los enseña sw_zunbeltz.js. Lo usa la
// app desde Ajustes y al abrirse (lib/servicios/avisos_push_web.dart).
//
// Estados: 'activo', 'inactivo', 'denegado' (permiso retirado: solo se
// cambia en los ajustes del navegador), 'instalar' (iPhone/iPad sin añadir
// a la pantalla de inicio), 'no_compatible' y 'error'.
(function () {
  const RUTA_API = '/wp-json/solera-zunbeltz/v1/push/';

  function bytesDesdeBase64url(texto) {
    const base64 = (texto + '='.repeat((4 - (texto.length % 4)) % 4))
      .replace(/-/g, '+').replace(/_/g, '/');
    return Uint8Array.from(atob(base64), (caracter) => caracter.charCodeAt(0));
  }

  function compatible() {
    return 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window;
  }

  // En iOS el push solo existe con la app añadida a la pantalla de inicio.
  function esIosSinInstalar() {
    const ios = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
      (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    const instalada = navigator.standalone === true ||
      window.matchMedia('(display-mode: standalone)').matches;
    return ios && !instalada;
  }

  async function suscripcionActual() {
    const registro = await navigator.serviceWorker.getRegistration();
    return registro ? registro.pushManager.getSubscription() : null;
  }

  async function mandar(urlBase, token, metodo, cuerpo) {
    const respuesta = await fetch(urlBase + RUTA_API + 'suscripcion', {
      method: metodo,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Zunbeltz-Token': token,
      },
      body: JSON.stringify(cuerpo),
    });
    if (!respuesta.ok) throw new Error('servidor ' + respuesta.status);
  }

  async function estado() {
    if (esIosSinInstalar()) return 'instalar';
    if (!compatible()) return 'no_compatible';
    if (Notification.permission === 'denied') return 'denegado';
    const suscripcion = await suscripcionActual();
    return suscripcion && Notification.permission === 'granted' ? 'activo' : 'inactivo';
  }

  // Hay que llamarla directamente desde el toque: Safari solo enseña la
  // petición de permiso en respuesta a un gesto.
  async function activar(urlBase, token, idioma) {
    if (esIosSinInstalar()) return 'instalar';
    if (!compatible()) return 'no_compatible';
    const permiso = await Notification.requestPermission();
    if (permiso !== 'granted') return permiso === 'denied' ? 'denegado' : 'inactivo';
    try {
      const registro = await navigator.serviceWorker.ready;
      let suscripcion = await registro.pushManager.getSubscription();
      if (!suscripcion) {
        // 404: un plugin anterior, sin avisos al momento.
        const respuesta = await fetch(urlBase + RUTA_API + 'clave', {
          headers: { 'Accept': 'application/json' },
        });
        if (!respuesta.ok) throw new Error('servidor ' + respuesta.status);
        const { clave_publica: clavePublica } = await respuesta.json();
        suscripcion = await registro.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: bytesDesdeBase64url(clavePublica),
        });
      }
      await mandar(urlBase, token, 'POST', Object.assign(suscripcion.toJSON(), { idioma }));
      return 'activo';
    } catch (error) {
      console.warn('Avisos al momento:', error);
      return 'error';
    }
  }

  async function desactivar(urlBase, token) {
    if (!compatible()) return 'no_compatible';
    const suscripcion = await suscripcionActual();
    if (!suscripcion) return 'inactivo';
    try {
      await mandar(urlBase, token, 'DELETE', { endpoint: suscripcion.endpoint });
    } catch (_) {
      // Sin red: el servidor la olvidará cuando el servicio de push le
      // diga que ya no existe.
    }
    await suscripcion.unsubscribe();
    return 'inactivo';
  }

  // Al abrir la app: si ya está activo, se vuelve a mandar (la dirección
  // de la suscripción puede cambiar, o la persona de este navegador).
  async function renovar(urlBase, token, idioma) {
    if (!compatible() || Notification.permission !== 'granted') return 'inactivo';
    const suscripcion = await suscripcionActual();
    if (!suscripcion) return 'inactivo';
    try {
      await mandar(urlBase, token, 'POST', Object.assign(suscripcion.toJSON(), { idioma }));
      return 'activo';
    } catch (error) {
      return 'error';
    }
  }

  window.larreaPush = { estado, activar, desactivar, renovar };
})();
