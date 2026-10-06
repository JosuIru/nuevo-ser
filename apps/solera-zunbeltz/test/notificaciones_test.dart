// Qué se notifica tras sincronizar, tareas vencidas y descripción de la
// actividad del espacio.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/entrada_actividad.dart';
import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';
import 'package:solera_zunbeltz/servicios/politica_espacio.dart';
import 'package:solera_zunbeltz/servicios/resumen_notificaciones.dart';
import 'package:solera_zunbeltz/utiles/descripcion_actividad.dart';

PoliticaEspacio politica(String uid, Set<String> capacidades) => PoliticaEspacio(
    SesionEspacio(persona: PersonaEspacio(uid: uid, nombre: uid), capacidades: capacidades));

ResultadoSyncZunbeltz resultado({
  List<Map<String, Object?>> entidades = const [],
  List<EntradaActividad> actividad = const [],
}) =>
    ResultadoSyncZunbeltz(
      subidas: 0,
      bajadas: 0,
      omitidasFincaDesconocida: 0,
      rechazadasPorPermisos: 0,
      sesionRemota: SesionRemota(
          sesion: SesionEspacio(
              persona: const PersonaEspacio(uid: 'x', nombre: 'x'), capacidades: const {}),
          personas: const []),
      entidadesNuevasRecibidas: entidades,
      actividadNueva: actividad,
    );

Map<String, Object?> aviso(String uid, String autor, {String gravedad = 'alarma', String estado = 'abierto'}) => {
      'tipo': 'aviso',
      'uid': uid,
      'autor_uid': autor,
      'datos': {'titulo': 'Oveja coja', 'gravedad': gravedad, 'estado': estado},
    };

void main() {
  final coordinacion = politica('coord', {capacidadGestionarPeticiones, capacidadVerActividad, capacidadGestionarProyectos});
  final ane = politica('ane', const {});

  test('suenan las alarmas abiertas de otras personas, una sola vez', () {
    final r = resultado(entidades: [
      aviso('a1', 'jon'),
      aviso('a2', 'ane'),
      aviso('a3', 'jon', gravedad: 'aviso'),
      aviso('a4', 'jon', estado: 'resuelto'),
    ]);
    expect(resumirParaNotificar(r, ane).alarmas, ['Oveja coja']);
    expect(resumirParaNotificar(r, ane, yaNotificadas: {'aviso|a1'}).alarmas, isEmpty);
  });

  test('peticiones nuevas solo para quien las gestiona', () {
    final r = resultado(entidades: [
      {'tipo': 'peticion', 'uid': 'p1', 'autor_uid': 'ane', 'datos': {'estado': 'pendiente'}},
    ]);
    expect(resumirParaNotificar(r, coordinacion).peticionesNuevas, 1);
    expect(resumirParaNotificar(r, ane).peticionesNuevas, 0);
  });

  test('la actividad ajena llega a coordinación; la propia no', () {
    final r = resultado(actividad: const [
      EntradaActividad(id: 1, momentoMs: 0, personaUid: 'ane', accion: 'mover'),
      EntradaActividad(id: 2, momentoMs: 0, personaUid: 'coord', accion: 'crear'),
    ]);
    expect(resumirParaNotificar(r, coordinacion).actividadAjena.map((e) => e.id), [1]);
    expect(resumirParaNotificar(r, ane).actividadAjena, isEmpty);
  });

  test('tareas vencidas: las mías y las generales; coordinación, todas', () {
    final ahora = DateTime(2026, 10, 6, 12);
    final ayer = DateTime(2026, 10, 5).millisecondsSinceEpoch;
    final tareas = [
      TareaMantenimiento(fincaId: 1, responsableUid: 'ane', fechaObjetivoMs: ayer),
      TareaMantenimiento(fincaId: 1, fechaObjetivoMs: ayer),
      TareaMantenimiento(fincaId: 1, responsableUid: 'jon', fechaObjetivoMs: ayer),
      TareaMantenimiento(fincaId: 1, responsableUid: 'ane', fechaObjetivoMs: ayer, estado: 'hecha'),
      TareaMantenimiento(
          fincaId: 1, responsableUid: 'ane', fechaObjetivoMs: DateTime(2026, 10, 6, 8).millisecondsSinceEpoch),
    ];
    expect(contarTareasVencidas(tareas, ahora, ane), 2, reason: 'hoy todavía no está vencida');
    expect(contarTareasVencidas(tareas, ahora, coordinacion), 3);
    expect(contarTareasProximas(tareas, ahora), 1);
  });

  test('describir la actividad en castellano', () async {
    final textos = await AppLocalizations.delegate.load(const Locale('es'));
    expect(
      describirActividad(
          const EntradaActividad(
              id: 1, momentoMs: 0, personaNombre: 'Ane', accion: 'mover',
              tipo: 'punto', etiqueta: 'Corral móvil', contexto: 'Zunbeltz'),
          textos, 'es'),
      'Ane ha movido el punto «Corral móvil» en Zunbeltz',
    );
    expect(
      describirActividad(
          const EntradaActividad(
              id: 2, momentoMs: 0, personaNombre: 'Pablo', accion: 'estado',
              tipo: 'tarea', etiqueta: 'Revisar vallado', detalle: 'hecha', origen: 'panel'),
          textos, 'es'),
      'Pablo ha marcado la tarea «Revisar vallado» como «Hecha» desde la oficina',
    );
  });
}
