import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/recoleccion.dart';
import '../dominio/rendimientos.dart';

/// Nombre visible de un valor cerrado: `arom.<grupo>_<id>`. Si la clave no
/// existe (un dato antiguo o raro), el propio id.
String _nombreValor(String grupo, String id) {
  if (id.isEmpty) return '';
  final clave = 'arom.${grupo}_$id';
  final texto = SoleraL10n.t(clave);
  return texto == clave ? id : texto;
}

String nombreTipoTerreno(String id) => _nombreValor('terreno', id);
String nombreEstadoFenologico(String id) => _nombreValor('feno', id);
String nombreMetodoSecado(String id) => _nombreValor('secado', id);
String nombreTipoAlambique(String id) => _nombreValor('alambique', id);
String nombreEstadoPlanta(String id) => _nombreValor('planta', id);
String nombreTipoLote(String id) => _nombreValor('lote', id);
String nombreDestinoLote(String id) => _nombreValor('destino', id);
String nombreEficacia(String id) => _nombreValor('eficacia', id);
String nombreCategoriaEconomica(String id) => _nombreValor('categoria', id);
String nombreRegimenIva(String id) => _nombreValor('regimen', id);

String textoAvisoRecoleccion(AvisoRecoleccion aviso) => switch (aviso) {
      AvisoRecoleccion.sinPermiso => SoleraL10n.t('arom.aviso_sin_permiso'),
      AvisoRecoleccion.fueraDeVigencia =>
        SoleraL10n.t('arom.aviso_fuera_vigencia'),
      AvisoRecoleccion.especieNoIncluida =>
        SoleraL10n.t('arom.aviso_especie_no_incluida'),
      AvisoRecoleccion.superaLimite => SoleraL10n.t('arom.aviso_supera_limite'),
      AvisoRecoleccion.especieConProteccion =>
        SoleraL10n.t('arom.aviso_especie_protegida'),
    };

String textoComparacion(ComparacionRendimiento comparacion) =>
    switch (comparacion) {
      ComparacionRendimiento.sinReferencia => '',
      ComparacionRendimiento.porDebajo => SoleraL10n.t('arom.rend_por_debajo'),
      ComparacionRendimiento.dentro => SoleraL10n.t('arom.rend_dentro'),
      ComparacionRendimiento.porEncima => SoleraL10n.t('arom.rend_por_encima'),
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
