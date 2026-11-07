// PROVISIONAL CORE — módulo transversal T2 (venta directa). Ver socio.dart.

import 'semanas.dart';

/// Tamaños de cesta. Cada tamaño vale unas «partes» en el reparto: la
/// grande recibe el doble que la pequeña.
const Map<String, int> partesPorTamanoCesta = {
  'pequena': 2,
  'mediana': 3,
  'grande': 4,
};

/// Cada cuánto recibe cesta.
const List<String> frecuenciasSuscripcion = ['semanal', 'quincenal'];

/// Suscripción de un socio a las cestas.
class Suscripcion {
  Suscripcion({
    this.id,
    required this.socioId,
    required this.fechaInicioMs,
    this.tamano = 'mediana',
    this.frecuencia = 'semanal',
    this.fechaFinMs,
    this.precioCentimosCesta = 0,
    this.activa = true,
    this.notas = '',
  });

  final int? id;
  final int socioId;

  /// Una de las claves de [partesPorTamanoCesta].
  final String tamano;

  /// Una de [frecuenciasSuscripcion].
  final String frecuencia;
  final int fechaInicioMs;

  /// Null si sigue abierta.
  final int? fechaFinMs;

  /// Precio de cada cesta, en céntimos (IVA incluido, tal como se cobra).
  final int precioCentimosCesta;

  /// En pausa (vacaciones) = false: ese tiempo no recibe cesta.
  final bool activa;
  final String notas;

  int get partes => partesPorTamanoCesta[tamano] ?? 3;

  /// Si le toca cesta la semana de [lunes]: activa, dentro de sus fechas y,
  /// si es quincenal, en semanas alternas contando desde la de inicio.
  bool tocaEnSemana(DateTime lunes) {
    if (!activa) return false;
    final semana = lunesDeSemana(lunes);
    final inicio =
        lunesDeSemana(DateTime.fromMillisecondsSinceEpoch(fechaInicioMs));
    if (semana.isBefore(inicio)) return false;
    if (fechaFinMs != null &&
        semana.isAfter(DateTime.fromMillisecondsSinceEpoch(fechaFinMs!))) {
      return false;
    }
    if (frecuencia == 'quincenal') return semanasEntre(inicio, semana).isEven;
    return true;
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'socio_id': socioId,
        'tamano': tamano,
        'frecuencia': frecuencia,
        'fecha_inicio_ms': fechaInicioMs,
        'fecha_fin_ms': fechaFinMs,
        'precio_centimos_cesta': precioCentimosCesta,
        'activa': activa ? 1 : 0,
        'notas': notas,
      };

  factory Suscripcion.fromMap(Map<String, Object?> mapa) => Suscripcion(
        id: mapa['id'] as int?,
        socioId: mapa['socio_id'] as int,
        tamano: (mapa['tamano'] as String?) ?? 'mediana',
        frecuencia: (mapa['frecuencia'] as String?) ?? 'semanal',
        fechaInicioMs: mapa['fecha_inicio_ms'] as int,
        fechaFinMs: mapa['fecha_fin_ms'] as int?,
        precioCentimosCesta: (mapa['precio_centimos_cesta'] as int?) ?? 0,
        activa: (mapa['activa'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
