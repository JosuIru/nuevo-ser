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
  final _formatoFecha = DateFormat("d/MM/yyyy 'a las' HH:mm", 'es_ES');
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
        subject: 'Copia de seguridad de Solera Aceitera',
      );
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar(textoErrorCopiaAceitera(error));
    } catch (error) {
      if (mounted) _avisar('No se ha podido crear la copia: $error');
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
        _avisar('No se ha podido leer la copia: $error. '
            'Tus datos no se han tocado.');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fecha = informe.fechaCreacion;
    final deCuando = fecha == null
        ? 'Es una copia de una versión anterior de la app y no indica la fecha.'
        : 'La copia es del ${_formatoFecha.format(fecha.toLocal())}.';
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Restaurar esta copia',
      mensaje: '$deCuando\n\n'
          'Los datos de este dispositivo se sustituirán por los de la copia. '
          'Antes se guarda automáticamente una copia del estado actual por '
          'si hay que volver atrás.',
      textoConfirmar: 'Restaurar',
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
          ? 'Copia restaurada.'
          : 'Copia restaurada. El estado anterior quedó guardado en '
              '${respaldo.path.split(Platform.pathSeparator).last}.');
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar(textoErrorCopiaAceitera(error));
    } catch (error) {
      if (mounted) _avisar('No se ha podido restaurar la copia: $error');
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
                title: const Text('Última copia'),
                subtitle: Text(ultima == null
                    ? 'Nunca. Conviene hacer una antes de la campaña.'
                    : _formatoFecha.format(ultima)),
              ),
            ),
            if (_trabajando) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 16),
            const Text('Crear una copia', style: estiloApartado),
            const SizedBox(height: 4),
            const Text(
              'Guarda la base de datos (parcelas, campañas, lotes, libro de '
              'movimientos, cuentas…) en un ZIP que puedes enviarte por '
              'correo, guardar en la nube o pasar al ordenador. La clave de '
              'Anthropic no va en la copia.',
              style: estiloExplicacion,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.archive_outlined),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: const Text('Crear copia y compartir'),
            ),
            const Divider(height: 32),
            const Text('Restaurar una copia', style: estiloApartado),
            const SizedBox(height: 4),
            const Text(
              'Sustituye los datos de este dispositivo por los de un ZIP de '
              'Solera Aceitera. Primero se comprueba la copia y se te enseña '
              'de cuándo es; si algo falla al restaurar, se vuelve al estado '
              'anterior.',
              style: estiloExplicacion,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: const Text('Elegir un ZIP y restaurar'),
            ),
          ],
        ),
      ),
    );
  }
}
