import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/widgets.dart' show Locale;
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/idioma_app.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/aviso_campo.dart';
import '../modelos/ganado.dart';
import '../modelos/tarea_mantenimiento.dart';
import 'politica_espacio.dart';
import 'resumen_notificaciones.dart';
import 'servicio_meteo.dart';

/// Widget «Hoy en Zunbeltz» de la pantalla de inicio de Android: alarmas
/// abiertas, tareas, ganado en plazo de supresión y el tiempo de hoy, con
/// tres accesos directos (dar un aviso, mover un lote, apuntar una cura).
///
/// La app compone los textos ya traducidos y los deja en las preferencias
/// del widget; el lado nativo (`WidgetHoyZunbeltz.kt`) solo los pinta. Se
/// pone al día al cambiar datos con la app abierta y tras cada vuelta de la
/// sincronización en segundo plano (~15 min).
const String nombreProveedorWidgetHoy = 'WidgetHoyZunbeltz';

/// Enlaces que abren los botones del widget (ver [accionDesdeEnlaceWidget]).
const String esquemaEnlaceWidget = 'zunbeltz';

enum AccionWidgetHoy { hoy, ganado, nuevoAviso, moverLote, apuntarCura }

/// La acción de un enlace del widget (`zunbeltz://mover-lote`…); null si
/// no es del widget.
AccionWidgetHoy? accionDesdeEnlaceWidget(Uri? enlace) {
  if (enlace == null || enlace.scheme != esquemaEnlaceWidget) return null;
  return switch (enlace.host) {
    'hoy' => AccionWidgetHoy.hoy,
    'ganado' => AccionWidgetHoy.ganado,
    'nuevo-aviso' => AccionWidgetHoy.nuevoAviso,
    'mover-lote' => AccionWidgetHoy.moverLote,
    'apuntar-cura' => AccionWidgetHoy.apuntarCura,
    _ => null,
  };
}

/// Lo que pinta el widget, ya en el idioma de la app.
class ContenidoWidgetHoy {
  const ContenidoWidgetHoy({
    required this.titulo,
    required this.actualizado,
    required this.alarmas,
    required this.tareas,
    required this.tareasUrgentes,
    required this.supresion,
    required this.hayLotesEnSupresion,
    required this.tiempo,
    required this.botonAviso,
    required this.botonMover,
    required this.botonCura,
    required this.puedeDarAvisos,
    required this.puedeManejarGanado,
  });

  final String titulo;
  final String actualizado;

  /// Vacío si no hay alarmas abiertas (la fila roja se oculta).
  final String alarmas;
  final String tareas;
  final bool tareasUrgentes;
  final String supresion;
  final bool hayLotesEnSupresion;
  final String tiempo;
  final String botonAviso;
  final String botonMover;
  final String botonCura;
  final bool puedeDarAvisos;
  final bool puedeManejarGanado;

  /// Claves que lee el lado nativo.
  Map<String, Object> aPreferencias() => {
        'zw_titulo': titulo,
        'zw_actualizado': actualizado,
        'zw_alarmas': alarmas,
        'zw_tareas': tareas,
        'zw_tareas_urgentes': tareasUrgentes,
        'zw_supresion': supresion,
        'zw_supresion_activa': hayLotesEnSupresion,
        'zw_tiempo': tiempo,
        'zw_boton_aviso': botonAviso,
        'zw_boton_mover': botonMover,
        'zw_boton_cura': botonCura,
        'zw_puede_avisos': puedeDarAvisos,
        'zw_puede_ganado': puedeManejarGanado,
      };
}

/// Día en que queda libre cada lote en uso que está en plazo de supresión
/// (el más tardío de carne y leche), contando lo que se le ha hecho al lote
/// y a los animales que siguen en él. Ordenado del que antes queda libre.
List<DateTime> lotesEnSupresion({
  required List<LoteGanado> lotes,
  required List<Animal> animales,
  required List<EventoGanado> eventos,
  required DateTime ahora,
}) {
  final loteDeAnimal = {
    for (final animal in animales)
      if (animal.id != null && animal.activo && animal.loteId != null)
        animal.id!: animal.loteId!,
  };
  final eventosPorLote = <int, List<EventoGanado>>{};
  for (final evento in eventos) {
    final lote = evento.animalId == null
        ? evento.loteId
        : loteDeAnimal[evento.animalId];
    if (lote != null) (eventosPorLote[lote] ??= []).add(evento);
  }
  final libres = <DateTime>[];
  for (final lote in lotes) {
    if (lote.id == null || lote.estado == estadoLoteCerrado) continue;
    final supresion =
        supresionVigente(eventosPorLote[lote.id] ?? const [], ahora);
    if (!supresion.hayAlguna) continue;
    final carne = supresion.carneHasta;
    final leche = supresion.lecheHasta;
    libres.add(carne == null
        ? leche!
        : leche == null || carne.isAfter(leche)
            ? carne
            : leche);
  }
  return libres..sort();
}

/// Tareas sin hacer con fecha de hoy que le tocan a esta persona (mismo
/// criterio que [contarTareasVencidas]).
int contarTareasDeHoy(List<TareaMantenimiento> tareas, DateTime ahora,
    PoliticaEspacio politica) {
  final inicio = DateTime(ahora.year, ahora.month, ahora.day);
  final fin = DateTime(ahora.year, ahora.month, ahora.day + 1);
  return tareas.where((tarea) {
    final fecha = tarea.fechaObjetivoMs;
    if (fecha == null ||
        tarea.estado == 'hecha' ||
        fecha < inicio.millisecondsSinceEpoch ||
        fecha >= fin.millisecondsSinceEpoch) {
      return false;
    }
    return politica.modoLocal ||
        politica.puedeGestionarProyectos ||
        tarea.responsableUid.isEmpty ||
        tarea.responsableUid == politica.miUid;
  }).length;
}

/// Compone el widget. Pura: los datos llegan ya leídos.
ContenidoWidgetHoy componerWidgetHoy({
  required AppLocalizations textos,
  required String idioma,
  required DateTime ahora,
  required PoliticaEspacio politica,
  required List<AvisoCampo> avisos,
  required List<TareaMantenimiento> tareas,
  required List<DateTime> libresDeSupresion,
  PrevisionMeteo? prevision,
}) {
  final alarmas = avisos.where((aviso) => aviso.esAlarma && aviso.abierto)
      .toList()
    ..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));
  final vencidas = contarTareasVencidas(tareas, ahora, politica);
  final deHoy = contarTareasDeHoy(tareas, ahora, politica);
  final formatoDia = DateFormat('dd/MM', idioma);
  return ContenidoWidgetHoy(
    titulo: textos.widgetHoyTitulo,
    actualizado:
        textos.widgetActualizado(DateFormat('HH:mm', idioma).format(ahora)),
    alarmas: alarmas.isEmpty
        ? ''
        : textos.widgetAlarmas(alarmas.length, alarmas.first.titulo),
    tareas:
        '${textos.hoyTareasVencidas(vencidas)} · ${textos.widgetTareasHoy(deHoy)}',
    tareasUrgentes: vencidas > 0,
    supresion: textos.widgetSupresion(
        libresDeSupresion.length,
        libresDeSupresion.isEmpty
            ? ''
            : formatoDia.format(libresDeSupresion.first)),
    hayLotesEnSupresion: libresDeSupresion.isNotEmpty,
    tiempo: _describirTiempo(prevision, ahora, textos, idioma),
    botonAviso: textos.widgetBotonAviso,
    botonMover: textos.widgetBotonMover,
    botonCura: textos.widgetBotonCura,
    puedeDarAvisos: politica.puedeCrearAvisos,
    puedeManejarGanado: politica.puedeManejarAnimales,
  );
}

String _describirTiempo(PrevisionMeteo? prevision, DateTime ahora,
    AppLocalizations textos, String idioma) {
  final dias = prevision?.diasDesde(ahora) ?? const <DiaMeteo>[];
  if (dias.isEmpty ||
      dias.first.fecha != DateTime(ahora.year, ahora.month, ahora.day)) {
    return textos.widgetSinTiempo;
  }
  final hoy = dias.first;
  final numero = NumberFormat('0.#', idioma);
  String grados(double? valor) => valor == null ? '–' : valor.round().toString();
  final avisos = [
    if (hoy.tormenta) textos.avisoTormenta,
    if (hoy.nieve) textos.avisoNieve,
    if (hoy.riesgoHelada) textos.avisoHelada,
    if (hoy.vientoFuerte) textos.avisoViento,
    if (hoy.calorIntenso) textos.avisoCalor,
    if (hoy.estresCalor && !hoy.calorIntenso) textos.avisoEstresCalor,
  ];
  return [
    textos.widgetTiempo(grados(hoy.tempMin), grados(hoy.tempMax),
        numero.format(hoy.lluviaMm ?? 0)),
    ...avisos,
  ].join(' · ');
}

bool get _hayWidget => !kIsWeb && Platform.isAndroid;

/// Lee los datos, compone el widget y le pide a Android que lo repinte.
/// No falla nunca: el widget es una comodidad.
Future<void> actualizarWidgetHoy({ServicioMeteo? servicioMeteo}) async {
  if (!_hayWidget) return;
  try {
    final bd = BaseDatosSoleraZunbeltz();
    final ahora = DateTime.now();
    final idioma = localeAppZunbeltz.value?.languageCode ??
        (Platform.localeName.startsWith('eu') ? 'eu' : 'es');
    final textos = lookupAppLocalizations(Locale(idioma));
    final fincas = await bd.listarFincas();
    PrevisionMeteo? prevision;
    final finca = fincas.isEmpty
        ? null
        : fincas.firstWhere((f) => f.nombre.contains('Zunbeltz'),
            orElse: () => fincas.first);
    try {
      prevision = await (servicioMeteo ?? ServicioMeteo()).obtenerSiCaduca(
          latitud: finca?.latitud ?? 42.8226,
          longitud: finca?.longitud ?? -2.0315);
    } catch (_) {}
    final contenido = componerWidgetHoy(
      textos: textos,
      idioma: idioma,
      ahora: ahora,
      politica: politicaEspacioActual,
      avisos: await bd.listarAvisos(soloAbiertos: true),
      tareas: await bd.listarTareas(),
      libresDeSupresion: lotesEnSupresion(
        lotes: await bd.listarLotes(soloActivos: true),
        animales: await bd.listarAnimales(),
        eventos: await bd.listarEventosGanado(),
        ahora: ahora,
      ),
      prevision: prevision,
    );
    for (final MapEntry(:key, :value) in contenido.aPreferencias().entries) {
      if (value is bool) {
        await HomeWidget.saveWidgetData<bool>(key, value);
      } else {
        await HomeWidget.saveWidgetData<String>(key, value as String);
      }
    }
    await HomeWidget.updateWidget(androidName: nombreProveedorWidgetHoy);
  } catch (_) {
    // Sin BD o sin widget puesto: no pasa nada.
  }
}

Timer? _esperaActualizacion;

/// Con la app abierta: repinta el widget poco después de cada cambio de
/// datos (agrupando los cambios seguidos).
void escucharCambiosParaWidgetHoy() {
  if (!_hayWidget) return;
  notificadorDatos.addListener(programarActualizacionWidgetHoy);
  programarActualizacionWidgetHoy();
}

@visibleForTesting
const Duration esperaActualizacionWidget = Duration(seconds: 2);

void programarActualizacionWidgetHoy() {
  _esperaActualizacion?.cancel();
  _esperaActualizacion = Timer(esperaActualizacionWidget, actualizarWidgetHoy);
}
