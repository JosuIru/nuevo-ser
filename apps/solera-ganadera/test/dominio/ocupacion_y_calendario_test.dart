import 'package:flutter_test/flutter_test.dart';
import 'package:solera_ganadera/dominio/calendario_sanitario.dart';
import 'package:solera_ganadera/dominio/ocupacion_pastos.dart';
import 'package:solera_ganadera/estado/datos_ganado.dart';
import 'package:solera_ganadera/modelos/ganado.dart';
import 'package:solera_ganadera/modelos/ganado_ecologico.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';
import 'package:solera_ganadera/modelos/tarea_sanitaria.dart';

int dia(int anio, int mes, int diaDelMes) =>
    DateTime(anio, mes, diaDelMes, 10).millisecondsSinceEpoch;

void main() {
  final ahora = DateTime(2026, 11, 7, 12);
  final ovejas = LoteGanado(
      id: 1, nombre: 'Latxas', especie: 'ovino', cabezasSinIdentificar: 40);
  final vacas = LoteGanado(id: 2, nombre: 'Vacas', especie: 'vacuno');
  final cerrado = LoteGanado(id: 3, nombre: 'Viejo', estado: estadoLoteCerrado);
  final piezas = [
    PiezaPasto(id: 10, nombre: 'Larre', superficieHa: 20),
    PiezaPasto(id: 11, nombre: 'Soto'),
    PiezaPasto(id: 12, nombre: 'Baja', activa: false),
  ];

  test('ocupación: cada rebaño en su pieza, con UGM de la PAC', () {
    final estados = estadosDeLotes(
      lotes: [ovejas, vacas, cerrado],
      animales: [
        Animal(id: 1, loteId: 2, sexo: 'hembra'),
        Animal(id: 2, loteId: 2, sexo: 'macho'),
      ],
      movimientos: [
        MovimientoGanado(
            id: 1, loteId: 1, fechaMs: dia(2026, 6, 1), piezaDestinoId: 10),
        MovimientoGanado(
            id: 2, loteId: 2, fechaMs: dia(2026, 6, 1), piezaDestinoId: 10),
        MovimientoGanado(
            id: 3, loteId: 2, fechaMs: dia(2026, 7, 1), piezaDestinoId: 11),
      ],
      tabla: tablaUgmPantallas,
      ahora: ahora,
    );
    expect(estados, hasLength(2), reason: 'el cerrado no cuenta');
    final ocupacion = ocupacionDePiezas(piezas, estados);
    expect(ocupacion.map((pieza) => pieza.pieza.nombre), ['Larre', 'Soto']);
    expect(ocupacion.first.cabezas, 40);
    expect(ocupacion.first.ugm, closeTo(4.0, 1e-9));
    expect(ocupacion.first.carga, closeTo(0.2, 1e-9));
    expect(ocupacion.last.ugm, closeTo(1.8, 1e-9));
    expect(ocupacion.last.carga, isNull, reason: 'sin superficie');
  });

  test('calendario: tareas pendientes y fin de esperas, por fecha', () {
    final avisos = avisosSanitarios(
      tareas: [
        TareaSanitaria(
            id: 1, titulo: 'Saneamiento', fechaPrevistaMs: dia(2026, 11, 20)),
        TareaSanitaria(
            id: 2, titulo: 'Atrasada', fechaPrevistaMs: dia(2026, 11, 1)),
        TareaSanitaria(
            id: 3,
            titulo: 'Hecha',
            fechaPrevistaMs: dia(2026, 11, 2),
            hechaMs: dia(2026, 11, 2)),
        TareaSanitaria(
            id: 4, titulo: 'Lejana', fechaPrevistaMs: dia(2027, 6, 1)),
      ],
      eventos: [
        EventoGanado(
            loteId: 1,
            fechaMs: dia(2026, 11, 5),
            sustanciaActiva: 'Ivermectina',
            plazoSupresionCarneDias: 10,
            plazoSupresionLecheDias: 0),
        EventoGanado(
            loteId: 1,
            fechaMs: dia(2026, 10, 1),
            plazoSupresionCarneDias: 5), // ya terminó
        EventoGanado(
            loteId: 1,
            fechaMs: dia(2026, 11, 5),
            tipo: tipoEventoPesaje,
            plazoSupresionCarneDias: 99), // no lleva medicamento
      ],
      lotes: [ovejas],
      animales: const [],
      ahora: ahora,
    );
    expect(avisos.map((aviso) => aviso.tarea?.titulo ?? aviso.tipo.name), [
      'Atrasada',
      'finSupresionCarne',
      'Saneamiento',
    ]);
    expect(avisos.first.vencido(ahora), isTrue);
    expect(avisos[1].dia, DateTime(2026, 11, 15));
  });

  test('calendario: en ecológico la espera es la doble', () {
    final ecologicas = LoteGanado(id: 5, ecologico: true);
    final avisos = avisosSanitarios(
      tareas: const [],
      eventos: [
        EventoGanado(
            animalId: 9,
            fechaMs: dia(2026, 11, 6),
            claseMedicamento: claseAlopatico,
            plazoSupresionLecheDias: 0,
            plazoSupresionCarneDias: 4),
      ],
      lotes: [ecologicas],
      animales: [Animal(id: 9, loteId: 5)],
      ahora: ahora,
    );
    expect(avisos.map((aviso) => aviso.tipo), [
      TipoAvisoSanitario.finSupresionLeche, // 0 → mínimo 48 h
      TipoAvisoSanitario.finSupresionCarne, // 4 → 8
    ]);
    expect(avisos.first.dia, DateTime(2026, 11, 8));
    expect(avisos.last.dia, DateTime(2026, 11, 14));
    expect(avisos.last.loteId, 5);
  });
}
