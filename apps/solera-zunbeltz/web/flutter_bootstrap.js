{{flutter_js}}
{{flutter_build_config}}

// Sin `serviceWorkerSettings`: el service worker de Flutter está obsoleto
// (se borra a sí mismo) y, registrado en la misma carpeta, quitaría el
// nuestro (sw_zunbeltz.js, que se registra desde index.html).
_flutter.loader.load();
