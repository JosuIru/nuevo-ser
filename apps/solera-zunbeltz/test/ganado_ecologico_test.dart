import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/modelos/ganado_ecologico.dart';

void main() {
  final ahora = DateTime(2026, 10, 22, 10);
  int dia(int anio, int mes, int d) =>
      DateTime(anio, mes, d, 9).millisecondsSinceEpoch;
  EventoGanado tratamiento(int fechaMs,
          {String clase = claseAlopatico,
          String tipo = tipoEventoTratamiento,
          int carne = 0,
          int leche = 0}) =>
      EventoGanado(
          fechaMs: fechaMs,
          tipo: tipo,
          claseMedicamento: clase,
          plazoSupresionCarneDias: carne,
          plazoSupresionLecheDias: leche);

  test('en ecológico el plazo se dobla, con 48 h como mínimo', () {
    expect(plazoEfectivoDias(28, ecologico: true, clase: claseAlopatico), 56);
    expect(plazoEfectivoDias(0, ecologico: true, clase: claseAlopatico), 2);
    expect(plazoEfectivoDias(0, ecologico: true, clase: ''), 2,
        reason: 'sin indicar la clase, lo prudente');
    expect(plazoEfectivoDias(10, ecologico: true, clase: claseVacuna), 10);
    expect(plazoEfectivoDias(10, ecologico: true, clase: claseNatural), 10);
    expect(plazoEfectivoDias(28, ecologico: false, clase: claseAlopatico), 28);
  });

  test('la supresión de un lote ecológico usa el plazo doble', () {
    final evento = tratamiento(dia(2026, 10, 10), carne: 7);
    expect(supresionVigente([evento], ahora).carneHasta, isNull,
        reason: '7 días: libre desde el 17');
    final eco = eventoConPlazosEfectivos(evento, ecologico: true);
    expect(supresionVigente([eco], ahora).carneHasta, DateTime(2026, 10, 24));
    final pesaje = EventoGanado(fechaMs: dia(2026, 10, 10), tipo: 'pesaje');
    expect(
        eventoConPlazosEfectivos(pesaje, ecologico: true)
            .plazoSupresionLecheDias,
        0,
        reason: 'sin medicamento no hay plazo que doblar');
  });

  test('límite de tratamientos en 12 meses: tres, o uno con ciclo corto', () {
    final eventos = [
      tratamiento(dia(2025, 10, 21)), // fuera: más de 12 meses
      tratamiento(dia(2025, 10, 22)),
      tratamiento(dia(2026, 3, 1)),
      tratamiento(dia(2026, 5, 1), clase: claseVacuna),
      tratamiento(dia(2026, 6, 1), clase: claseAntiparasitario),
      tratamiento(dia(2026, 7, 1), tipo: 'saneamiento'),
      tratamiento(dia(2026, 9, 1), clase: ''),
    ];
    final estado =
        estadoTratamientosEcologico(eventos, ahora, cicloCorto: false);
    expect(estado.tratamientos, 3);
    expect(estado.enElLimite, isTrue);
    expect(estado.superado, isFalse);
    final corto = estadoTratamientosEcologico(eventos, ahora, cicloCorto: true);
    expect(corto.limite, 1);
    expect(corto.superado, isTrue);
  });

  test('los campos nuevos viajan por toMap/fromMap', () {
    final lote = LoteGanado.fromMap(
        LoteGanado(nombre: 'Ovejas', ecologico: true, cicloCorto: true)
            .toMap());
    expect(lote.ecologico, isTrue);
    expect(lote.cicloCorto, isTrue);
    final evento = EventoGanado.fromMap(
        tratamiento(dia(2026, 1, 1), clase: claseVacuna).toMap());
    expect(evento.claseMedicamento, claseVacuna);
  });
}
