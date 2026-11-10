import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/backup_servicio.dart';

/// Texto para la persona según el motivo del error. Solo dice que los
/// datos no se han tocado cuando es verdad ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopiaSeguridad(ErrorCopiaSeguridad error, {bool alRestaurar = true}) {
  final String causa;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      causa = SoleraL10n.t('agro.copia_error_fichero_no_existe');
    case MotivoErrorCopiaSeguridad.noEsZip:
      causa = SoleraL10n.t('agro.copia_error_no_es_zip');
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      causa = SoleraL10n.t('agro.copia_error_incompleta');
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      causa = SoleraL10n.t('agro.copia_error_version_mas_nueva');
    case MotivoErrorCopiaSeguridad.deOtraApp:
      causa = SoleraL10n.t('agro.copia_error_otra_app');
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      causa = SoleraL10n.t('agro.copia_error_sin_base_datos');
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      causa = SoleraL10n.t('agro.copia_error_bd_danada');
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      causa = SoleraL10n.t('agro.copia_error_rutas_no_permitidas');
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      causa = SoleraL10n.t('agro.copia_error_respaldo_previo');
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      causa = SoleraL10n.t('agro.copia_error_sin_datos');
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      causa = SoleraL10n.t('agro.copia_error_revertida');
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      return [
        SoleraL10n.t('agro.copia_error_reversion_fallida'),
        if (respaldo != null)
          SoleraL10n.tf('agro.copia_estado_anterior_en', {'ruta': respaldo.path}),
        SoleraL10n.tf('agro.copia_no_borres_app', {'detalle': error.mensaje}),
      ].join(' ');
  }
  if (!alRestaurar) return '${SoleraL10n.t('agro.copia_no_se_pudo_crear')} $causa';
  return error.datosIntactos
      ? '$causa ${SoleraL10n.t('agro.copia_datos_intactos')}'
      : causa;
}

/// Pantalla de backup/restore. Operaciones lentas (segundos) y
/// destructivas — UI explícita con confirmaciones para que el usuario
/// nunca pierda datos por accidente.
class PantallaBackup extends StatefulWidget {
  PantallaBackup({super.key});

  @override
  State<PantallaBackup> createState() => _PantallaBackupState();
}

class _PantallaBackupState extends State<PantallaBackup> {
  bool _trabajando = false;
  DateTime? _ultimoBackup;

  @override
  void initState() {
    super.initState();
    _cargarUltimoBackup();
  }

  Future<void> _cargarUltimoBackup() async {
    final ultimaCopia = await servicioCopiaSeguridadAgro.ultimaCopia();
    if (mounted) setState(() => _ultimoBackup = ultimaCopia);
  }

  void _avisar(String mensaje, {int segundos = 6}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: segundos), content: Text(mensaje)),
    );
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await servicioCopiaSeguridadAgro.crearCopia();
      await _cargarUltimoBackup();
      if (!mounted) return;
      await Share.shareXFiles([XFile(fichero.path)], subject: SoleraL10n.t('agro.asunto_copia_seguridad'));
    } on ErrorCopiaSeguridad catch (error) {
      if (!mounted) return;
      _avisar(textoErrorCopiaSeguridad(error, alRestaurar: false), segundos: 8);
    } catch (error) {
      if (!mounted) return;
      _avisar(SoleraL10n.tf('agro.copia_no_se_pudo_crear_error', {'error': error}), segundos: 8);
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _restaurar() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (resultado == null || resultado.files.isEmpty) return;
    final ruta = resultado.files.first.path;
    if (ruta == null) return;
    final copia = File(ruta);

    // Primero se comprueba la copia sin tocar nada, para enseñar de
    // cuándo es antes de pedir confirmación.
    setState(() => _trabajando = true);
    final InformeCopiaSeguridad informe;
    try {
      informe = await servicioCopiaSeguridadAgro.validarCopia(copia);
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(textoErrorCopiaSeguridad(error), segundos: 8);
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(SoleraL10n.tf('agro.copia_no_se_pudo_leer', {'error': error}), segundos: 8);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fechaCopia = informe.fechaCreacion;
    final descripcionCopia = fechaCopia != null
        ? SoleraL10n.tf('agro.copia_del_fecha', {
            'fecha': DateFormat.yMMMMd(SoleraL10n.idioma).add_Hm().format(fechaCopia),
          })
        : SoleraL10n.tf('agro.copia_sin_fecha', {
            'fecha': DateFormat('d/M/yyyy HH:mm', 'es_ES').format(copia.lastModifiedSync()),
          });
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: SoleraL10n.t('agro.restaurar_una_copia_de_seguridad'),
      mensaje: '${SoleraL10n.tf('agro.copia_con_n_fotos', {
            'descripcion': descripcionCopia,
            'n': informe.numeroFicherosExtra,
          })}\n\n${SoleraL10n.t('agro.copia_aviso_sustitucion')}',
      textoConfirmar: SoleraL10n.t('agro.restaurar'),
      textoCancelar: SoleraL10n.t('cancelar'),
      icono: Icons.restore,
    );
    if (confirmado != true || !mounted) return;

    setState(() => _trabajando = true);
    try {
      await servicioCopiaSeguridadAgro.restaurarCopia(copia);
      if (!mounted) return;
      _avisar(
        SoleraL10n.t('agro.copia_restaurada'),
        segundos: 8,
      );
    } on ErrorCopiaSeguridad catch (error) {
      if (!mounted) return;
      _avisar(textoErrorCopiaSeguridad(error), segundos: 10);
    } catch (error) {
      if (!mounted) return;
      _avisar(SoleraL10n.tf('agro.error_al_restaurar', {'error': error}), segundos: 10);
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _ultimoBackup;
    final hace = ultimo == null ? null : DateTime.now().difference(ultimo);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('copia_de_seguridad'))),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      ultimo == null ? Icons.warning_amber : (hace != null && hace.inDays > 7 ? Icons.error_outline : Icons.check_circle),
                      color: ultimo == null ? Colors.orange : (hace != null && hace.inDays > 7 ? Colors.red : Colors.green),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(SoleraL10n.t('agro.ultima_copia'), style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimo == null
                                ? SoleraL10n.t('agro.nunca_copia')
                                : DateFormat.yMMMMd(SoleraL10n.idioma).add_Hm().format(ultimo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(SoleraL10n.t('agro.crear_copia'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              SoleraL10n.t('agro.crear_copia_explicacion'),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            FilledButton.icon(
              icon: Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? SoleraL10n.t('agro.empaquetando') : SoleraL10n.t('crear_y_compartir_backup')),
            ),
            Divider(height: 32),
            Text(SoleraL10n.t('agro.restaurar_una_copia'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              SoleraL10n.t('agro.restaurar_copia_explicacion'),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text(SoleraL10n.t('restaurar_desde_zip')),
            ),
          ],
        ),
      ),
    );
  }
}
