import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/dominio/prevision_cosecha.dart';
import 'package:solera_huerta/dominio/siembras_escalonadas.dart';
import 'package:solera_huerta/modelos/cosecha.dart';
import 'package:solera_huerta/modelos/siembra.dart';

int ms(DateTime fecha) => fecha.millisecondsSinceEpoch;

void main() {
  group('siembras escalonadas', () {
    test('fechas cada N días, por calendario', () {
      expect(
          fechasEscalonadas(
              primera: DateTime(2026, 3, 20), numero: 3, intervaloDias: 7),
          [DateTime(2026, 3, 20), DateTime(2026, 3, 27), DateTime(2026, 4, 3)]);
      expect(
          fechasEscalonadas(
              primera: DateTime(2026), numero: 0, intervaloDias: 7),
          isEmpty);
    });

    test('la serie copia la plantilla y desplaza la cosecha', () {
      final plantilla = Siembra(
          bancalId: 1,
          cultivoId: 2,
          fechaPrevistaMs: ms(DateTime(2026, 4, 1)),
          inicioCosechaPrevistaMs: ms(DateTime(2026, 5, 16)),
          kgPrevistos: 10,
          cantidad: 30);
      final serie = planificarSerieEscalonada(
          plantilla: plantilla,
          numero: 3,
          intervaloDias: 14,
          serie: 'lechuga-2026',
          bancalesPorOrden: [1, 5]);
      expect(serie.map((siembra) => siembra.bancalId), [1, 5, 1]);
      expect(
          serie.every((siembra) => siembra.serieEscalonada == 'lechuga-2026'),
          isTrue);
      expect(serie.every((siembra) => !siembra.realizada), isTrue);
      expect(serie.last.fechaPrevistaMs, ms(DateTime(2026, 4, 29)));
      expect(serie.last.inicioCosechaPrevistaMs, ms(DateTime(2026, 6, 13)));
    });
  });

  group('previsión de cosecha', () {
    const ciclo = (diasHastaCosecha: 60, semanasCosecha: 4);
    final siembra = Siembra(
        bancalId: 1,
        cultivoId: 2,
        fechaPrevistaMs: ms(DateTime(2026, 4, 1)),
        kgPrevistos: 20);

    test('inicio de cosecha: apuntado o por ciclo', () {
      expect(inicioCosechaPrevisto(siembra, ciclo), DateTime(2026, 5, 31));
      expect(inicioCosechaPrevisto(siembra, null), isNull);
    });

    test('reparte los kilos por igual entre las semanas de cosecha', () {
      CicloCultivo? cicloDe(int _) => ciclo;
      // 31/5 es domingo: su semana empieza el 25/5.
      expect(
          cosechaPrevistaSemana(
              siembras: [siembra],
              lunes: DateTime(2026, 5, 18),
              cicloDe: cicloDe),
          isEmpty);
      expect(
          cosechaPrevistaSemana(
              siembras: [siembra],
              lunes: DateTime(2026, 5, 25),
              cicloDe: cicloDe)[2],
          5);
      expect(
          cosechaPrevistaSemana(
              siembras: [siembra],
              lunes: DateTime(2026, 6, 15),
              cicloDe: cicloDe)[2],
          5);
      expect(
          cosechaPrevistaSemana(
              siembras: [siembra],
              lunes: DateTime(2026, 6, 22),
              cicloDe: cicloDe),
          isEmpty);
    });

    test('no cuenta lo levantado ni lo que no tiene kilos', () {
      final levantada =
          siembra.copiar(fechaLevantadaMs: ms(DateTime(2026, 6, 1)));
      final sinKilos = Siembra(
          bancalId: 1, cultivoId: 3, fechaPrevistaMs: siembra.fechaPrevistaMs);
      expect(
          cosechaPrevistaSemana(
              siembras: [levantada, sinKilos],
              lunes: DateTime(2026, 6, 8),
              cicloDe: (_) => ciclo),
          isEmpty);
    });

    test('cosecha real para cestas de la semana', () {
      final cosechas = [
        Cosecha(
            bancalId: 1,
            cultivoId: 2,
            fechaMs: ms(DateTime(2026, 6, 2)),
            kg: 3),
        Cosecha(
            bancalId: 2,
            cultivoId: 2,
            fechaMs: ms(DateTime(2026, 6, 4)),
            kg: 1.5),
        Cosecha(
            bancalId: 1,
            cultivoId: 4,
            fechaMs: ms(DateTime(2026, 6, 4)),
            unidades: 12),
        Cosecha(
            bancalId: 1,
            cultivoId: 2,
            fechaMs: ms(DateTime(2026, 6, 4)),
            kg: 9,
            destino: 'mercado'),
        Cosecha(
            bancalId: 1,
            cultivoId: 2,
            fechaMs: ms(DateTime(2026, 6, 9)),
            kg: 9),
      ];
      final real = cosechaRealParaCestas(
          cosechas: cosechas, lunes: DateTime(2026, 6, 1));
      expect(real[2]!.kg, 4.5);
      expect(real[4]!.unidades, 12);
      expect(real.length, 2);
    });
  });
}
