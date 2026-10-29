// Fuera del navegador no hay Web Push (ver avisos_push_web.dart).

Future<String> estadoAvisosPush() async => 'no_compatible';

Future<String> activarAvisosPush(
        String url, String token, String idioma) async =>
    'no_compatible';

Future<String> desactivarAvisosPush(String url, String token) async =>
    'no_compatible';

Future<String> renovarAvisosPush(
        String url, String token, String idioma) async =>
    'no_compatible';
