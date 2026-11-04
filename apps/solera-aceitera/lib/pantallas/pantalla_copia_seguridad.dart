import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/copia_seguridad_aceitera.dart';

/// Copia de seguridad: crear un ZIP con la base de datos (y las fotos, si
/// las hay) para compartirlo, y restaurar uno. Antes de restaurar se
/// valida la copia y se enseña de cuándo es; el servicio común guarda
/// antes una copia automática del estado actual y deshace si algo falla.
class PantallaCopiaSeguridad extends StatefulWidget {
  const PantallaCopiaSeguridad({super.key});

  @override
  State<PantallaCopiaSeguridad> createState() => _PantallaCopiaSeguridadState();
}

class _PantallaCopiaSeguridadState extends State<PantallaCopiaSeguridad> {
  final _formatoDia = DateFormat('d/MM/yyyy');
  final _formatoHora = DateFormat('HH:mm');

  String _fechaYHora(DateTime momento) => SoleraL10n.tf(
        'acei.fecha_a_las_hora',
        {'fecha': _formatoDia.format(momento), 'hora': _formatoHora.format(momento)},
      );
  bool _trabajando = false;
  DateTime? _ultimaCopia;

  @override
  void initState() {
    super.initState();
    _cargarUltimaCopia();
  }

  Future<void> _cargarUltimaCopia() async {
    final ultima = await servicioCopiaSeguridadAceitera.ultimaCopia();
    if (mounted) setState(() => _ultimaCopia = ultima);
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 8), content: Text(texto)),
    );
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final copia = await servicioCopiaSeguridadAceitera.crearCopia();
      await _cargarUltimaCopia();
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(copia.path)],
        subject: SoleraL10n.t('acei.copia_asunto'),
      );
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar(textoErrorCopiaAceitera(error));
    } catch (error) {
      if (mounted) _avisar(SoleraL10n.tf('acei.copia_no_se_pudo_crear', {'error': error}));
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _restaurar() async {
    final seleccion = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    final ruta = seleccion?.files.firstOrNull?.path;
    if (ruta == null || !mounted) return;
    final copia = File(ruta);

    setState(() => _trabajando = true);
    final InformeCopiaSeguridad informe;
    try {
      informe = await servicioCopiaSeguridadAceitera.validarCopia(copia);
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(textoErrorCopiaAceitera(error));
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(SoleraL10n.tf('acei.copia_no_se_pudo_leer', {'error': error}));
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fecha = informe.fechaCreacion;
    final deCuando = fecha == null
        ? SoleraL10n.t('acei.copia_sin_fecha')
        : SoleraL10n.tf('acei.copia_es_del', {'fecha': _fechaYHora(fecha.toLocal())});
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: SoleraL10n.t('acei.restaurar_esta_copia'),
      mensaje: '$deCuando\n\n${SoleraL10n.t('acei.restaurar_aviso')}',
      textoConfirmar: SoleraL10n.t('acei.restaurar'),
      esPeligroso: true,
      icono: Icons.restore,
    );
    if (!confirmado || !mounted) return;

    setState(() => _trabajando = true);
    try {
      final resultado =
          await servicioCopiaSeguridadAceitera.restaurarCopia(copia);
      generacionDatosAceitera.value++;
      if (!mounted) return;
      final respaldo = resultado.respaldoPrevio;
      _avisar(respaldo == null
          ? SoleraL10n.t('acei.copia_restaurada')
          : SoleraL10n.tf('acei.copia_restaurada_respaldo', {
              'fichero': respaldo.path.split(Platform.pathSeparator).last,
            }));
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar(textoErrorCopiaAceitera(error));
    } catch (error) {
      if (mounted) _avisar(SoleraL10n.tf('acei.copia_no_se_pudo_restaurar', {'error': error}));
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultima = _ultimaCopia;
    final diasDesdeLaUltima =
        ultima == null ? null : DateTime.now().difference(ultima).inDays;
    final estaAlDia = diasDesdeLaUltima != null && diasDesdeLaUltima <= 7;
    const estiloApartado =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    const estiloExplicacion = TextStyle(color: Colors.black54, fontSize: 13);

    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('copia_de_seguridad'))),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  ultima == null
                      ? Icons.warning_amber
                      : (estaAlDia ? Icons.check_circle : Icons.error_outline),
                  color: ultima == null
                      ? Colors.orange
                      : (estaAlDia ? Colors.green : Colors.red),
                ),
                title: Text(SoleraL10n.t('acei.ultima_copia')),
                subtitle: Text(ultima == null
                    ? SoleraL10n.t('acei.ultima_copia_nunca')
                    : _fechaYHora(ultima)),
              ),
            ),
            if (_trabajando) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 16),
            Text(SoleraL10n.t('acei.crear_una_copia'), style: estiloApartado),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('acei.crear_una_copia_texto'),
              style: estiloExplicacion,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.archive_outlined),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(SoleraL10n.t('crear_y_compartir_backup')),
            ),
            const Divider(height: 32),
            Text(SoleraL10n.t('acei.restaurar_una_copia'), style: estiloApartado),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('acei.restaurar_una_copia_texto'),
              style: estiloExplicacion,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text(SoleraL10n.t('acei.elegir_zip_y_restaurar')),
            ),
          ],
        ),
      ),
    );
  }
}
