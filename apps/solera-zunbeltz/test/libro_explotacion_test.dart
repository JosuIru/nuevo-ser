import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_zunbeltz/l10n/app_localizations_es.dart';
import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/modelos/ganado_ecologico.dart';
import 'package:solera_zunbeltz/servicios/generador_libro_explotacion.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));
  final textos = AppLocalizationsEs();
  final ahora = DateTime(2026, 10, 22, 10);
  int dia(int mes, int d) => DateTime(2026, mes, d, 9).millisecondsSinceEpoch;

  final ovejas = LoteGanado(
      id: 1,
      nombre: 'Ovejas de Ane',
      especie: 'ovino',
      ecologico: true,
      cabezasSinIdentificar: 10);
  final vacas = LoteGanado(id: 2, nombre: 'Vacas', especie: 'vacuno');
  final datos = DatosGanado(
    lotes: [ovejas, vacas],
    animales: [
      Animal(
          id: 1, identificacion: 'ES012345678901', loteId: 1, especie: 'ovino'),
      Animal(
          id: 2,
          identificacion: 'ES012345678902',
          loteId: 2,
          especie: 'vacuno'),
    ],
    movimientos: [
      MovimientoGanado(
          id: 1,
          loteId: 1,
          fechaMs: dia(9, 1),
          tipo: tipoMovimientoEntrada,
          zonaDestinoId: 5,
          cabezas: 11,
          guia: 'G-77'),
    ],
    eventos: [
      EventoGanado(
          id: 1,
          loteId: 1,
          fechaMs: dia(10, 1),
          tipo: tipoEventoTratamiento,
          sustanciaActiva: 'Oxitetraciclina',
          claseMedicamento: claseAlopatico,
          plazoSupresionCarneDias: 14),
      EventoGanado(id: 2, animalId: 2, fechaMs: dia(10, 2), tipo: 'pesaje'),
    ],
    zonas: {5: 'Pasillo'},
  );

  test('el libro lleva censo, animales, movimientos, tratamientos y ecológico',
      () {
    final tablas = tablasLibroExplotacion(
        textos: textos, idioma: 'es', datos: datos, ahora: ahora);
    expect(tablas.map((t) => t.titulo), [
      textos.libroCenso,
      textos.libroAnimales,
      textos.libroMovimientos,
      textos.libroTratamientos,
      textos.libroEcologico,
    ]);
    final censo = tablas[0].filas;
    expect(censo.first,
        ['Ovejas de Ane', 'Ovino', 'Pasillo', '11', '10', '1,65', 'Sí']);
    expect(censo.last[5], '1,00', reason: 'vaca adulta sin fecha');
    expect(tablas[2].filas.single[5], 'G-77');
    final tratamiento = tablas[3].filas.single;
    expect(tratamiento[1], 'Ovejas de Ane');
    expect(tratamiento[6], '14 (eco 28)', reason: 'en ecológico se dobla');
    expect(tratamiento[7], '0 (eco 2)', reason: 'mínimo 48 horas');
    expect(tablas[4].filas.first,
        ['Ovejas de Ane', '1', '3', textos.libroEcoBien]);
  });

  test('sin rebaños ecológicos no sale la tabla ecológica', () {
    final soloVacas = DatosGanado(
        lotes: [vacas],
        animales: const [],
        movimientos: const [],
        eventos: const [],
        zonas: const {});
    expect(
        tablasLibroExplotacion(
                textos: textos, idioma: 'es', datos: soloVacas, ahora: ahora)
            .map((t) => t.titulo),
        isNot(contains(textos.libroEcologico)));
  });

  test('la hoja de movimiento lleva sus datos y los animales del rebaño', () {
    final tablas = tablasHojaMovimiento(
        textos: textos,
        idioma: 'es',
        movimiento: datos.movimientos.single,
        lote: ovejas,
        animalesDelLote: [datos.animales.first],
        zonas: datos.zonas);
    final datosMovimiento = {
      for (final fila in tablas[0].filas) fila[0]: fila[1]
    };
    expect(datosMovimiento[textos.libroColGuia], 'G-77');
    expect(datosMovimiento[textos.libroColTrayecto],
        '${textos.ganFueraDelEspacio} → Pasillo');
    expect(tablas[1].filas.single.first, 'ES012345678901');
  });
}
