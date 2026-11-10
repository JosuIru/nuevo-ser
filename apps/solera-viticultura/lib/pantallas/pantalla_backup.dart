import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/backup_servicio.dart';

/// Texto para la persona según el motivo de un [ErrorCopiaSeguridad].
/// Solo dice que los datos no se han tocado cuando es verdad
/// ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopiaSeguridad(ErrorCopiaSeguridad error) {
  final String explicacion;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      explicacion = SoleraL10n.t('viti.backup_error_fichero_no_existe');
    case MotivoErrorCopiaSeguridad.noEsZip:
      explicacion = SoleraL10n.t('viti.backup_error_no_es_zip');
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      explicacion = SoleraL10n.t('viti.backup_error_manifiesto');
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      explicacion = SoleraL10n.t('viti.backup_error_version_nueva');
    case MotivoErrorCopiaSeguridad.deOtraApp:
      explicacion = SoleraL10n.t('viti.backup_error_otra_app');
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      explicacion = SoleraL10n.t('viti.backup_error_sin_datos_app');
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      explicacion = SoleraL10n.t('viti.backup_error_bd_danada');
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      explicacion = SoleraL10n.t('viti.backup_error_ruta_peligrosa');
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      explicacion = SoleraL10n.t('viti.backup_error_respaldo_previo');
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      explicacion = SoleraL10n.t('viti.backup_error_sin_datos');
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      explicacion = SoleraL10n.t('viti.backup_error_revertida');
    case MotivoErrorCopiaSeguridad.reversionFallida:
      explicacion = SoleraL10n.tf('viti.backup_error_reversion_fallida', {
        'ruta': error.respaldoPrevio?.path ?? error.mensaje,
      });
  }
  if (!error.datosIntactos) return explicacion;
  return '$explicacion ${SoleraL10n.t('viti.backup_datos_intactos')}';
}

/// Pantalla de copia de seguridad y restauración. Operaciones lentas
/// (segundos) y delicadas: confirmaciones explícitas para que la persona
/// nunca pierda datos por accidente.
class PantallaBackup extends StatefulWidget {
  const PantallaBackup({super.key});

  @override
  State<PantallaBackup> createState() => _PantallaBackupState();
}

class _PantallaBackupState extends State<PantallaBackup> {
  final _servicioCopia = servicioCopiaSeguridadViticultura;

  /// «3/11/2026 a las 18:05» en el idioma actual.
  String _fechaConHora(DateTime momento) => SoleraL10n.tf('viti.fecha_a_las_hora', {
        'fecha': DateFormat('d/MM/yyyy').format(momento),
        'hora': DateFormat('HH:mm').format(momento),
      });
  bool _trabajando = false;
  DateTime? _ultimaCopia;

  @override
  void initState() {
    super.initState();
    _cargarUltimaCopia();
  }

  Future<void> _cargarUltimaCopia() async {
    final ultimaCopia = await _servicioCopia.ultimaCopia();
    if (mounted) setState(() => _ultimaCopia = ultimaCopia);
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 8), content: Text(mensaje)),
    );
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await _servicioCopia.crearCopia();
      await _cargarUltimaCopia();
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        subject: SoleraL10n.t('viti.backup_asunto_compartir'),
      );
    } on ErrorCopiaSeguridad catch (errorCopia) {
      if (mounted) _avisar('${SoleraL10n.t('viti.backup_no_se_pudo_crear')} ${textoErrorCopiaSeguridad(errorCopia)}');
    } catch (error) {
      if (mounted) _avisar('${SoleraL10n.t('viti.backup_no_se_pudo_crear')} $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _restaurar() async {
    final seleccion = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (seleccion == null || seleccion.files.isEmpty) return;
    final ruta = seleccion.files.first.path;
    if (ruta == null) return;
    final ficheroCopia = File(ruta);

    setState(() => _trabajando = true);
    final InformeCopiaSeguridad informe;
    try {
      informe = await _servicioCopia.validarCopia(ficheroCopia);
    } on ErrorCopiaSeguridad catch (errorCopia) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar('${SoleraL10n.t('viti.backup_no_restaurable')} ${textoErrorCopiaSeguridad(errorCopia)}');
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(SoleraL10n.tf('viti.backup_no_se_pudo_leer', {'error': error}));
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fechaCopia = informe.fechaCreacion;
    final descripcionFecha = fechaCopia != null
        ? SoleraL10n.tf('viti.backup_copia_del', {'fecha': _fechaConHora(fechaCopia)})
        : SoleraL10n.t('viti.backup_copia_sin_fecha');
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: SoleraL10n.t('viti.backup_restaurar_esta_copia'),
      mensaje: '$descripcionFecha · ${SoleraL10n.tf('viti.n_fotos', {'n': informe.numeroFicherosExtra})}\n\n'
          '${SoleraL10n.t('viti.backup_restaurar_explicacion')}',
      textoConfirmar: SoleraL10n.t('viti.restaurar'),
      textoCancelar: SoleraL10n.t('cancelar'),
      icono: Icons.restore,
    );
    if (confirmado != true || !mounted) return;

    setState(() => _trabajando = true);
    try {
      final resultado = await _servicioCopia.restaurarCopia(ficheroCopia);
      if (!mounted) return;
      final respaldoPrevio = resultado.respaldoPrevio;
      _avisar(respaldoPrevio != null
          ? SoleraL10n.tf('viti.backup_restaurada_con_respaldo', {
              'fichero': respaldoPrevio.path.split('/').last,
            })
          : SoleraL10n.t('viti.backup_restaurada'));
    } on ErrorCopiaSeguridad catch (errorCopia) {
      if (mounted) _avisar('${SoleraL10n.t('viti.backup_no_se_pudo_restaurar')} ${textoErrorCopiaSeguridad(errorCopia)}');
    } catch (error) {
      if (mounted) _avisar('${SoleraL10n.t('viti.backup_no_se_pudo_restaurar')} $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimaCopia = _ultimaCopia;
    final tiempoDesdeCopia = ultimaCopia == null ? null : DateTime.now().difference(ultimaCopia);
    final copiaAntigua = tiempoDesdeCopia != null && tiempoDesdeCopia.inDays > 7;
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
                      ultimaCopia == null
                          ? Icons.warning_amber
                          : (copiaAntigua ? Icons.error_outline : Icons.check_circle),
                      color: ultimaCopia == null
                          ? Colors.orange
                          : (copiaAntigua ? Colors.red : Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(SoleraL10n.t('viti.backup_ultima_copia'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimaCopia == null
                                ? SoleraL10n.t('viti.backup_nunca')
                                : _fechaConHora(ultimaCopia),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(SoleraL10n.t('viti.backup_crear_copia'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('viti.backup_crear_explicacion'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? SoleraL10n.t('viti.trabajando') : SoleraL10n.t('crear_y_compartir_backup')),
            ),
            const Divider(height: 32),
            Text(SoleraL10n.t('viti.backup_restaurar_una_copia'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('viti.backup_restaurar_detalle'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text(SoleraL10n.t('viti.backup_elegir_y_restaurar')),
            ),
          ],
        ),
      ),
    );
  }
}
