// Tareas tipo de Zunbeltz (Ganado.docx), tipos de punto y especies nuevos,
// y partidas de presupuesto con fórmula (material del 2026-10-13).

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/constantes.dart';
import 'package:solera_zunbeltz/modelos/convenio.dart';
import 'package:solera_zunbeltz/modelos/plantillas_tarea.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_convenio.dart';

void main() {
  test('las tareas tipo apuntan a catálogos que existen', () {
    final codigos = <String>{};
    for (final plantilla in plantillasTarea) {
      expect(codigos.add(plantilla.codigo), isTrue,
          reason: 'código repetido: ${plantilla.codigo}');
      expect(buscarOpcion(gruposPlantillaTarea, plantilla.grupo), isNotNull);
      expect(buscarOpcion(tiposPlantillaTarea, plantilla.tipo), isNotNull);
      expect(recurrenciasTarea, contains(plantilla.recurrenciaDias),
          reason: '${plantilla.codigo}: la periodicidad tiene que poder '
              'elegirse en el formulario');
      expect(plantilla.recurrenciaDias == null,
          plantilla.tipo == 'puntual',
          reason: '${plantilla.codigo}: solo las puntuales no se repiten');
      for (final tipoPunto in [
        plantilla.tipoPunto,
        ...plantilla.subtipos.map((subtipo) => subtipo.tipoPunto),
      ].nonNulls) {
        expect(buscarOpcion(tiposPunto, tipoPunto), isNotNull,
            reason: '${plantilla.codigo} → $tipoPunto');
      }
      for (final subtipo in plantilla.subtipos) {
        final gasto = subtipo.gasto;
        if (gasto == null) continue;
        expect(buscarOpcion(categoriasGasto, gasto.$1), isNotNull);
        expect(buscarOpcion(partidasDe(gasto.$1), gasto.$2), isNotNull,
            reason: '${subtipo.codigo} → ${gasto.$2}');
      }
    }
    // Las dos tablas del documento.
    expect(plantillasTarea.where((p) => p.grupo == 'ganado'), hasLength(11));
  });

  test('título y sugerencias por punto', () {
    final revision = plantillasTarea.firstWhere((p) => p.codigo == 'revision');
    final pastor = revision.subtipos.firstWhere((s) => s.codigo == 'pastor');
    expect(revision.titulo('es', pastor), 'Revisión: pastor eléctrico');
    expect(revision.titulo('eu', pastor), 'Berrikuspena: artzain elektrikoa');
    expect(revision.encajaCon('pastor_electrico'), isTrue);
    expect(revision.encajaCon('molino'), isFalse);
  });

  test('una compra lleva su bloque y su partida al apuntarla como gasto', () {
    expect(gastoSugeridoParaTarea('Compra: gasoil y otros combustibles'),
        ('maquinaria', 'combustibles'));
    expect(gastoSugeridoParaTarea('erosketa: elikagaiak'),
        ('directos', 'compra_alimento'));
    expect(gastoSugeridoParaTarea('Arreglar la puerta'), ('directos', ''));
  });

  test('tipos de punto y especies nuevos', () {
    for (final codigo in [
      'aprisco',
      'placas_solares',
      'vestuario',
      'bebedero_movil',
      'pastor_electrico',
      'isotermo',
      'molino',
    ]) {
      expect(buscarOpcion(tiposPunto, codigo), isNotNull, reason: codigo);
    }
    expect(tiposPuntoMoviles, containsAll(['bebedero_movil', 'pastor_electrico']));
    expect(especiesGanado.map((e) => e.codigo), containsAll(['aves', 'porcino']));
  });

  test('presupuesto con fórmula, como la hoja (pollos: 1.417,50 €)', () {
    expect(
        importeCalculadoPartida(
            modo: modoPartidaRacion,
            cantidad: 0.15,
            cabezas: 300,
            dias: 90,
            precioUnitarioCentimos: 35),
        141750);
    // Transporte: 79,6 km × 0,32 €/km = 25,47 €.
    expect(
        importeCalculadoPartida(
            modo: modoPartidaUnidades,
            cantidad: 79.6,
            cabezas: 0,
            dias: 0,
            precioUnitarioCentimos: 32),
        2547);
    expect(
        importeCalculadoPartida(
            modo: modoPartidaManual,
            cantidad: 1,
            cabezas: 1,
            dias: 1,
            precioUnitarioCentimos: 1),
        isNull);

    final partida = PartidaPresupuesto.fromMap(PartidaPresupuesto(
      proyectoId: 1,
      categoria: 'directos',
      modoCalculo: modoPartidaRacion,
      cantidad: 0.15,
      cabezas: 300,
      dias: 90,
      precioUnitarioCentimos: 35,
      importeCentimos: 141750,
    ).toMap());
    expect(formulaPartida(partida), '0,15 × 300 × 90 × 0,35 €');
    expect(formulaPartida(PartidaPresupuesto(proyectoId: 1)), isNull);
  });
}
