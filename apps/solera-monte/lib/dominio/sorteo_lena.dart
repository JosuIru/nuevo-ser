/// Sorteo de lotes de leña vecinal, **reproducible y verificable**.
///
/// No usa `Random`: el orden sale de una función resumen pública (SHA-256),
/// así que cualquiera puede repetirlo con la misma lista y la misma semilla,
/// en la app o a mano con `sha256sum`, sin fiarse de nadie:
///
/// 1. Cada participante se escribe sin espacios sobrantes
///    ([normalizarParticipante]).
/// 2. Para cada uno se calcula `SHA-256("<semilla>|<participante>")` en
///    UTF-8, escrito en hexadecimal ([claveSorteo]).
/// 3. Se ordenan las claves de menor a mayor (orden alfabético del texto
///    hexadecimal).
/// 4. El primero se lleva el lote de número más bajo, el segundo el
///    siguiente, y así. Si hay más participantes que lotes, los que sobran
///    quedan en **lista de espera** en ese mismo orden; si hay más lotes,
///    los últimos quedan sin adjudicar.
///
/// Por qué es justo: SHA-256 reparte las claves de forma que nadie puede
/// prever ni elegir su puesto sin conocer la semilla. Por eso la lista se
/// cierra (y se publica su [huellaLista]) **antes** de conocerse la semilla,
/// que sale de una fuente pública posterior. Es la misma idea que Concejo
/// aplica a la urna (azar inyectable y comprobable en los tests), llevada a
/// un azar que también pueden comprobar los vecinos.
///
/// Quién tiene derecho a lote y cuánto vale cada lote lo deciden la
/// ordenanza, los estatutos o la costumbre (TRRL art. 75; Ley 55/1980,
/// art. 5.Cuatro): la app sortea entre la lista que da la junta.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Quita espacios al principio y al final y deja uno solo entre palabras.
String normalizarParticipante(String participante) =>
    participante.trim().replaceAll(RegExp(r'\s+'), ' ');

/// `SHA-256("<semilla>|<participante>")` en hexadecimal (64 caracteres).
String claveSorteo(String semilla, String participante) => sha256
    .convert(utf8.encode('$semilla|${normalizarParticipante(participante)}'))
    .toString();

/// Huella de la lista cerrada: `SHA-256` de los participantes normalizados
/// unidos por saltos de línea, en el orden de la lista. Se publica antes de
/// la semilla: si alguien cambia la lista, la huella cambia.
String huellaLista(List<String> participantes) => sha256
    .convert(utf8.encode(participantes.map(normalizarParticipante).join('\n')))
    .toString();

/// Por qué no se puede sortear.
enum ErrorSorteo {
  sinSemilla,
  sinParticipantes,
  sinLotes,
  participanteRepetido
}

class SorteoNoValido implements Exception {
  const SorteoNoValido(this.error, [this.detalle = '']);
  final ErrorSorteo error;
  final String detalle;
  @override
  String toString() =>
      'SorteoNoValido(${error.name}${detalle.isEmpty ? '' : ': $detalle'})';
}

/// Un puesto del orden del sorteo.
class PuestoSorteo {
  const PuestoSorteo({
    required this.posicion,
    required this.participante,
    required this.clave,
    this.numeroLote,
  });

  /// 1, 2, 3… en el orden que sale.
  final int posicion;
  final String participante;
  final String clave;

  /// Lote que le toca; null = lista de espera.
  final int? numeroLote;
}

class ResultadoSorteo {
  const ResultadoSorteo({
    required this.semilla,
    required this.huella,
    required this.orden,
    required this.lotesSinAdjudicar,
  });

  final String semilla;
  final String huella;

  /// Todos los participantes, en el orden del sorteo.
  final List<PuestoSorteo> orden;

  /// Números de lote que no se llevó nadie.
  final List<int> lotesSinAdjudicar;

  Iterable<PuestoSorteo> get adjudicados =>
      orden.where((puesto) => puesto.numeroLote != null);
  Iterable<PuestoSorteo> get listaEspera =>
      orden.where((puesto) => puesto.numeroLote == null);

  /// Lote → participante.
  Map<int, String> get adjudicacionPorLote => {
        for (final puesto in adjudicados)
          puesto.numeroLote!: puesto.participante
      };
}

/// Sortea [numerosLote] entre [participantes] con [semilla]. Lanza
/// [SorteoNoValido] si falta algo o si hay un participante repetido (sin
/// distinguir mayúsculas): dos «Casa Juana» harían dudar del resultado.
ResultadoSorteo sortear({
  required String semilla,
  required List<String> participantes,
  required List<int> numerosLote,
}) {
  if (semilla.trim().isEmpty) {
    throw const SorteoNoValido(ErrorSorteo.sinSemilla);
  }
  final normalizados = participantes
      .map(normalizarParticipante)
      .where((participante) => participante.isNotEmpty)
      .toList();
  if (normalizados.isEmpty) {
    throw const SorteoNoValido(ErrorSorteo.sinParticipantes);
  }
  if (numerosLote.isEmpty) throw const SorteoNoValido(ErrorSorteo.sinLotes);
  final vistos = <String>{};
  for (final participante in normalizados) {
    if (!vistos.add(participante.toLowerCase())) {
      throw SorteoNoValido(ErrorSorteo.participanteRepetido, participante);
    }
  }

  final conClave = [
    for (final participante in normalizados)
      (participante, claveSorteo(semilla, participante)),
  ]..sort((a, b) {
      final porClave = a.$2.compareTo(b.$2);
      return porClave != 0 ? porClave : a.$1.compareTo(b.$1);
    });
  final lotesOrdenados = numerosLote.toSet().toList()..sort();

  return ResultadoSorteo(
    semilla: semilla,
    huella: huellaLista(normalizados),
    orden: [
      for (final (indice, (participante, clave)) in conClave.indexed)
        PuestoSorteo(
          posicion: indice + 1,
          participante: participante,
          clave: clave,
          numeroLote:
              indice < lotesOrdenados.length ? lotesOrdenados[indice] : null,
        ),
    ],
    lotesSinAdjudicar: lotesOrdenados.length > conClave.length
        ? lotesOrdenados.sublist(conClave.length)
        : const [],
  );
}

/// Comprueba un resultado publicado: repite el sorteo y dice si coincide
/// lote a lote.
bool verificarSorteo({
  required String semilla,
  required List<String> participantes,
  required List<int> numerosLote,
  required Map<int, String> adjudicacionPublicada,
}) {
  final repetido = sortear(
          semilla: semilla,
          participantes: participantes,
          numerosLote: numerosLote)
      .adjudicacionPorLote;
  if (repetido.length != adjudicacionPublicada.length) return false;
  return repetido.entries.every((entrada) =>
      normalizarParticipante(adjudicacionPublicada[entrada.key] ?? '') ==
      entrada.value);
}

/// Separa la lista pegada (una persona o casa por línea).
List<String> leerListaParticipantes(String texto) => texto
    .split('\n')
    .map(normalizarParticipante)
    .where((linea) => linea.isNotEmpty)
    .toList();
