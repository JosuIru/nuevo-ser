import 'dart:convert';
import 'dart:typed_data';

import '../modelos/registro_actividad.dart';
import 'documento_generado.dart';

/// Kg de alimentación de un día y lote.
class FilaAlimentacion {
  const FilaAlimentacion(this.dia, this.lote, this.kg);
  final DateTime dia;
  final String lote;
  final double kg;
}

/// Alimentación suministrada por día y lote (hora local del móvil), con los
/// kg sumados, ordenada por día y lote. Mismo cálculo que
/// `szs_alimentacion_por_dias` en el WordPress.
List<FilaAlimentacion> alimentacionPorDias(List<RegistroActividad> registros) {
  final suma = <(DateTime, String), double>{};
  for (final registro in registros) {
    if (registro.tipo != 'alimentacion') continue;
    final momento = DateTime.fromMillisecondsSinceEpoch(registro.fechaMs);
    final clave = (
      DateTime(momento.year, momento.month, momento.day),
      registro.lote.trim()
    );
    suma.update(clave, (kg) => kg + registro.cantidad,
        ifAbsent: () => registro.cantidad);
  }
  final filas = [
    for (final entrada in suma.entries)
      FilaAlimentacion(entrada.key.$1, entrada.key.$2, entrada.value),
  ];
  filas.sort((a, b) {
    final porDia = a.dia.compareTo(b.dia);
    return porDia != 0 ? porDia : a.lote.compareTo(b.lote);
  });
  return filas;
}

/// CSV para Excel (`;`, coma decimal, fecha dd/mm/aaaa) con fila de total.
String alimentacionACsv(List<FilaAlimentacion> filas) {
  String numero(double kg) {
    final texto = kg.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
    return texto.replaceAll('.', ',');
  }

  String dosCifras(int valor) => valor.toString().padLeft(2, '0');
  String campo(String texto) => RegExp(r'[;"\r\n]').hasMatch(texto)
      ? '"${texto.replaceAll('"', '""')}"'
      : texto;

  var total = 0.0;
  final lineas = ['Fecha;Lote;Kg'];
  for (final fila in filas) {
    lineas.add(
        '${dosCifras(fila.dia.day)}/${dosCifras(fila.dia.month)}/${fila.dia.year};${campo(fila.lote)};${numero(fila.kg)}');
    total += fila.kg;
  }
  lineas.add('Total;;${numero(total)}');
  return '﻿${lineas.join('\r\n')}\r\n';
}

/// El CSV listo para compartir o descargar (ya lleva el BOM para Excel).
DocumentoGenerado documentoAlimentacion(
        String nombreProyecto, List<RegistroActividad> registros) =>
    DocumentoGenerado(
      nombreFichero:
          'alimentacion_${nombreSeguroFichero(nombreProyecto.isEmpty ? 'proyecto' : nombreProyecto)}.csv',
      bytes: Uint8List.fromList(
          utf8.encode(alimentacionACsv(alimentacionPorDias(registros)))),
      tipoMime: 'text/csv',
    );
