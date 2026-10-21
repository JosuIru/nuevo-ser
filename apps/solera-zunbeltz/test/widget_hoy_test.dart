// Widget «Hoy en Zunbeltz» de Android: lo que se compone en Dart (los
// textos ya traducidos que pinta el lado nativo) y los enlaces de sus
// botones.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/aviso_campo.dart';
import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/politica_espacio.dart';
import 'package:solera_zunbeltz/servicios/servicio_meteo.dart';
import 'package:solera_zunbeltz/servicios/widget_hoy.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  final ahora = DateTime(2026, 10, 17, 10, 42);
  int ms(DateTime fecha) => fecha.millisecondsSinceEpoch;
  final textos = lookupAppLocalizations(const Locale('es'));
  const modoLocal = PoliticaEspacio(null);
  final tester = PoliticaEspacio(SesionEspacio(
    persona: PersonaEspacio(uid: 'ana', nombre: 'Ana'),
    capacidades: {capacidadRegistrarGanado},
  ));

  ContenidoWidgetHoy componer({
    PoliticaEspacio politica = modoLocal,
    List<AvisoCampo> avisos = const [],
    List<TareaMantenimiento> tareas = const [],
    List<DateTime> libres = const [],
    PrevisionMeteo? prevision,
    String idioma = 'es',
  }) =>
      componerWidgetHoy(
        textos: lookupAppLocalizations(Locale(idioma)),
        idioma: idioma,
        ahora: ahora,
        politica: politica,
        avisos: avisos,
        tareas: tareas,
        libresDeSupresion: libres,
        prevision: prevision,
      );

  test('enlaces de los botones', () {
    expect(accionDesdeEnlaceWidget(Uri.parse('zunbeltz://mover-lote')),
        AccionWidgetHoy.moverLote);
    expect(accionDesdeEnlaceWidget(Uri.parse('zunbeltz://apuntar-cura')),
        AccionWidgetHoy.apuntarCura);
    expect(accionDesdeEnlaceWidget(Uri.parse('zunbeltz://nuevo-aviso')),
        AccionWidgetHoy.nuevoAviso);
    expect(accionDesdeEnlaceWidget(Uri.parse('zunbeltz://hoy')),
        AccionWidgetHoy.hoy);
    expect(accionDesdeEnlaceWidget(Uri.parse('https://hoy')), isNull);
    expect(accionDesdeEnlaceWidget(Uri.parse('zunbeltz://otra')), isNull);
    expect(accionDesdeEnlaceWidget(null), isNull);
  });

  test('sin nada: sin alarmas, sin supresión y sin tiempo', () {
    final contenido = componer();
    expect(contenido.titulo, 'Hoy en Zunbeltz');
    expect(contenido.actualizado, 'Act. 10:42');
    expect(contenido.alarmas, isEmpty);
    expect(contenido.tareas, 'Ninguna tarea vencida · nada para hoy');
    expect(contenido.tareasUrgentes, isFalse);
    expect(contenido.supresion, 'Ningún rebaño en supresión');
    expect(contenido.hayLotesEnSupresion, isFalse);
    expect(contenido.tiempo, 'Sin previsión guardada');
    expect(contenido.puedeDarAvisos, isTrue);
  });

  test('alarmas abiertas: la última arriba; los avisos y cerradas no', () {
    final contenido = componer(avisos: [
      AvisoCampo(
          gravedad: gravedadAlarma,
          titulo: 'Valla rota',
          fechaMs: ms(DateTime(2026, 10, 16))),
      AvisoCampo(
          gravedad: gravedadAlarma,
          titulo: 'Oveja coja',
          fechaMs: ms(DateTime(2026, 10, 17))),
      AvisoCampo(titulo: 'Aviso normal', fechaMs: ms(ahora)),
      AvisoCampo(
          gravedad: gravedadAlarma,
          estado: estadoAvisoResuelto,
          titulo: 'Ya resuelta'),
    ]);
    expect(contenido.alarmas, '2 alarmas · Oveja coja');
  });

  test('tareas: vencidas y de hoy, de la tester solo las suyas y generales',
      () {
    TareaMantenimiento tarea(DateTime fecha,
            {String responsable = '', String estado = 'pendiente'}) =>
        TareaMantenimiento(
            fincaId: 1,
            fechaObjetivoMs: ms(fecha),
            responsableUid: responsable,
            estado: estado);
    final tareas = [
      tarea(DateTime(2026, 10, 15)),
      tarea(DateTime(2026, 10, 16), responsable: 'otra'),
      tarea(DateTime(2026, 10, 10), estado: 'hecha'),
      tarea(DateTime(2026, 10, 17, 18)),
      tarea(DateTime(2026, 10, 17, 8), responsable: 'ana'),
      tarea(DateTime(2026, 10, 18)),
    ];
    final todas = componer(tareas: tareas);
    expect(todas.tareas, '2 tareas vencidas · 2 para hoy');
    expect(todas.tareasUrgentes, isTrue);
    final deAna = componer(tareas: tareas, politica: tester);
    expect(deAna.tareas, '1 tarea vencida · 2 para hoy');
  });

  test('supresión: cuenta lote y animales que siguen en él', () {
    final libres = lotesEnSupresion(
      lotes: [
        LoteGanado(id: 1, nombre: 'Ovejas'),
        LoteGanado(id: 2, nombre: 'Vacas'),
        LoteGanado(id: 3, nombre: 'Cerrado', estado: estadoLoteCerrado),
        LoteGanado(id: 4, nombre: 'Sin tratar'),
      ],
      animales: [
        Animal(id: 10, loteId: 2),
        Animal(id: 11, loteId: 4, estado: 'vendido'),
      ],
      eventos: [
        // Al lote 1: carne 10 días, leche 20 (manda la leche).
        EventoGanado(
            loteId: 1,
            fechaMs: ms(DateTime(2026, 10, 15)),
            plazoSupresionCarneDias: 10,
            plazoSupresionLecheDias: 20),
        // A un animal del lote 2.
        EventoGanado(
            animalId: 10,
            loteId: 2,
            fechaMs: ms(DateTime(2026, 10, 16)),
            plazoSupresionCarneDias: 5),
        // Lote cerrado y animal dado de baja: no cuentan.
        EventoGanado(
            loteId: 3,
            fechaMs: ms(ahora),
            plazoSupresionCarneDias: 30),
        EventoGanado(
            animalId: 11,
            fechaMs: ms(ahora),
            plazoSupresionCarneDias: 30),
        // Ya pasado.
        EventoGanado(
            loteId: 4,
            fechaMs: ms(DateTime(2026, 9, 1)),
            plazoSupresionCarneDias: 10),
      ],
      ahora: ahora,
    );
    expect(libres, [DateTime(2026, 10, 21), DateTime(2026, 11, 4)]);
    final contenido = componer(libres: libres);
    expect(contenido.supresion,
        '2 rebaños en supresión · el primero, libre el 21/10');
    expect(contenido.hayLotesEnSupresion, isTrue);
  });

  test('el tiempo de hoy con sus avisos; una previsión vieja no vale', () {
    PrevisionMeteo prevision(DateTime dia) => PrevisionMeteo(
          latitud: 0,
          longitud: 0,
          actualizado: ahora,
          horas: const [],
          todosLosDias: [
            DiaMeteo(fecha: DateTime(2026, 10, 16), tempMin: 20),
            DiaMeteo(
                fecha: dia,
                tempMin: -1.4,
                tempMax: 9.6,
                lluviaMm: 2.35,
                rachaMaxKmh: 60),
          ],
        );
    expect(componer(prevision: prevision(DateTime(2026, 10, 17))).tiempo,
        'Hoy -1° / 10° · 2,4 mm · ${textos.avisoHelada} · ${textos.avisoViento}');
    expect(componer(prevision: prevision(DateTime(2026, 10, 18))).tiempo,
        'Sin previsión guardada');
  });

  test('en euskera y con permisos de tester', () {
    final contenido = componer(idioma: 'eu', politica: tester);
    expect(contenido.titulo, 'Gaur Zunbeltzen');
    expect(contenido.puedeDarAvisos, isFalse);
    expect(contenido.puedeManejarGanado, isTrue);
    expect(contenido.aPreferencias()['zw_puede_avisos'], isFalse);
  });
}
