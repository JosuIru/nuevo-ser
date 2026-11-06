import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  test('dos personas de la mesa firman el acta de un asunto cerrado', () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    expect(estado.actaLista('txoko'), isTrue);
    estado.firmarActa('txoko');
    expect(estado.acta('txoko').definitiva, isFalse);
    estado
      ..verComo('mikel')
      ..firmarActa('txoko');
    final acta = estado.acta('txoko');
    expect(acta.definitiva, isTrue);
    expect(acta.firmas.map((f) => f.personaUid), ['ane', 'mikel']);
    expect(estado.compromisosDelActa('txoko').map((c) => c.uid), ['c1', 'c2']);

    // Lo que se apunta después va a «¿Se ha hecho?», no al acta firmada.
    estado.anadirCompromiso(
      asuntoUid: 'txoko',
      que: 'Poner un cartel con el horario',
      responsable: 'Iker',
      fechaLimite: DateTime(2026, 12, 1),
    );
    expect(estado.compromisosDe('txoko'), hasLength(3));
    expect(estado.compromisosDelActa('txoko'), hasLength(2));
  });

  test('ni una vecina ni un asunto sin cerrar', () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    expect(estado.actaLista('fiestas'), isFalse);
    expect(() => estado.firmarActa('fiestas'), throwsStateError);
    estado.verComo('maite');
    expect(() => estado.firmarActa('txoko'), throwsStateError);
  });

  test('con una firma, el resultado queda quieto hasta retirarla', () {
    final estado = estadoDeEjemplo(hoy: _hoy)..firmarActa('txoko');
    void conteo() => estado.registrarConteoPresencial(
          asuntoUid: 'txoko',
          papeletasTotales: 1,
          marcasPorOpcion: const {'23': 1},
          segundaFirmaUid: 'mikel',
        );
    expect(conteo, throwsStateError);
    expect(
        () => estado.resumirDebate('txoko', 'Otro resumen'), throwsStateError);

    estado.retirarFirmaActa('txoko');
    expect(estado.acta('txoko').tieneFirmas, isFalse);
    final conteosAntes = estado.urna('txoko').conteosPresenciales.length;
    conteo();
    expect(
        estado.urna('txoko').conteosPresenciales, hasLength(conteosAntes + 1));
  });
}
