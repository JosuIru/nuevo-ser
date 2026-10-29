// En el navegador: llama a `window.larreaPush` (web/avisos_push.js).

import 'dart:js_interop';

@JS('larreaPush')
external _LarreaPush? get _larreaPush;

extension type _LarreaPush._(JSObject _) implements JSObject {
  external JSPromise<JSString> estado();
  external JSPromise<JSString> activar(
      JSString url, JSString token, JSString idioma);
  external JSPromise<JSString> desactivar(JSString url, JSString token);
  external JSPromise<JSString> renovar(
      JSString url, JSString token, JSString idioma);
}

Future<String> _esperar(
    JSPromise<JSString> Function(_LarreaPush) llamada) async {
  final larreaPush = _larreaPush;
  // Sin el script (una página antigua en caché): como si no hubiera push.
  if (larreaPush == null) return 'no_compatible';
  try {
    return (await llamada(larreaPush).toDart).toDart;
  } catch (_) {
    return 'error';
  }
}

Future<String> estadoAvisosPush() =>
    _esperar((larreaPush) => larreaPush.estado());

Future<String> activarAvisosPush(String url, String token, String idioma) =>
    _esperar(
        (larreaPush) => larreaPush.activar(url.toJS, token.toJS, idioma.toJS));

Future<String> desactivarAvisosPush(String url, String token) =>
    _esperar((larreaPush) => larreaPush.desactivar(url.toJS, token.toJS));

Future<String> renovarAvisosPush(String url, String token, String idioma) =>
    _esperar(
        (larreaPush) => larreaPush.renovar(url.toJS, token.toJS, idioma.toJS));
