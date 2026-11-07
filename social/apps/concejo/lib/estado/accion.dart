/// Cada cambio que hace alguien en Concejo es una acción con sus datos. La
/// app la aplica al momento y la guarda en cola; el servidor del pueblo la
/// vuelve a comprobar y la aplica (o la rechaza) con sus propias reglas.
///
/// Se sube la acción y no el resultado para que el servidor pueda guardar
/// el voto secreto separado de quien vota y para que no haya conflictos de
/// «quién escribió último»: dos personas que aportan a la vez son dos
/// acciones, no dos versiones del mismo debate.
library;

import '../datos/json_dominio.dart';

enum TipoAccion {
  votar,
  aportar,
  objetar,
  cambiarEstadoCompromiso,
  guardarBorrador,
  abrirAsunto,
  borrarBorrador,
  moderar,
  resumirDebate,
  resolverObjecion,
  cerrarRondaConsentimiento,
  anadirCompromiso,
  darDeAlta,
  anotarVotoPresencial,
  registrarConteoPresencial,
  firmarActa,
  retirarFirmaActa,
  convocarSesion,
  anularSesion,
  anotarAsistencia,
  anotarAsistentesSinApp,
  anotarNotasPunto,
  publicarAnuncio,
  retirarAnuncio,
  fijarAnuncio,
}

class AccionConcejo {
  const AccionConcejo({
    required this.uid,
    required this.tipo,
    required this.autorUid,
    required this.momento,
    required this.datos,
  });

  /// Lo genera la app: si la misma acción llega dos veces (se cortó la red
  /// a mitad), el servidor la aplica una sola.
  final String uid;
  final TipoAccion tipo;
  final String autorUid;
  final DateTime momento;
  final Json datos;

  Json aJson() => {
        'uid': uid,
        'tipo': tipo.name,
        'autor_uid': autorUid,
        'momento': momento.toUtc().toIso8601String(),
        'datos': datos,
      };

  static AccionConcejo desdeJson(Json json) => AccionConcejo(
        uid: json['uid'] as String,
        tipo: TipoAccion.values.byName(json['tipo'] as String),
        autorUid: json['autor_uid'] as String,
        momento: DateTime.parse(json['momento'] as String),
        datos: json['datos'] as Json,
      );
}
