import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' hide SelectorHabilidades;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/catalogo_habilidades.dart';
import 'package:uno_roto/datos/nivel_de_partida.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';
import 'package:uno_roto/dominio/catalogo_distritos.dart';
import 'package:uno_roto/dominio/generador_caza.dart';
import 'package:uno_roto/dominio/nivel_escolar.dart';
import 'package:uno_roto/dominio/selector_habilidades.dart';

Habilidad _habilidad(String id, String curso, {List<String> distritos = const ['tejados'], List<String> deps = const []}) =>
    Habilidad(
      identificador: id,
      nombre: id,
      dominio: id.split('.').first,
      dependencias: deps,
      familiasFragmento: const [],
      distritos: distritos,
      rangoIntroduccion: 'Aprendiz_I',
      rangoExigido: 'Aprendiz_I',
      umbralPrecision: 0.8,
      tiempoMedianoMinSeg: 5,
      tiempoMedianoMaxSeg: 30,
      curso: curso,
    );

void main() {
  test('todas las habilidades del catálogo tienen un curso válido', () {
    final datos = jsonDecode(File('assets/data/skills.json').readAsStringSync()) as Map<String, dynamic>;
    for (final habilidad in datos['skills'] as List) {
      expect(NivelEscolar.deCodigo(habilidad['course'] as String?), isNotNull, reason: '${habilidad['id']}');
    }
  });

  test('el suelo de acceso no quita esquirlas: sólo abre', () {
    expect(esquirlasParaAcceso(12, null), 12);
    expect(esquirlasParaAcceso(12, NivelEscolar.primeroEso), 150);
    expect(esquirlasParaAcceso(400, NivelEscolar.primeroEso), 400);
  });

  test('se da por sabido lo de cursos anteriores; queda muy atrás lo de dos o más', () {
    expect(seDaPorSabida('4P', NivelEscolar.sextoPrimaria), isTrue);
    expect(seDaPorSabida('6P', NivelEscolar.sextoPrimaria), isFalse);
    expect(seDaPorSabida('4P', null), isFalse);
    expect(quedaMuyAtras('4P', NivelEscolar.sextoPrimaria), isTrue);
    expect(quedaMuyAtras('5P', NivelEscolar.sextoPrimaria), isFalse);
    expect(quedaMuyAtras('5P', NivelEscolar.segundoEso), isTrue);
  });

  test('con 2.º de ESO se abren todos los distritos', () {
    final acceso = esquirlasParaAcceso(0, NivelEscolar.segundoEso);
    expect(CatalogoDistritos.todos.every((d) => d.estaDesbloqueado(acceso)), isTrue);
  });

  test('aplicar el nivel siembra lo anterior sin bajar lo demostrado ni inventar encuentros', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioProgreso();
    final catalogo = CatalogoHabilidades.paraTests(
      reglasDecaimiento: const ReglasDecaimiento(diasMaestriaACompetente: 21, diasCompetenteAEnDesarrollo: 14, nivelSuelo: 1),
      habilidades: {
        'FR.01': _habilidad('FR.01', '4P'),
        'FR.10': _habilidad('FR.10', '5P'),
        'FR.19': _habilidad('FR.19', '6P'),
        'ALG.01': _habilidad('ALG.01', '1E'),
      },
    );
    await repositorio.guardarEstadoHabilidad(
        EstadoHabilidad.inicial('FR.10').copiarCon(nivel: NivelMaestria.maestria, totalExposiciones: 9));
    final sembradas = await aplicarNivelDePartida(repositorio, NivelEscolar.sextoPrimaria,
        origen: 'prueba', catalogo: catalogo);
    expect(sembradas, 1); // FR.01; FR.10 ya estaba en maestría
    expect((await repositorio.cargarEstadoHabilidad('FR.01'))!.nivel, NivelMaestria.competente);
    expect((await repositorio.cargarEstadoHabilidad('FR.01'))!.totalExposiciones, 0);
    expect((await repositorio.cargarEstadoHabilidad('FR.10'))!.nivel, NivelMaestria.maestria);
    expect(await repositorio.cargarEstadoHabilidad('FR.19'), isNull);
    expect(await repositorio.cargarNivelEscolar(), NivelEscolar.sextoPrimaria);
    expect(await repositorio.cargarOrigenNivelEscolar(), 'prueba');
    await repositorio.guardarEsquirlas(20);
    expect(await repositorio.cargarEsquirlasParaAcceso(), 100);
  });

  test('el selector aparta lo que queda muy atrás, salvo lo que cuesta', () async {
    final catalogo = CatalogoHabilidades.paraTests(
      reglasDecaimiento: const ReglasDecaimiento(diasMaestriaACompetente: 21, diasCompetenteAEnDesarrollo: 14, nivelSuelo: 1),
      rangos: const ['Aprendiz_I'],
      habilidades: {
        'FR.01': _habilidad('FR.01', '4P'),
        'FR.02': _habilidad('FR.02', '4P'),
        'FR.03': _habilidad('FR.03', '4P'),
        'FR.19': _habilidad('FR.19', '6P'),
        'FR.21': _habilidad('FR.21', '6P'),
      },
    );
    final estados = <String, EstadoHabilidad>{
      // FR.03 le cuesta: 4 intentos y precisión baja.
      'FR.03': EstadoHabilidad.inicial('FR.03').copiarCon(
        nivel: NivelMaestria.introducida,
        precision: 0.25,
        intentosRecientes: [
          for (var i = 0; i < 4; i++)
            IntentoHabilidad(instante: DateTime(2026, 9, 1), acierto: i == 0, dificultad: 1, duracionSegundos: 10),
        ],
      ),
    };
    final elegidas = <String>{};
    for (var semilla = 0; semilla < 60; semilla++) {
      final selector = SelectorHabilidades(
          catalogo: catalogo, cargarEstado: (id) async => estados[id], semilla: semilla);
      elegidas.add((await selector.elegirSiguienteHabilidad(
        distrito: CatalogoDistritos.tejados,
        nivelEscolar: NivelEscolar.primeroEso,
      ))!);
    }
    expect(elegidas, isNot(contains('FR.01')));
    expect(elegidas, isNot(contains('FR.02')));
    expect(elegidas, containsAll(['FR.03', 'FR.19', 'FR.21']));
  });

  test('la dificultad no baja de lo que ya domina', () {
    expect(dificultadMinimaPorMaestria(null), 0);
    expect(dificultadMinimaPorMaestria(NivelMaestria.competente), 5);
    expect(dificultadMinimaPorMaestria(NivelMaestria.maestria), 7);
  });
}
