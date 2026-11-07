// Paridad con el servidor: la app decide qué acciones valen y genera con
// esas decisiones `social/wp-plugin/concejo/tests/paridad.json`, que el
// test de PHP (`php tests/test_paridad.php`) repite contra la lógica del
// plugin. Si una regla cambia en un lado y no en el otro, falla uno de los
// dos.
//
// El fichero se regenera con CONCEJO_REGENERAR=1; sin eso, este test
// comprueba que está al día.
import 'dart:convert';
import 'dart:io';

import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/datos/json_dominio.dart';
import 'package:concejo/dominio/asunto.dart';
import 'package:concejo/dominio/reglas_decision.dart';
import 'package:concejo/dominio/sesion.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);
const _ruta = '../../wp-plugin/concejo/tests/paridad.json';

typedef _Paso = (String persona, TipoAccion tipo, Json datos);

Asunto _borrador(String uid, {String titulo = 'Arreglar la fuente'}) => Asunto(
      uid: uid,
      titulo: titulo,
      resumen: titulo.isEmpty ? '' : 'El caño gotea desde el invierno.',
      efectoEntorno: titulo.isEmpty ? '' : 'Se pierde menos agua.',
      reglas: const ReglasDecision(forma: FormaDecision.votacion),
      inicioDebate: DateTime(2026, 11, 12),
      inicioDecision: DateTime(2026, 11, 20),
      finDecision: DateTime(2026, 11, 27),
    );

const _fecha = '2026-12-01T00:00:00.000';

Json _sesionNueva({
  String uid = 'nueva',
  String lugar = 'Frontón cubierto',
  String? asuntoUid = 'comunal',
  bool dosPuntosIguales = false,
}) =>
    sesionAJson(Sesion(
      uid: uid,
      titulo: 'Asamblea extraordinaria',
      inicio: DateTime(2026, 11, 14, 19),
      lugar: lugar,
      puntos: [
        PuntoOrdenDia(uid: 'n1', texto: 'Leña del comunal', asuntoUid: asuntoUid),
        PuntoOrdenDia(
            uid: 'n2',
            texto: dosPuntosIguales ? 'leña del comunal' : 'Ruegos y preguntas'),
      ],
    ));

// dart format off
/// Cada caso empieza en el pueblo de ejemplo y aplica sus pasos en orden.
final Map<String, List<_Paso>> _casos = {
  'votar sí': [
    (
      'maite',
      TipoAccion.votar,
      {
        'asunto_uid': 'fiestas',
        'opciones': ['si']
      }
    ),
    (
      'maite',
      TipoAccion.votar,
      {
        'asunto_uid': 'fiestas',
        'opciones': ['no']
      }
    ),
  ],
  'papeleta con dos marcas': [
    (
      'maite',
      TipoAccion.votar,
      {
        'asunto_uid': 'fiestas',
        'opciones': ['si', 'no']
      }
    ),
  ],
  'opción que no existe': [
    (
      'maite',
      TipoAccion.votar,
      {
        'asunto_uid': 'txoko',
        'opciones': ['25']
      }
    ),
  ],
  'votar fuera de plazo': [
    (
      'maite',
      TipoAccion.votar,
      {
        'asunto_uid': 'presupuesto',
        'opciones': ['fuente']
      }
    ),
  ],
  'aportar': [
    (
      'maite',
      TipoAccion.aportar,
      {
        'uid': 'ap1',
        'asunto_uid': 'fiestas',
        'tipo': 'duda',
        'texto': '¿Y la charanga?',
        'anonima': false
      }
    ),
    (
      'maite',
      TipoAccion.aportar,
      {
        'uid': 'ap2',
        'asunto_uid': 'fiestas',
        'tipo': 'aFavor',
        'texto': 'Sí',
        'responde_a_uid': 'ap1'
      }
    ),
    (
      'maite',
      TipoAccion.aportar,
      {
        'uid': 'ap3',
        'asunto_uid': 'fiestas',
        'tipo': 'aFavor',
        'texto': 'Y más',
        'responde_a_uid': 'ap2'
      }
    ),
    (
      'maite',
      TipoAccion.aportar,
      {
        'uid': 'ap1',
        'asunto_uid': 'fiestas',
        'tipo': 'duda',
        'texto': 'Repetida'
      }
    ),
    (
      'maite',
      TipoAccion.aportar,
      {'uid': 'ap4', 'asunto_uid': 'fiestas', 'tipo': 'duda', 'texto': '   '}
    ),
  ],
  'aportar con el debate cerrado': [
    (
      'maite',
      TipoAccion.aportar,
      {'uid': 'ap1', 'asunto_uid': 'txoko', 'tipo': 'duda', 'texto': 'Tarde'}
    ),
  ],
  'recoger lo dicho en persona': [
    (
      'maite',
      TipoAccion.aportar,
      {
        'uid': 'ap1',
        'asunto_uid': 'fiestas',
        'tipo': 'duda',
        'texto': 'x',
        'en_nombre_de_uid': 'josean'
      }
    ),
    (
      'ane',
      TipoAccion.aportar,
      {
        'uid': 'ap2',
        'asunto_uid': 'fiestas',
        'tipo': 'duda',
        'texto': 'x',
        'en_nombre_de_uid': 'josean'
      }
    ),
    (
      'ane',
      TipoAccion.objetar,
      {
        'uid': 'ob2',
        'asunto_uid': 'comunal',
        'motivo': 'Lo dijo en el concejo',
        'en_nombre_de_uid': 'pili'
      }
    ),
  ],
  'moderar': [
    (
      'maite',
      TipoAccion.aportar,
      {
        'uid': 'ap1',
        'asunto_uid': 'fiestas',
        'tipo': 'duda',
        'texto': 'Sin nombre',
        'anonima': true
      }
    ),
    (
      'maite',
      TipoAccion.moderar,
      {'asunto_uid': 'fiestas', 'aportacion_uid': 'ap1', 'estado': 'visible'}
    ),
    (
      'ane',
      TipoAccion.moderar,
      {
        'asunto_uid': 'fiestas',
        'aportacion_uid': 'ap1',
        'estado': 'retirada',
        'motivo': ''
      }
    ),
    (
      'ane',
      TipoAccion.moderar,
      {'asunto_uid': 'fiestas', 'aportacion_uid': 'ap1', 'estado': 'pendiente'}
    ),
    (
      'ane',
      TipoAccion.moderar,
      {'asunto_uid': 'fiestas', 'aportacion_uid': 'ap1', 'estado': 'visible'}
    ),
  ],
  'objeciones': [
    (
      'maite',
      TipoAccion.objetar,
      {'uid': 'ob2', 'asunto_uid': 'comunal', 'motivo': ''}
    ),
    (
      'maite',
      TipoAccion.objetar,
      {'uid': 'ob2', 'asunto_uid': 'fiestas', 'motivo': 'No es consentimiento'}
    ),
    (
      'maite',
      TipoAccion.objetar,
      {'uid': 'o1', 'asunto_uid': 'comunal', 'motivo': 'Uid repetido'}
    ),
    (
      'maite',
      TipoAccion.resolverObjecion,
      {
        'asunto_uid': 'comunal',
        'objecion_uid': 'o1',
        'estado': 'retirada',
        'respuesta': ''
      }
    ),
    (
      'ane',
      TipoAccion.resolverObjecion,
      {
        'asunto_uid': 'comunal',
        'objecion_uid': 'o1',
        'estado': 'integrada',
        'respuesta': ''
      }
    ),
    (
      'josean',
      TipoAccion.resolverObjecion,
      {
        'asunto_uid': 'comunal',
        'objecion_uid': 'o1',
        'estado': 'retirada',
        'respuesta': ''
      }
    ),
    ('maite', TipoAccion.cerrarRondaConsentimiento, {'asunto_uid': 'comunal'}),
    ('ane', TipoAccion.cerrarRondaConsentimiento, {'asunto_uid': 'comunal'}),
    ('ane', TipoAccion.cerrarRondaConsentimiento, {'asunto_uid': 'comunal'}),
  ],
  'dos vueltas con la objeción viva': [
    ('ane', TipoAccion.cerrarRondaConsentimiento, {'asunto_uid': 'comunal'}),
    ('ane', TipoAccion.cerrarRondaConsentimiento, {'asunto_uid': 'comunal'}),
    (
      'maite',
      TipoAccion.objetar,
      {'uid': 'ob2', 'asunto_uid': 'comunal', 'motivo': 'Tarde'}
    ),
  ],
  'borradores': [
    (
      'maite',
      TipoAccion.guardarBorrador,
      {'asunto': asuntoAJson(_borrador('nuevo'))}
    ),
    (
      'ane',
      TipoAccion.guardarBorrador,
      {'asunto': asuntoAJson(_borrador('vacio', titulo: ''))}
    ),
    ('ane', TipoAccion.abrirAsunto, {'asunto_uid': 'vacio'}),
    ('ane', TipoAccion.borrarBorrador, {'asunto_uid': 'vacio'}),
    (
      'ane',
      TipoAccion.guardarBorrador,
      {'asunto': asuntoAJson(_borrador('nuevo'))}
    ),
    ('ane', TipoAccion.abrirAsunto, {'asunto_uid': 'nuevo'}),
    (
      'ane',
      TipoAccion.guardarBorrador,
      {'asunto': asuntoAJson(_borrador('nuevo'))}
    ),
    ('ane', TipoAccion.borrarBorrador, {'asunto_uid': 'nuevo'}),
    ('ane', TipoAccion.abrirAsunto, {'asunto_uid': 'nuevo'}),
  ],
  'papel': [
    ('maite', TipoAccion.darDeAlta, {'uid': 'pe1', 'nombre': 'Maritxu'}),
    ('ane', TipoAccion.darDeAlta, {'uid': 'pe1', 'nombre': '  '}),
    ('ane', TipoAccion.darDeAlta, {'uid': 'pe1', 'nombre': 'Maritxu'}),
    ('ane', TipoAccion.darDeAlta, {'uid': 'pe1', 'nombre': 'Otra'}),
    (
      'ane',
      TipoAccion.anotarVotoPresencial,
      {'asunto_uid': 'fiestas', 'persona_uid': 'pe1'}
    ),
    (
      'ane',
      TipoAccion.anotarVotoPresencial,
      {'asunto_uid': 'fiestas', 'persona_uid': 'pe1'}
    ),
    (
      'pe1',
      TipoAccion.votar,
      {
        'asunto_uid': 'fiestas',
        'opciones': ['si']
      }
    ),
    (
      'ane',
      TipoAccion.anotarVotoPresencial,
      {'asunto_uid': 'presupuesto', 'persona_uid': 'pili'}
    ),
    (
      'ane',
      TipoAccion.registrarConteoPresencial,
      {
        'asunto_uid': 'fiestas',
        'papeletas_totales': 1,
        'marcas': {'si': 1},
        'segunda_firma_uid': 'ane'
      }
    ),
    (
      'ane',
      TipoAccion.registrarConteoPresencial,
      {
        'asunto_uid': 'fiestas',
        'papeletas_totales': 1,
        'marcas': {'si': 1},
        'segunda_firma_uid': 'maite'
      }
    ),
    (
      'ane',
      TipoAccion.registrarConteoPresencial,
      {
        'asunto_uid': 'fiestas',
        'papeletas_totales': 1,
        'marcas': {'si': -1},
        'segunda_firma_uid': 'mikel'
      }
    ),
    (
      'ane',
      TipoAccion.registrarConteoPresencial,
      {
        'asunto_uid': 'fiestas',
        'papeletas_totales': 1,
        'marcas': {'si': 1},
        'segunda_firma_uid': 'mikel'
      }
    ),
    (
      'ane',
      TipoAccion.registrarConteoPresencial,
      {
        'asunto_uid': 'presupuesto',
        'papeletas_totales': 0,
        'marcas': <String, int>{},
        'segunda_firma_uid': 'mikel'
      }
    ),
  ],
  'compromisos': [
    (
      'maite',
      TipoAccion.anadirCompromiso,
      {
        'uid': 'co1',
        'asunto_uid': 'txoko',
        'que': 'Cartel',
        'responsable': 'Iker',
        'fecha_limite': _fecha
      }
    ),
    (
      'ane',
      TipoAccion.anadirCompromiso,
      {
        'uid': 'co1',
        'asunto_uid': 'txoko',
        'que': ' ',
        'responsable': 'Iker',
        'fecha_limite': _fecha
      }
    ),
    (
      'ane',
      TipoAccion.anadirCompromiso,
      {
        'uid': 'co1',
        'asunto_uid': 'txoko',
        'que': 'Cartel',
        'responsable': 'Iker',
        'fecha_limite': _fecha
      }
    ),
    (
      'ane',
      TipoAccion.anadirCompromiso,
      {
        'uid': 'co1',
        'asunto_uid': 'txoko',
        'que': 'Otro',
        'responsable': 'Iker',
        'fecha_limite': _fecha
      }
    ),
    (
      'ane',
      TipoAccion.cambiarEstadoCompromiso,
      {'compromiso_uid': 'co1', 'estado': 'noSeHara', 'nota': ''}
    ),
    (
      'maite',
      TipoAccion.cambiarEstadoCompromiso,
      {'compromiso_uid': 'co1', 'estado': 'hecho', 'nota': ''}
    ),
    (
      'ane',
      TipoAccion.cambiarEstadoCompromiso,
      {'compromiso_uid': 'co1', 'estado': 'hecho', 'nota': ''}
    ),
  ],
  'acta': [
    ('maite', TipoAccion.firmarActa, {'asunto_uid': 'txoko'}),
    ('ane', TipoAccion.firmarActa, {'asunto_uid': 'fiestas'}),
    ('ane', TipoAccion.firmarActa, {'asunto_uid': 'txoko'}),
    ('ane', TipoAccion.firmarActa, {'asunto_uid': 'txoko'}),
    (
      'ane',
      TipoAccion.resumirDebate,
      {'asunto_uid': 'txoko', 'resumen': 'Otro'}
    ),
    (
      'ane',
      TipoAccion.registrarConteoPresencial,
      {
        'asunto_uid': 'txoko',
        'papeletas_totales': 0,
        'marcas': <String, int>{},
        'segunda_firma_uid': 'mikel'
      }
    ),
    ('mikel', TipoAccion.retirarFirmaActa, {'asunto_uid': 'txoko'}),
    ('ane', TipoAccion.retirarFirmaActa, {'asunto_uid': 'txoko'}),
    ('ane', TipoAccion.firmarActa, {'asunto_uid': 'txoko'}),
    ('mikel', TipoAccion.firmarActa, {'asunto_uid': 'txoko'}),
    ('ane', TipoAccion.retirarFirmaActa, {'asunto_uid': 'txoko'}),
    ('ane', TipoAccion.firmarActa, {'asunto_uid': 'comunal'}),
  ],
  'asambleas': [
    ('maite', TipoAccion.convocarSesion, {'sesion': _sesionNueva()}),
    ('ane', TipoAccion.convocarSesion, {'sesion': _sesionNueva()}),
    ('ane', TipoAccion.convocarSesion, {'sesion': _sesionNueva(asuntoUid: 'no-existe')}),
    ('ane', TipoAccion.convocarSesion, {'sesion': _sesionNueva(lugar: ' ')}),
    ('ane', TipoAccion.convocarSesion, {'sesion': _sesionNueva(dosPuntosIguales: true)}),
    ('ane', TipoAccion.convocarSesion, {'sesion': _sesionNueva(uid: 'octubre')}),
    ('ane', TipoAccion.convocarSesion, {'sesion': _sesionNueva(lugar: 'Frontón')}),
    ('ane', TipoAccion.anularSesion, {'sesion_uid': 'noviembre', 'motivo': ' '}),
    ('ane', TipoAccion.anularSesion, {'sesion_uid': 'noviembre', 'motivo': 'Coincide con el funeral'}),
    ('ane', TipoAccion.anularSesion, {'sesion_uid': 'noviembre', 'motivo': 'Otra vez'}),
    ('ane', TipoAccion.anularSesion, {'sesion_uid': 'octubre', 'motivo': 'Tarde'}),
    ('ane', TipoAccion.anotarAsistencia, {'sesion_uid': 'noviembre', 'persona_uid': 'pili', 'presente': true}),
    ('ane', TipoAccion.anotarAsistencia, {'sesion_uid': 'nueva', 'persona_uid': 'pili', 'presente': true}),
    ('maite', TipoAccion.anotarAsistencia, {'sesion_uid': 'octubre', 'persona_uid': 'pili', 'presente': true}),
    ('ane', TipoAccion.anotarAsistencia, {'sesion_uid': 'octubre', 'persona_uid': 'nadie', 'presente': true}),
    ('ane', TipoAccion.anotarAsistencia, {'sesion_uid': 'octubre', 'persona_uid': 'pili', 'presente': true}),
    ('ane', TipoAccion.anotarAsistencia, {'sesion_uid': 'octubre', 'persona_uid': 'maite', 'presente': false}),
    ('ane', TipoAccion.anotarAsistencia, {'sesion_uid': 'no-existe', 'persona_uid': 'pili', 'presente': true}),
    ('ane', TipoAccion.anotarAsistentesSinApp, {'sesion_uid': 'octubre', 'cantidad': -1}),
    ('ane', TipoAccion.anotarAsistentesSinApp, {'sesion_uid': 'octubre', 'cantidad': 12}),
    ('ane', TipoAccion.anotarNotasPunto, {'sesion_uid': 'octubre', 'punto_uid': 'no-existe', 'notas': 'x'}),
    ('ane', TipoAccion.anotarNotasPunto, {'sesion_uid': 'octubre', 'punto_uid': 'oc2', 'notas': ' La fuente ya es asunto. '}),
  ],
};
// dart format on

Json _generar() {
  final casos = <Json>[];
  _casos.forEach((nombre, pasos) {
    final estado = estadoDeEjemplo(hoy: _hoy);
    final resultados = <Json>[];
    for (final (indice, (persona, tipo, datos)) in pasos.indexed) {
      final accion = AccionConcejo(
        uid: '$nombre-$indice',
        tipo: tipo,
        autorUid: persona,
        momento: _hoy,
        datos: datos,
      );
      var aceptada = true;
      try {
        estado
          ..verComo(persona)
          ..rehacer(accion);
      } catch (_) {
        aceptada = false;
      }
      resultados.add({'accion': accion.aJson(), 'aceptada': aceptada});
    }
    casos.add({'nombre': nombre, 'pasos': resultados});
  });
  return {
    'hoy': _hoy.toIso8601String(),
    'inicial': instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
    'casos': casos,
  };
}

void main() {
  test('el fichero de paridad con el servidor está al día', () {
    final texto = '${const JsonEncoder.withIndent('  ').convert(_generar())}\n';
    final fichero = File(_ruta);
    if (Platform.environment['CONCEJO_REGENERAR'] == '1') {
      fichero.writeAsStringSync(texto);
    }
    expect(fichero.existsSync(), isTrue,
        reason: 'Genéralo con CONCEJO_REGENERAR=1 flutter test $_ruta');
    expect(fichero.readAsStringSync(), texto,
        reason: 'Las reglas han cambiado: regenera con CONCEJO_REGENERAR=1 '
            'y pasa php tests/test_paridad.php');
  });
}
