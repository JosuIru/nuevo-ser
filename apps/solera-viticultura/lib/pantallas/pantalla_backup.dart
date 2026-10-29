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
      explicacion = 'No se encuentra el fichero elegido.';
    case MotivoErrorCopiaSeguridad.noEsZip:
      explicacion = 'El fichero no es un ZIP válido o está dañado.';
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      explicacion = 'La copia está incompleta o dañada: no se entiende su descripción.';
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      explicacion =
          'La copia es de una versión más nueva de Larrea Viticultura. Actualiza la app y vuelve a intentarlo.';
    case MotivoErrorCopiaSeguridad.deOtraApp:
      explicacion = 'La copia es de otra aplicación, no de Larrea Viticultura.';
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      explicacion = 'El ZIP no contiene datos de Larrea Viticultura.';
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      explicacion = 'La base de datos de la copia está dañada.';
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      explicacion = 'La copia contiene rutas no permitidas y se ha rechazado.';
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      explicacion =
          'No se pudo guardar antes una copia del estado actual, así que no se ha restaurado nada.';
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      explicacion = 'Todavía no hay datos que copiar.';
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      explicacion = 'La restauración falló a mitad y se ha vuelto al estado anterior.';
    case MotivoErrorCopiaSeguridad.reversionFallida:
      explicacion = 'La restauración falló y no se pudo volver del todo al estado anterior. '
          'Tu estado anterior está guardado en la copia automática: ${error.respaldoPrevio?.path ?? error.mensaje}';
  }
  if (!error.datosIntactos) return explicacion;
  return '$explicacion Tus datos no se han tocado.';
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
  final _formatoFecha = DateFormat("d/MM/yyyy 'a las' HH:mm");
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
        subject: 'Copia de seguridad de Larrea Viticultura',
      );
    } on ErrorCopiaSeguridad catch (errorCopia) {
      if (mounted) _avisar('No se pudo crear la copia. ${textoErrorCopiaSeguridad(errorCopia)}');
    } catch (error) {
      if (mounted) _avisar('No se pudo crear la copia: $error');
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
        _avisar('Esa copia no se puede restaurar. ${textoErrorCopiaSeguridad(errorCopia)}');
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar('No se pudo leer la copia: $error. Tus datos no se han tocado.');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fechaCopia = informe.fechaCreacion;
    final descripcionFecha = fechaCopia != null
        ? 'Copia del ${_formatoFecha.format(fechaCopia)}'
        : 'Copia de una versión anterior de la app (sin fecha guardada)';
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Restaurar esta copia',
      mensaje: '$descripcionFecha · ${informe.numeroFicherosExtra} fotos.\n\n'
          'Sustituye la base de datos actual por la de la copia y añade sus fotos. '
          'Antes se guarda automáticamente una copia del estado actual.',
      textoConfirmar: 'Restaurar',
      textoCancelar: 'Cancelar',
      icono: Icons.restore,
    );
    if (confirmado != true || !mounted) return;

    setState(() => _trabajando = true);
    try {
      final resultado = await _servicioCopia.restaurarCopia(ficheroCopia);
      if (!mounted) return;
      final respaldoPrevio = resultado.respaldoPrevio;
      _avisar(respaldoPrevio != null
          ? 'Copia restaurada. Tu estado anterior se guardó en ${respaldoPrevio.path.split('/').last}.'
          : 'Copia restaurada.');
    } on ErrorCopiaSeguridad catch (errorCopia) {
      if (mounted) _avisar('No se pudo restaurar. ${textoErrorCopiaSeguridad(errorCopia)}');
    } catch (error) {
      if (mounted) _avisar('No se pudo restaurar: $error');
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
      appBar: AppBar(title: const Text('Copia de seguridad')),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                          const Text('Última copia', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimaCopia == null
                                ? 'Nunca — recomendado hacer una antes de salir al campo.'
                                : _formatoFecha.format(ultimaCopia),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Crear copia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Empaqueta la base de datos y todas las fotos en un ZIP que puedes compartir por WhatsApp, '
              'Drive, correo o copiar al PC. Si reinstalas la app o cambias de móvil podrás restaurar desde aquí. '
              'La clave de Anthropic no va en la copia.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? 'Trabajando…' : 'Crear copia y compartir'),
            ),
            const Divider(height: 32),
            const Text('Restaurar una copia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Primero se comprueba la copia y se te enseña de cuándo es. Si confirmas, sustituye la base de datos '
              'actual por la de la copia y añade sus fotos; antes se guarda una copia automática del estado actual. '
              'Si algo falla a mitad, se vuelve al estado anterior.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: const Text('Elegir copia y restaurar'),
            ),
          ],
        ),
      ),
    );
  }
}
