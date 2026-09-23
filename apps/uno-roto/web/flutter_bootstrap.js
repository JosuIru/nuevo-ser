{{flutter_js}}
{{flutter_build_config}}

// Motor gráfico (canvaskit) desde la propia web, no desde la CDN de
// Google: funciona sin conexión y no avisa a terceros de cada visita
// (doc 01, principio 5). Sin serviceWorkerSettings: el de Flutter está
// obsoleto y se desregistra solo.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
    // Fuentes de respaldo (símbolos que no trae Roboto) servidas desde
    // aquí, no desde fonts.gstatic.com. Noto Sans Symbols 1 y 2, OFL.
    fontFallbackBaseUrl: "fuentes-respaldo/",
  },
});

// Nuestro service worker (generado en el despliegue con la lista de
// todos los archivos): deja el juego entero guardado para jugar sin red.
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("sw_uno_roto.js").catch((error) => {
      console.warn("Uno Roto: no se pudo registrar el modo sin conexión", error);
    });
  });
}
