import 'dart:math' as math;

import 'catalogo_habilidades.dart';
import 'ejercicio.dart';
import 'registro_plantillas.dart';
import 'utilidades.dart';

/// Habilidad que no entra en el lote, con el motivo.
class HabilidadSaltada {
  final String id;
  final String motivo;
  const HabilidadSaltada(this.id, this.motivo);

  @override
  String toString() => '$id: $motivo';
}

class ResultadoSeleccion {
  final List<Habilidad> conFicha;
  final List<HabilidadSaltada> saltadas;
  const ResultadoSeleccion(this.conFicha, this.saltadas);
}

/// Resuelve los ids y dominios pedidos contra el catálogo, sin repetir y
/// en el orden pedido. Lo desconocido o sin plantilla va a [saltadas].
ResultadoSeleccion seleccionarHabilidades(
  CatalogoHabilidades catalogo, {
  List<String> ids = const [],
  List<String> dominios = const [],
  Map<String, PlantillaFicha>? plantillas,
}) {
  final registro = plantillas ?? plantillasPorHabilidad;
  final pedidas = <Habilidad>[];
  final saltadas = <HabilidadSaltada>[];

  for (final id in ids) {
    final habilidad = catalogo.porId(id);
    if (habilidad == null) {
      saltadas.add(HabilidadSaltada(id, 'no existe en skills.json'));
    } else {
      pedidas.add(habilidad);
    }
  }
  for (final dominio in dominios) {
    final delDominio = catalogo.porDominio(dominio);
    if (delDominio.isEmpty) {
      saltadas.add(HabilidadSaltada(dominio, 'dominio desconocido'));
    }
    pedidas.addAll(delDominio);
  }

  final vistas = <String>{};
  final conFicha = <Habilidad>[];
  for (final habilidad in pedidas) {
    if (!vistas.add(habilidad.id)) continue;
    if (registro.containsKey(habilidad.id)) {
      conFicha.add(habilidad);
    } else {
      saltadas.add(HabilidadSaltada(
        habilidad.id,
        motivosSinPlantilla[habilidad.id] ?? 'sin generador de ejercicios todavía',
      ));
    }
  }
  return ResultadoSeleccion(conFicha, saltadas);
}

/// Número de ejercicios por ficha.
const ejerciciosPorFicha = 3;

/// Genera el contenido de la ficha de [habilidad]. La semilla de cada
/// ficha depende de la semilla general y del id, así que la misma semilla
/// da siempre la misma ficha aunque cambie el lote en que se pide.
ContenidoFicha generarContenidoFicha(
  CatalogoHabilidades catalogo,
  Habilidad habilidad, {
  int semilla = 1,
  Map<String, PlantillaFicha>? plantillas,
}) {
  final plantilla = (plantillas ?? plantillasPorHabilidad)[habilidad.id];
  if (plantilla == null) {
    throw ArgumentError('Sin plantilla para ${habilidad.id}');
  }
  final semillaFicha = hashEstable('${habilidad.id}#$semilla');
  final azar = math.Random(semillaFicha);
  final ejercicios = <Ejercicio>[];
  final claves = <String>{};
  // Reintenta para no repetir un ejercicio; si el generador tiene pocas
  // variantes, acepta repetición antes que colgarse.
  for (var intento = 0; ejercicios.length < ejerciciosPorFicha; intento++) {
    final ejercicio = plantilla.generar(azar);
    if (claves.add(ejercicio.clave) || intento > 50) ejercicios.add(ejercicio);
  }
  return ContenidoFicha(
    idHabilidad: habilidad.id,
    nombreHabilidad: habilidad.nombre,
    nombreDominio: catalogo.nombreDominio(habilidad.dominio),
    curso: habilidad.curso,
    descripcion: plantilla.descripcion,
    ejercicios: ejercicios,
    preguntaExplicalo: plantilla.preguntaExplicalo,
    semilla: semilla,
  );
}
