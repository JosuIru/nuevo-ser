import 'package:flutter_test/flutter_test.dart';
import 'package:solera_frutal/dominio/polinizacion.dart';
import 'package:solera_frutal/dominio/resumen_cosecha.dart';
import 'package:solera_frutal/modelos/cosecha.dart';
import 'package:solera_frutal/modelos/tratamiento.dart';

void main() {
  group('resumen de cosecha', () {
    test('agrupa por parcela y campaña y pondera por kilos', () {
      final resumenes = ResumenCosechaParcela.calcular([
        Cosecha(
            parcelaId: 1,
            campania: 2026,
            fechaMs: 0,
            kgCascara: 1000,
            rendimientoGranoPorcentaje: 30,
            humedadPorcentaje: 5),
        Cosecha(
            parcelaId: 1,
            campania: 2026,
            fechaMs: 1,
            kgCascara: 3000,
            rendimientoGranoPorcentaje: 20,
            humedadPorcentaje: 9),
        Cosecha(parcelaId: 1, campania: 2026, fechaMs: 2, kgCascara: 500),
        Cosecha(parcelaId: 2, campania: 2026, fechaMs: 0, kgCascara: 10),
      ]);
      expect(resumenes, hasLength(2));
      final primera = resumenes.first;
      expect(primera.entregas, 3);
      expect(primera.kgCascara, 4500);
      expect(primera.kgGrano, closeTo(900, 1e-9));
      expect(primera.rendimientoMedioPorcentaje, closeTo(22.5, 1e-9));
      expect(primera.humedadMediaPorcentaje, closeTo(8, 1e-9));
      expect(primera.kgCascaraPorHectarea(2), 2250);
      expect(primera.kgCascaraPorHectarea(0), isNull);
      expect(resumenes.last.rendimientoMedioPorcentaje, isNull);
      expect(resumenes.last.humedadMediaPorcentaje, isNull);
    });

    test('sin cosechas no hay resumen', () {
      expect(ResumenCosechaParcela.calcular([]), isEmpty);
    });

    test('cosechar dentro del plazo de seguridad se detecta', () {
      final tratamientos = [
        Tratamiento(
            parcelaId: 1,
            fechaMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
            plazoSeguridadDias: 21),
        Tratamiento(
            parcelaId: 1,
            fechaMs: DateTime(2026, 8, 1).millisecondsSinceEpoch,
            plazoSeguridadDias: 7),
        Tratamiento(
            parcelaId: 2,
            fechaMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
            plazoSeguridadDias: 30),
        Tratamiento(
            parcelaId: 1, fechaMs: DateTime(2026, 9, 5).millisecondsSinceEpoch),
      ];
      expect(
          tratamientosConPlazoAbierto(tratamientos,
                  parcelaId: 1, fecha: DateTime(2026, 9, 10))
              .single
              .plazoSeguridadDias,
          21);
      expect(
          tratamientosConPlazoAbierto(tratamientos,
              parcelaId: 1, fecha: DateTime(2026, 9, 22)),
          isEmpty);
    });
  });

  group('polinización', () {
    const catalogo = {
      'marcona': DatosPolinizacionVariedad(
          id: 'marcona',
          especieId: 'almendro',
          autocompatible: false,
          grupoIncompatibilidad: 'A',
          floracion: 'temprana'),
      'desmayo': DatosPolinizacionVariedad(
          id: 'desmayo',
          especieId: 'almendro',
          autocompatible: false,
          grupoIncompatibilidad: 'B',
          floracion: 'temprana'),
      'tardia_a': DatosPolinizacionVariedad(
          id: 'tardia_a',
          especieId: 'almendro',
          autocompatible: false,
          grupoIncompatibilidad: 'C',
          floracion: 'muy_tardia'),
      'mismo_grupo': DatosPolinizacionVariedad(
          id: 'mismo_grupo',
          especieId: 'almendro',
          autocompatible: false,
          grupoIncompatibilidad: 'A',
          floracion: 'media'),
      'sin_grupo': DatosPolinizacionVariedad(
          id: 'sin_grupo',
          especieId: 'almendro',
          autocompatible: false,
          floracion: 'media'),
      'guara': DatosPolinizacionVariedad(
          id: 'guara',
          especieId: 'almendro',
          autocompatible: true,
          floracion: 'tardia'),
      'avellano_x': DatosPolinizacionVariedad(
          id: 'avellano_x',
          especieId: 'avellano',
          autocompatible: false,
          grupoIncompatibilidad: 'Z',
          floracion: 'temprana'),
      'dudosa': DatosPolinizacionVariedad(
          id: 'dudosa', especieId: 'almendro', autocompatible: null),
    };

    EstadoPolinizacion estado(List<String> variedades, String variedad) =>
        evaluarPolinizacion(variedadesEnParcela: variedades, catalogo: catalogo)
            .firstWhere((resultado) => resultado.variedadId == variedad)
            .estado;

    test('autocompatible y variedad desconocida', () {
      expect(estado(['guara'], 'guara'), EstadoPolinizacion.autocompatible);
      expect(
          estado(['inventada'], 'inventada'), EstadoPolinizacion.desconocida);
      expect(estado(['dudosa'], 'dudosa'), EstadoPolinizacion.desconocida);
    });

    test('dos grupos distintos con floración solapada se cubren', () {
      final resultados = evaluarPolinizacion(
          variedadesEnParcela: ['marcona', 'desmayo', ' ', 'marcona'],
          catalogo: catalogo);
      expect(resultados, hasLength(2));
      expect(resultados.first.estado, EstadoPolinizacion.cubierta);
      expect(resultados.first.polinizadoras, ['desmayo']);
      expect(resultados.first.necesitaAtencion, isFalse);
    });

    test('mismo grupo, floración lejana u otra especie no polinizan', () {
      expect(estado(['marcona', 'mismo_grupo'], 'marcona'),
          EstadoPolinizacion.sinPolinizadora);
      expect(estado(['marcona', 'tardia_a'], 'marcona'),
          EstadoPolinizacion.sinPolinizadora);
      expect(estado(['marcona', 'avellano_x'], 'marcona'),
          EstadoPolinizacion.sinPolinizadora);
      expect(
          estado(['marcona'], 'marcona'), EstadoPolinizacion.sinPolinizadora);
    });

    test('sin grupo conocido queda por confirmar', () {
      final resultado = evaluarPolinizacion(
              variedadesEnParcela: ['marcona', 'sin_grupo'], catalogo: catalogo)
          .first;
      expect(resultado.estado, EstadoPolinizacion.porConfirmar);
      expect(resultado.necesitaAtencion, isTrue);
    });

    test('solape de floraciones', () {
      expect(floracionesSolapan('temprana', 'media'), isTrue);
      expect(floracionesSolapan('temprana', 'tardia'), isFalse);
      expect(floracionesSolapan('', 'media'), isFalse);
    });
  });
}
