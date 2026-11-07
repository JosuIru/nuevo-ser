import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/aprovechamientos.dart';
import '../dominio/incendios.dart';
import '../dominio/plan_gestion.dart';

/// Nombre visible de un valor cerrado: `mont.<grupo>_<id>`. Si la clave no
/// existe (un dato antiguo o raro), el propio id.
String _nombreValor(String grupo, String id) {
  if (id.isEmpty) return '';
  final clave = 'mont.${grupo}_$id';
  final texto = SoleraL10n.t(clave);
  return texto == clave ? id : texto;
}

String nombreFigura(String id) => _nombreValor('figura', id);
String nombreInstrumento(String id) => _nombreValor('instrumento', id);
String nombreCertificacion(String id) => _nombreValor('certificacion', id);
String nombreEstadoMasa(String id) => _nombreValor('masa', id);
String nombreTipoActuacion(String id) => _nombreValor('actuacion', id);
String nombreTipoAprovechamiento(String id) => _nombreValor('aprov', id);
String nombreUnidad(String id) => _nombreValor('unidad', id);
String nombreModalidad(String id) => _nombreValor('modalidad', id);
String nombreTramite(String id) => _nombreValor('tramite', id);
String nombreTipoInfraestructura(String id) => _nombreValor('infra', id);
String nombreEstadoRevision(String id) => _nombreValor('revision', id);
String nombreTipoArbol(String id) => _nombreValor('arbol', id);
String nombreCategoriaEconomica(String id) => _nombreValor('categoria', id);
String nombreRegimenFiscal(String id) => _nombreValor('regimen', id);

String textoEstadoActuacion(EstadoActuacion estado) => switch (estado) {
      EstadoActuacion.pendiente => SoleraL10n.t('mont.estado_pendiente'),
      EstadoActuacion.enCurso => SoleraL10n.t('mont.estado_en_curso'),
      EstadoActuacion.ejecutada => SoleraL10n.t('mont.estado_ejecutada'),
      EstadoActuacion.atrasada => SoleraL10n.t('mont.estado_atrasada'),
      EstadoActuacion.cancelada => SoleraL10n.t('mont.estado_cancelada'),
    };

String textoAvisoAprovechamiento(
        AvisoAprovechamiento aviso, DateTime? limite) =>
    switch (aviso) {
      AvisoAprovechamiento.tramitePendiente =>
        SoleraL10n.t('mont.aviso_tramite_pendiente'),
      AvisoAprovechamiento.superaMenorCuantia =>
        SoleraL10n.t('mont.aviso_menor_cuantia'),
      AvisoAprovechamiento.comunicarCuantia => SoleraL10n.tf(
            'mont.aviso_comunicar_cuantia', {
          'fecha': limite == null
              ? ''
              : formatearFecha(limite.millisecondsSinceEpoch)
        }),
      AvisoAprovechamiento.comunicacionVencida => SoleraL10n.tf(
            'mont.aviso_comunicacion_vencida', {
          'fecha': limite == null
              ? ''
              : formatearFecha(limite.millisecondsSinceEpoch)
        }),
    };

String textoEstadoCampanya(EstadoCampanyaIncendios estado) => switch (estado) {
      EstadoCampanyaIncendios.sinRevisar => SoleraL10n.t('mont.sin_revisar'),
      EstadoCampanyaIncendios.correcta => SoleraL10n.t('mont.revisada_bien'),
      EstadoCampanyaIncendios.conTrabajoPendiente =>
        SoleraL10n.t('mont.con_trabajo_pendiente'),
    };

/// 1234.5 céntimos → «12,35 €» (formato del idioma de la app).
String formatearEuros(num centimos) => NumberFormat.currency(
        locale: SoleraL10n.idioma, symbol: '€', decimalDigits: 2)
    .format(centimos / 100);

/// Número en el formato del idioma de la app: con [decimales] fijos o, sin
/// ellos, con un decimal como mucho y sin ceros de relleno («100», «12,5»).
String formatearNumero(num valor, {int? decimales}) => decimales == null
    ? (NumberFormat.decimalPattern(SoleraL10n.idioma)
          ..maximumFractionDigits = 1)
        .format(valor)
    : NumberFormat.decimalPatternDigits(
            locale: SoleraL10n.idioma, decimalDigits: decimales)
        .format(valor);

/// Fecha corta (dd/MM/aaaa), igual en todos los idiomas: es la de los
/// documentos oficiales.
String formatearFecha(int fechaMs) => DateFormat('dd/MM/yyyy')
    .format(DateTime.fromMillisecondsSinceEpoch(fechaMs));

/// Lee «1.234,5» o «1234.5»; null si no se entiende.
double? leerNumero(String texto) {
  final limpio = texto.trim().replaceAll(' ', '');
  if (limpio.isEmpty) return null;
  final normalizado = limpio.contains(',')
      ? limpio.replaceAll('.', '').replaceAll(',', '.')
      : limpio;
  return double.tryParse(normalizado);
}

/// Lee un entero; null si no se entiende.
int? leerEntero(String texto) => leerNumero(texto)?.round();

/// Número para un campo de texto: vacío si es null o cero.
String numeroParaCampo(num? valor, {int? decimales}) =>
    valor == null || valor == 0
        ? ''
        : formatearNumero(valor, decimales: decimales);

/// Inicio y fin (ms, ambos incluidos) del año natural [anyo].
(int, int) intervaloAnyo(int anyo) => (
      DateTime(anyo).millisecondsSinceEpoch,
      DateTime(anyo + 1).millisecondsSinceEpoch - 1,
    );

/// Huella corta para mostrar (los 12 primeros caracteres).
String huellaCorta(String huella) =>
    huella.length <= 12 ? huella : '${huella.substring(0, 12)}…';
