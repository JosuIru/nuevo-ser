import 'package:concejo/dominio/asunto.dart';
import 'package:concejo/dominio/compromiso.dart';
import 'package:concejo/dominio/consentimiento.dart';
import 'package:concejo/dominio/debate.dart';
import 'package:concejo/dominio/reglas_decision.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

Asunto _borrador(String uid, {String efecto = 'Ninguno'}) => Asunto(
      uid: uid,
      titulo: 'Arreglar el camino del cementerio',
      resumen: 'Echar zahorra en los baches.',
      efectoEntorno: efecto,
      reglas: const ReglasDecision(forma: FormaDecision.votacion),
      inicioDebate: DateTime(2026, 11, 12),
      inicioDecision: DateTime(2026, 11, 20),
      finDecision: DateTime(2026, 11, 27),
    );

void main() {
  group('lo que solo hace la mesa', () {
    test('una vecina no crea asuntos, no modera ni apunta compromisos', () {
      final estado = estadoDeEjemplo(hoy: _hoy)..verComo('maite');
      expect(estado.soyMesa, isFalse);
      expect(() => estado.guardarBorrador(_borrador('b1')), throwsStateError);
      expect(() => estado.resumirDebate('fiestas', 'x'), throwsStateError);
      expect(
        () => estado.anadirCompromiso(
            asuntoUid: 'txoko', que: 'x', responsable: 'y', fechaLimite: _hoy),
        throwsStateError,
      );
      expect(
          () => estado.cerrarRondaConsentimiento('comunal'), throwsStateError);
    });

    test('los borradores solo los ve la mesa', () {
      final estado = estadoDeEjemplo(hoy: _hoy)
        ..guardarBorrador(_borrador('b1'));
      expect(estado.asuntosEnFase(FaseAsunto.borrador), hasLength(1));
      estado.verComo('maite');
      expect(estado.asuntosEnFase(FaseAsunto.borrador), isEmpty);
    });
  });

  group('borradores', () {
    test('se editan mientras no estén abiertos, y al abrirlos quedan fijos',
        () {
      final estado = estadoDeEjemplo(hoy: _hoy)
        ..guardarBorrador(_borrador('b1'));
      estado.guardarBorrador(_borrador('b1').conReglas(const ReglasDecision(
          forma: FormaDecision.votacion, quorumPersonas: 10)));
      expect(estado.asunto('b1').reglas.quorumPersonas, 10);
      expect(estado.asunto('b1').creadoPorUid, 'ane');

      estado.abrirAsunto('b1');
      expect(estado.asunto('b1').faseEn(_hoy), FaseAsunto.debate);
      expect(() => estado.guardarBorrador(_borrador('b1')), throwsStateError);
      expect(() => estado.borrarBorrador('b1'), throwsStateError);
    });

    test('no se abre si falta el efecto sobre el entorno', () {
      final estado = estadoDeEjemplo(hoy: _hoy)
        ..guardarBorrador(_borrador('b1', efecto: ''));
      expect(() => estado.abrirAsunto('b1'), throwsStateError);
      expect(estado.asunto('b1').abierto, isFalse);
    });
  });

  group('debate', () {
    test('la mesa publica una anónima o la retira con motivo', () {
      final estado = estadoDeEjemplo(hoy: _hoy)..verComo('iker');
      estado.aportar('fiestas', TipoAportacion.enContra, 'Sin mi nombre',
          anonima: true);
      final pendiente = estado.debate('fiestas').pendientesDeModerar.single;
      estado.verComo('ane');
      expect(
          () => estado.moderar(
              'fiestas', pendiente.uid, EstadoModeracion.retirada),
          throwsArgumentError);
      estado.moderar('fiestas', pendiente.uid, EstadoModeracion.visible);
      expect(estado.debate('fiestas').pendientesDeModerar, isEmpty);
      expect(
          estado.debate('fiestas').columna(TipoAportacion.enContra).last.texto,
          'Sin mi nombre');
    });

    test('una retirada deja el hueco con el motivo', () {
      final estado = estadoDeEjemplo(hoy: _hoy)
        ..moderar('fiestas', 'f2', EstadoModeracion.retirada,
            motivo: 'Datos personales de un vecino');
      final retirada =
          estado.debate('fiestas').columna(TipoAportacion.enContra).single;
      expect(retirada.estado, EstadoModeracion.retirada);
      expect(retirada.motivoRetirada, 'Datos personales de un vecino');
    });
  });

  group('consentimiento', () {
    test(
        'la mesa integra, solo quien objetó retira, y al cerrar queda decidido',
        () {
      final estado = estadoDeEjemplo(hoy: _hoy);
      // La objeción del ejemplo es de Josean: Ane (mesa) no la puede retirar.
      expect(
        () => estado.resolverObjecion(
            'comunal', 'o1', EstadoObjecion.retirada, ''),
        throwsStateError,
      );
      estado.resolverObjecion('comunal', 'o1', EstadoObjecion.integrada,
          'Las casas que solo se calientan con leña pueden pedir un segundo lote');
      expect(estado.cerrarRondaConsentimiento('comunal'),
          DesenlaceConsentimiento.aprobada);
      expect(estado.consentimiento('comunal').decidido, isTrue);
      expect(() => estado.objetar('comunal', 'Tarde'), throwsStateError);
    });
  });

  test('compromisos: la mesa los apunta y los cierra', () {
    final estado = estadoDeEjemplo(hoy: _hoy)
      ..anadirCompromiso(
        asuntoUid: 'txoko',
        que: 'Comprar cerradura con llave para el local',
        responsable: 'Pili',
        fechaLimite: DateTime(2026, 12, 1),
      );
    final nuevo = estado.compromisosDe('txoko').last;
    estado.cambiarEstadoCompromiso(nuevo.uid, EstadoCompromiso.noSeHara,
        nota: 'Ya tenía una');
    expect(
        estado.compromisosDe('txoko').last.estado, EstadoCompromiso.noSeHara);
  });
}
