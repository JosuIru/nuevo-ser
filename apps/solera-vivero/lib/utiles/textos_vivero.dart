import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/pasaporte.dart';

String nombreTipoZona(String id) => switch (id) {
      'nave' => SoleraL10n.t('vive.zona_nave'),
      'invernadero' => SoleraL10n.t('vive.zona_invernadero'),
      'umbraculo' => SoleraL10n.t('vive.zona_umbraculo'),
      'exterior' => SoleraL10n.t('vive.zona_exterior'),
      _ => id,
    };

String nombreTipoMaterial(String id) => switch (id) {
      'semilla' => SoleraL10n.t('vive.material_semilla'),
      'esqueje' => SoleraL10n.t('vive.material_esqueje'),
      'planta_madre' => SoleraL10n.t('vive.material_planta_madre'),
      'planton' => SoleraL10n.t('vive.material_planton'),
      'bulbo' => SoleraL10n.t('vive.material_bulbo'),
      _ => id,
    };

String nombreFormato(String id) => switch (id) {
      'alveolo' => SoleraL10n.t('vive.formato_alveolo'),
      'maceta' => SoleraL10n.t('vive.formato_maceta'),
      'contenedor' => SoleraL10n.t('vive.formato_contenedor'),
      'cepellon' => SoleraL10n.t('vive.formato_cepellon'),
      'raiz_desnuda' => SoleraL10n.t('vive.formato_raiz_desnuda'),
      _ => id,
    };

String nombreMetodoSiembra(String id) => switch (id) {
      'siembra' => SoleraL10n.t('vive.metodo_siembra'),
      'estaquillado' => SoleraL10n.t('vive.metodo_estaquillado'),
      'injerto' => SoleraL10n.t('vive.metodo_injerto'),
      'plantacion' => SoleraL10n.t('vive.metodo_plantacion'),
      _ => id,
    };

String nombreCategoriaForestal(String id) => switch (id) {
      'identificado' => SoleraL10n.t('vive.forestal_identificado'),
      'seleccionado' => SoleraL10n.t('vive.forestal_seleccionado'),
      'cualificado' => SoleraL10n.t('vive.forestal_cualificado'),
      'controlado' => SoleraL10n.t('vive.forestal_controlado'),
      '' => SoleraL10n.t('vive.forestal_no'),
      _ => id,
    };

String nombreEficacia(String id) => switch (id) {
      'buena' => SoleraL10n.t('vive.eficacia_buena'),
      'regular' => SoleraL10n.t('vive.eficacia_regular'),
      'mala' => SoleraL10n.t('vive.eficacia_mala'),
      _ => id,
    };

String nombreTipoInspeccion(String id) => switch (id) {
      'autoinspeccion' => SoleraL10n.t('vive.inspeccion_autoinspeccion'),
      'oficial' => SoleraL10n.t('vive.inspeccion_oficial'),
      _ => id,
    };

String nombreResultadoInspeccion(String id) => switch (id) {
      'no_detectada' => SoleraL10n.t('vive.resultado_no_detectada'),
      'sospecha' => SoleraL10n.t('vive.resultado_sospecha'),
      'detectada' => SoleraL10n.t('vive.resultado_detectada'),
      _ => id,
    };

/// Lo que se le dice a la persona sobre el pasaporte de una salida.
String textoNecesidadPasaporte(NecesidadPasaporte necesidad) =>
    switch (necesidad) {
      NecesidadPasaporte.necesario => SoleraL10n.t('vive.pasaporte_necesario'),
      NecesidadPasaporte.necesarioZonaProtegida =>
        SoleraL10n.t('vive.pasaporte_necesario_zp'),
      NecesidadPasaporte.noUsuarioFinal =>
        SoleraL10n.t('vive.pasaporte_no_usuario_final'),
      NecesidadPasaporte.noTrasladoPropio =>
        SoleraL10n.t('vive.pasaporte_no_traslado_propio'),
      NecesidadPasaporte.porVerificar =>
        SoleraL10n.t('vive.pasaporte_por_verificar'),
    };

String textoDatoFaltante(DatoPasaporteFaltante dato) => switch (dato) {
      DatoPasaporteFaltante.nombreBotanico =>
        SoleraL10n.t('vive.falta_nombre_botanico'),
      DatoPasaporteFaltante.codigoOperador =>
        SoleraL10n.t('vive.falta_codigo_operador'),
      DatoPasaporteFaltante.codigoTrazabilidad =>
        SoleraL10n.t('vive.falta_codigo_trazabilidad'),
      DatoPasaporteFaltante.paisOrigen =>
        SoleraL10n.t('vive.falta_pais_origen'),
      DatoPasaporteFaltante.plagasZonaProtegida =>
        SoleraL10n.t('vive.falta_plagas_zp'),
    };

/// 1234.5 céntimos → «12,35 €» (formato del idioma de la app).
String formatearEuros(num centimos) => NumberFormat.currency(
        locale: SoleraL10n.idioma, symbol: '€', decimalDigits: 2)
    .format(centimos / 100);

/// Número con [decimales] en el formato del idioma de la app.
String formatearNumero(num valor, {int decimales = 1}) =>
    NumberFormat.decimalPatternDigits(
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

/// Inicio y fin (ms, ambos incluidos) del año natural [anyo].
(int, int) intervaloAnyo(int anyo) => (
      DateTime(anyo).millisecondsSinceEpoch,
      DateTime(anyo + 1).millisecondsSinceEpoch - 1,
    );
