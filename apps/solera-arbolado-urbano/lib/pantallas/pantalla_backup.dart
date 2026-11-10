import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/backup_servicio.dart';
import '../utiles/etiquetas_l10n.dart';

/// Pantalla de backup/restore. Operaciones lentas (segundos) y
/// destructivas — UI explícita con confirmaciones.
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
    final u = await servicioCopiaSeguridad.ultimaCopia();
    if (mounted) setState(() => _ultimoBackup = u);
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await servicioCopiaSeguridad.crearCopia();
      await _cargarUltimoBackup();
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        subject: SoleraL10n.t('arb.asunto_copia_seguridad'),
      );
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('${SoleraL10n.t('arb.no_se_pudo_crear_copia')}. ${textoErrorCopiaSeguridad(error)}');
    } catch (error) {
      _avisar('${SoleraL10n.t('arb.no_se_pudo_crear_copia')}: $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  void _avisar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 8), content: Text(texto)),
    );
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
    // cuándo es y pedir confirmación.
    setState(() => _trabajando = true);
    InformeCopiaSeguridad informe;
    try {
      informe = await servicioCopiaSeguridad.validarCopia(copia);
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('${SoleraL10n.t('arb.no_se_puede_restaurar_copia')}. ${textoErrorCopiaSeguridad(error)}');
      return;
    } catch (error) {
      _avisar('${SoleraL10n.t('arb.no_se_puede_leer_copia')}: $error');
      return;
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
    if (!mounted) return;

    final fecha = informe.fechaCreacion;
    final textoFecha = fecha == null
        ? SoleraL10n.t('arb.copia_fecha_desconocida')
        : SoleraL10n.tf('arb.copia_del_momento', {'momento': fechaYHoraTraducida(fecha)});
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: SoleraL10n.t('arb.restaurar_copia_seguridad'),
      mensaje: '${SoleraL10n.tf('arb.copia_elegida_es', {'fecha': textoFecha})}\n\n'
          '${SoleraL10n.t('arb.restaurar_sustituye_bd')}\n\n'
          '${SoleraL10n.t('arb.restaurar_guarda_estado_actual')}',
      textoConfirmar: SoleraL10n.t('arb.restaurar'),
      textoCancelar: SoleraL10n.t('cancelar'),
      icono: Icons.restore,
    );
    if (confirmado != true) return;

    setState(() => _trabajando = true);
    try {
      final restauracion = await servicioCopiaSeguridad.restaurarCopia(copia);
      final respaldo = restauracion.respaldoPrevio;
      _avisar(respaldo == null
          ? SoleraL10n.t('arb.restaurado')
          : SoleraL10n.tf('arb.restaurado_estado_anterior_en', {'fichero': respaldo.path.split('/').last}));
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('${SoleraL10n.t('arb.no_se_pudo_restaurar')}. ${textoErrorCopiaSeguridad(error)}');
    } catch (error) {
      _avisar('${SoleraL10n.t('arb.no_se_pudo_restaurar')}: $error');
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
                      ultimo == null
                          ? Icons.warning_amber
                          : (hace != null && hace.inDays > 7 ? Icons.error_outline : Icons.check_circle),
                      color: ultimo == null
                          ? Colors.orange
                          : (hace != null && hace.inDays > 7 ? Colors.red : Colors.green),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(SoleraL10n.t('arb.ultima_copia'), style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimo == null
                                ? SoleraL10n.t('arb.nunca_recomendamos_copia')
                                : fechaYHoraTraducida(ultimo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(SoleraL10n.t('arb.crear_copia'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              SoleraL10n.t('arb.crear_copia_explicacion'),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            FilledButton.icon(
              icon: Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? SoleraL10n.t('arb.empaquetando') : SoleraL10n.t('crear_y_compartir_backup')),
            ),
            Divider(height: 32),
            Text(SoleraL10n.t('arb.restaurar_una_copia'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              SoleraL10n.t('arb.restaurar_copia_explicacion'),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text(SoleraL10n.t('arb.restaurar_zip')),
            ),
          ],
        ),
      ),
    );
  }
}
