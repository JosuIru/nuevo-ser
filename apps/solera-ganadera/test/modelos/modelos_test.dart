import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:solera_ganadera/modelos/apunte_economico.dart';
import 'package:solera_ganadera/modelos/explotacion.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';
import 'package:solera_ganadera/modelos/tarea_sanitaria.dart';
import 'package:solera_ganadera/modelos/titular.dart';
import 'package:solera_ganadera/modelos/visita.dart';

void main() {
  test('titular y explotación: round-trip y valores por defecto', () {
    final titular = Titular.fromMap(Titular(
            nombre: 'Ane',
            nif: 'X',
            telefono: '6',
            correo: 'a@b',
            direccion: 'D')
        .toMap());
    expect([titular.telefono, titular.correo, titular.direccion],
        ['6', 'a@b', 'D']);
    final explotacion = Explotacion.fromMap(Explotacion(
        codigoRega: 'ES310000000001',
        latitud: 43.1,
        capacidadMaxima: 300,
        especies: {'vacuno', 'ovino'}).toMap());
    expect(explotacion.especies, {'ovino', 'vacuno'});
    expect(explotacion.latitud, 43.1);
    expect(explotacion.capacidadMaxima, 300);
    expect(Explotacion.fromMap(const {}).especies, isEmpty);
  });

  test('código REGA: forma ES + 12 cifras', () {
    expect(pareceCodigoRega('ES310000000001'), isTrue);
    expect(pareceCodigoRega('es 3100 0000 0001'), isTrue);
    expect(pareceCodigoRega('ES31000000001'), isFalse);
    expect(pareceCodigoRega(''), isFalse);
  });

  test('pieza de pasto: contorno, y un contorno roto no rompe', () {
    final pieza = PiezaPasto.fromMap(PiezaPasto(
        nombre: 'Larre',
        superficieHa: 3.2,
        tipoPasto: pastoHumedo,
        contorno: const [LatLng(43.0, -1.0), LatLng(43.1, -1.1)]).toMap());
    expect(pieza.contorno, const [LatLng(43.0, -1.0), LatLng(43.1, -1.1)]);
    expect(pieza.tieneContorno, isFalse);
    expect(pieza.tipoPasto, pastoHumedo);
    expect(
        PiezaPasto.fromMap(const {'contorno': 'no es json'}).contorno, isEmpty);
    expect(
        PiezaPasto.fromMap(const {'contorno': '[[1, "x"], [2, 3]]'}).contorno,
        const [LatLng(2.0, 3.0)]);
    expect(PiezaPasto.fromMap(const {}).contorno, isEmpty);
    expect(PiezaPasto.fromMap(const {}).activa, isTrue);
  });

  test('pieza de pasto: sin superficie toma la del área; la escrita manda', () {
    // Un cuadrado de unos 100 m de lado a la latitud de Navarra: ~1 ha.
    const lado = 100 / 111195.0;
    const cuadrado = [
      LatLng(42.8, -1.6),
      LatLng(42.8 + lado, -1.6),
      LatLng(42.8 + lado, -1.6 + lado / 0.7337),
      LatLng(42.8, -1.6 + lado / 0.7337),
    ];
    final sinSuperficie = PiezaPasto(nombre: 'Larre').conContorno(cuadrado);
    expect(sinSuperficie.superficieHa, closeTo(1.0, 0.02));
    expect(sinSuperficie.superficieCalculadaHa, closeTo(1.0, 0.02));
    final conSuperficie =
        PiezaPasto(nombre: 'Larre', superficieHa: 2.4).conContorno(cuadrado);
    expect(conSuperficie.superficieHa, 2.4);
    expect(
        PiezaPasto(nombre: 'Larre').conContorno(const []).superficieHa, isNull);
  });

  test('visita, tarea sanitaria y apunte: round-trip', () {
    final visita = Visita.fromMap(
        Visita(fechaMs: 1, persona: 'Vet', esVeterinaria: true, vehiculo: 'M')
            .toMap());
    expect(visita.esVeterinaria, isTrue);
    expect(visita.vehiculo, 'M');
    final tarea = TareaSanitaria.fromMap(
        TareaSanitaria(titulo: 'T', loteId: 2, fechaPrevistaMs: 3).toMap());
    expect(tarea.pendiente, isTrue);
    expect(tarea.marcarHecha(4).hechaMs, 4);
    final apunte = ApunteEconomico.fromMap(ApunteEconomico(
            esIngreso: false,
            fechaMs: 1,
            concepto: 'Pienso',
            categoria: 'piensos_forraje',
            baseCentimos: 1000,
            porcentaje: 10)
        .toMap());
    expect(apunte.totalCentimos, 1100);
    expect(apunte.esReagp, isFalse);
  });
}
