import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../modelos/registro_autocontrol.dart';
import '../modelos/titular.dart';
import '../utiles/textos_obrador.dart';

/// Sello del documento hasta que un técnico de seguridad alimentaria valide
/// el formato (BLOQUEOS-PENDIENTES.md). Lo vigila test/sello_provisional_test.dart.
const String selloCuadernoAutocontrol = 'PROVISIONAL';

/// Tablas del cuaderno: una por tipo de registro que tenga apuntes, y una
/// final con los incorrectos y su acción correctora.
List<TablaInforme> tablasCuadernoAutocontrol(
    List<RegistroAutocontrol> registros) {
  final formato = DateFormat('dd/MM HH:mm');
  String fecha(RegistroAutocontrol registro) =>
      formato.format(DateTime.fromMillisecondsSinceEpoch(registro.fechaMs));
  final tablas = <TablaInforme>[];
  for (final tipo in tiposRegistroAutocontrol) {
    final delTipo =
        registros.where((registro) => registro.tipo == tipo).toList();
    if (delTipo.isEmpty) continue;
    final conValor = tipo == 'temperatura' || tipo == 'proveedor';
    tablas.add(TablaInforme(
      titulo: nombreTipoAutocontrol(tipo),
      headers: [
        SoleraL10n.t('obra.fecha'),
        SoleraL10n.t('obra.elemento_corto'),
        if (conValor) '°C',
        SoleraL10n.t('obra.correcto'),
        SoleraL10n.t('obra.responsable'),
      ],
      filas: [
        for (final registro in delTipo)
          [
            fecha(registro),
            registro.elemento,
            if (conValor)
              registro.valor == null ? '' : formatearNumero(registro.valor!),
            registro.correcto
                ? SoleraL10n.t('obra.si')
                : SoleraL10n.t('obra.no'),
            registro.responsable,
          ],
      ],
    ));
  }
  final incorrectos =
      registros.where((registro) => !registro.correcto).toList();
  tablas.add(TablaInforme(
    titulo: SoleraL10n.t('obra.incidencias_y_acciones'),
    headers: [
      SoleraL10n.t('obra.fecha'),
      SoleraL10n.t('obra.tipo'),
      SoleraL10n.t('obra.elemento_corto'),
      SoleraL10n.t('obra.accion_correctora'),
    ],
    filas: [
      for (final registro in incorrectos)
        [
          fecha(registro),
          nombreTipoAutocontrol(registro.tipo),
          registro.elemento,
          registro.faltaAccionCorrectora
              ? SoleraL10n.t('obra.falta_accion')
              : registro.accionCorrectora,
        ],
    ],
    mensajeSiVacia: SoleraL10n.t('obra.sin_incidencias'),
  ));
  return tablas;
}

/// Cuaderno de autocontrol de un mes en PDF.
Future<Uint8List> generarCuadernoAutocontrolPdf({
  required DateTime mes,
  required Titular titular,
  required List<RegistroAutocontrol> registros,
  pw.ThemeData? tema,
}) {
  final nombreMes = DateFormat.yMMMM(SoleraL10n.idioma).format(mes);
  final incorrectos = registros.where((registro) => !registro.correcto).length;
  final sinAccion =
      registros.where((registro) => registro.faltaAccionCorrectora).length;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('obra.cuaderno_autocontrol')} · $nombreMes',
    subtituloCabecera: '${titular.nombre}'
        '${titular.registroSanitario.isEmpty ? '' : ' · ${SoleraL10n.t('obra.registro_sanitario')}: ${titular.registroSanitario}'}'
        ' · $selloCuadernoAutocontrol',
    bulletsResumen: [
      SoleraL10n.tf('obra.resumen_registros', {'n': registros.length}),
      SoleraL10n.tf('obra.resumen_incorrectos', {'n': incorrectos}),
      if (sinAccion > 0)
        SoleraL10n.tf('obra.resumen_sin_accion', {'n': sinAccion}),
      SoleraL10n.t('obra.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoAutocontrol(registros),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
