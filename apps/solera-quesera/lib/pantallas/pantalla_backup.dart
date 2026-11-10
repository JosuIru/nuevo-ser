import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/backup_servicio.dart';
import '../utiles/textos_quesera.dart';

/// Crear y restaurar copias de seguridad (BD + fotos) con el servicio
/// común del core.
class PantallaBackup extends StatefulWidget {
  const PantallaBackup({super.key});
  @override
  State<PantallaBackup> createState() => _PantallaBackupState();
}

class _PantallaBackupState extends State<PantallaBackup> {
  final _servicioCopia = BackupServicioQuesera.instancia;
  DateFormat get _formatoFecha => DateFormat('d MMM yyyy HH:mm', localeFechasQuesera());
  bool _trabajando = false;
  DateTime? _ultimaCopia;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final ultima = await _servicioCopia.ultimaCopia();
    if (mounted) setState(() => _ultimaCopia = ultima);
  }

  void _avisar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto), duration: const Duration(seconds: 6)));
  }

  Future<void> _crear() async {
    setState(() => _trabajando = true);
    try {
      final copia = await _servicioCopia.crearCopia();
      await _cargar();
      if (mounted) {
        await Share.shareXFiles([XFile(copia.path)],
            subject: SoleraL10n.t('ques.asunto_copia'));
      }
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('${SoleraL10n.t('ques.no_se_ha_podido_crear_copia')}. ${textoErrorCopia(error)}');
    } catch (error) {
      _avisar('${SoleraL10n.t('ques.no_se_ha_podido_crear_copia')}: $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _restaurar() async {
    final rutaElegida = (await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: const ['zip']))
        ?.files
        .first
        .path;
    if (rutaElegida == null || !mounted) return;
    final ficheroCopia = File(rutaElegida);

    setState(() => _trabajando = true);
    final InformeCopiaSeguridad informe;
    try {
      informe = await _servicioCopia.validarCopia(ficheroCopia);
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('${SoleraL10n.t('ques.copia_no_restaurable')} ${textoErrorCopia(error)}');
      if (mounted) setState(() => _trabajando = false);
      return;
    } catch (error) {
      _avisar('${SoleraL10n.t('ques.no_se_ha_podido_leer_copia')}: $error');
      if (mounted) setState(() => _trabajando = false);
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fechaCopia = informe.fechaCreacion;
    final descripcionCopia = fechaCopia != null
        ? SoleraL10n.tf('ques.copia_del', {'fecha': _formatoFecha.format(fechaCopia.toLocal())})
        : SoleraL10n.t('ques.copia_version_anterior');
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: SoleraL10n.t('ques.restaurar_esta_copia'),
      mensaje: '${SoleraL10n.tf('ques.copia_con_fotos', {'copia': descripcionCopia, 'n': informe.numeroFicherosExtra})}'
          '\n\n${SoleraL10n.t('ques.restaurar_aviso')}',
      textoConfirmar: SoleraL10n.t('ques.restaurar'),
      icono: Icons.restore,
    );
    if (!confirmado || !mounted) return;

    setState(() => _trabajando = true);
    try {
      await _servicioCopia.restaurarCopia(ficheroCopia);
      await _cargar();
      _avisar(SoleraL10n.t('ques.copia_restaurada'));
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('${SoleraL10n.t('ques.no_se_ha_restaurado_copia')}. ${textoErrorCopia(error)}');
    } catch (error) {
      _avisar('${SoleraL10n.t('ques.no_se_ha_restaurado_copia')}: $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('backup'))),
      body: ListView(padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Icon(Icons.backup, size: 48, color: tema.colorScheme.primary),
              const SizedBox(height: 12),
              Text(SoleraL10n.t('copia_de_seguridad'),
                  style: tema.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _ultimaCopia != null
                    ? SoleraL10n.tf('ques.ultima_copia', {'fecha': _formatoFecha.format(_ultimaCopia!)})
                    : SoleraL10n.t('ques.ninguna_copia_todavia'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                SoleraL10n.t('ques.copia_incluye'),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _trabajando ? null : _crear,
          icon: _trabajando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload),
          label: Text(_trabajando
              ? SoleraL10n.t('ques.trabajando')
              : SoleraL10n.t('crear_y_compartir_backup')),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _trabajando ? null : _restaurar,
          icon: const Icon(Icons.download),
          label: Text(SoleraL10n.t('restaurar_desde_zip')),
        ),
      ]),
    );
  }
}
