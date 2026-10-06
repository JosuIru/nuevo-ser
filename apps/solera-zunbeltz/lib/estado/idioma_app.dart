import 'package:flutter/widgets.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas que soporta Solera Zunbeltz. Castellano y euskera son ambos de
/// primera clase desde el día uno (decisión cerrada). La lista queda
/// preparada para sumar otras cooficiales si la plataforma se replica a
/// otros Espacios Test (catalán, gallego…).
const List<Locale> localesSoportadosZunbeltz = <Locale>[
  Locale('es'),
  Locale('eu'),
];

/// Locale activo de la app. `null` = primer arranque (todavía no se ha
/// elegido idioma): el orquestador mostrará la pantalla de bienvenida y
/// el `localeResolutionCallback` caerá al idioma del dispositivo o a
/// castellano. Al elegir/cambiar idioma se actualiza este notifier, lo que
/// repinta `MaterialApp` con el nuevo locale.
final ValueNotifier<Locale?> localeAppZunbeltz = ValueNotifier<Locale?>(null);

/// Persistencia del idioma elegido, reutilizando el repositorio del core.
/// Namespace propio de la app: `zunbeltz.idioma_app`.
final RepositorioIdiomaApp repositorioIdiomaZunbeltz = RepositorioIdiomaApp(
  prefs: SharedPreferences.getInstance,
  clave: 'zunbeltz.idioma_app',
);

/// Carga el idioma persistido (si lo hay) y lo aplica al notifier global
/// antes del primer build, para evitar un parpadeo con el idioma del
/// sistema. Devuelve el código cargado o `null` si es primer arranque.
///
/// Sin idioma guardado, en la app web vale el de la dirección (`?lang=eu`,
/// lo pone la portada en euskera del WordPress): se aplica sin guardarlo,
/// así la bienvenida sale ya en ese idioma.
Future<String?> precargarIdiomaZunbeltz() async {
  final codigo =
      await repositorioIdiomaZunbeltz.cargar() ?? idiomaDesdeDireccion(Uri.base);
  if (codigo != null) {
    localeAppZunbeltz.value = Locale(codigo);
  }
  return codigo;
}

/// Idioma soportado pedido en la dirección (`?lang=eu`), o `null`.
String? idiomaDesdeDireccion(Uri direccion) {
  final pedido = direccion.queryParameters['lang'];
  return localesSoportadosZunbeltz.any((locale) => locale.languageCode == pedido)
      ? pedido
      : null;
}

/// Persiste y aplica el idioma elegido.
Future<void> elegirIdiomaZunbeltz(String codigo) async {
  await repositorioIdiomaZunbeltz.guardar(codigo);
  localeAppZunbeltz.value = Locale(codigo);
}
