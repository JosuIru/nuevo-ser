/// `true` en la versión de demostración (web para que las personas tester
/// prueben la app), que se compila con
/// `flutter build web --dart-define=SOLERA_DEMO=true`.
///
/// En esa versión los datos de ejemplo se cargan solos la primera vez y se
/// avisa de que todo queda guardado solo en ese navegador.
const bool esVersionDemo = bool.fromEnvironment('SOLERA_DEMO');
