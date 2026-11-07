import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_especies.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_parametros_ecoregimen.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_razas.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_sustancias_activas.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_tabla_ugm.dart';
import 'package:solera_ganadera/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_ganadera/dominio/busqueda_catalogos.dart';
import 'package:solera_ganadera/modelos/carga_ganadera.dart';
import 'package:solera_ganadera/modelos/ganado.dart';
import 'package:solera_ganadera/modelos/ganado_ecologico.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';

void main() {
  test('las especies del catálogo son las del código', () {
    expect(catalogoEspecies.map((especie) => especie.id).toSet(),
        especiesGanado.toSet());
    for (final especie in catalogoEspecies) {
      expect(dispositivosIdentificacion, contains(especie.dispositivoHabitual));
    }
  });

  test('cada raza es de una especie conocida y no se repite', () {
    final vistas = <String>{};
    for (final raza in catalogoRazas) {
      expect(especiesGanado, contains(raza.especie), reason: raza.nombre);
      expect(vistas.add('${raza.especie}/${raza.nombre}'), isTrue,
          reason: raza.nombre);
    }
    expect(razasDeEspecie('ovino'), contains('Latxa'));
    expect(razasDeEspecie('vacuno'), isNot(contains('Latxa')));
  });

  test('sustancias: ids únicos, clase válida y sin vacunas ni naturales', () {
    final ids = <String>{};
    for (final sustancia in catalogoSustanciasActivas) {
      expect(ids.add(sustancia.id), isTrue, reason: sustancia.id);
      expect([claseAlopatico, claseAntiparasitario], contains(sustancia.clase),
          reason: sustancia.id);
    }
  });

  test('hard limit: el catálogo de sustancias no trae plazos ni dosis', () {
    final cabecera = File('../../content/ganadera/sustancias_activas.csv')
        .readAsLinesSync()
        .firstWhere((linea) => !linea.startsWith('#'));
    expect(cabecera, 'id,nombre,clase,grupo,revisado_por');
  });

  test('tabla UGM: cada trámite cubre todas las especies a cualquier edad', () {
    for (final tramite in [tramitePac, tramiteAndalucia]) {
      final tabla = tablaDeTramite(catalogoCoeficientesUgm, tramite);
      expect(tabla, isNotEmpty);
      for (final especie in especiesGanado) {
        for (final sexo in ['', ...sexosAnimal]) {
          for (final meses in [0, 5, 11, 12, 23, 24, 600]) {
            final fila =
                tabla.where((fila) => fila.encaja(especie, sexo, meses));
            expect(fila, isNotEmpty,
                reason: '$tramite $especie $sexo $meses meses');
            expect(fila.first.ugm, greaterThan(0));
          }
        }
      }
    }
  });

  test('parámetros del eco-régimen para cada tipo de pasto, coherentes', () {
    expect(catalogoParametrosEcoregimen.map((fila) => fila.tipoPasto).toSet(),
        tiposPasto.toSet());
    for (final fila in catalogoParametrosEcoregimen) {
      expect(fila.cargaMinimaReducida, lessThan(fila.cargaMinima));
      expect(fila.cargaMinima, lessThan(fila.cargaMaxima));
      expect(fila.diasMinimosReducidos, lessThan(fila.diasMinimos));
    }
  });

  test('búsqueda de sustancia: sin tildes, mayúsculas ni concentración', () {
    expect(buscarSustanciaActiva('IVERMECTINA 1 %')?.id, 'ivermectina');
    expect(buscarSustanciaActiva(' bencilpenicilina ')?.id, 'bencilpenicilina');
    expect(buscarSustanciaActiva('una que no está'), isNull);
    expect(buscarSustanciaActiva(''), isNull);
    expect(normalizarTexto('Murciano-Granadina  Árbol'),
        'murciano-granadina arbol');
  });

  test('sin firma de persona, el banner de provisionales sigue activo', () {
    expect(catalogosCompletamenteRevisados, isFalse);
  });

  test('ninguna fila finge una firma humana', () {
    for (final fichero in Directory('../../content/ganadera')
        .listSync()
        .whereType<File>()
        .where((fichero) => fichero.path.endsWith('.csv'))) {
      for (final linea in fichero.readAsLinesSync()) {
        expect(
            linea.contains(',asesor:') || linea.contains(',persona:'), isFalse,
            reason: '${fichero.path}: $linea');
      }
    }
  });
}
