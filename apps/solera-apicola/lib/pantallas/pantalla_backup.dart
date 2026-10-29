import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/copia_seguridad_apicola.dart';

/// Texto para la persona según por qué ha fallado la copia o la
/// restauración. Solo dice que los datos no se han tocado cuando es
/// verdad ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopiaSeguridad(ErrorCopiaSeguridad error) {
  final String explicacion;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      explicacion = 'No se encuentra el fichero elegido.';
      break;
    case MotivoErrorCopiaSeguridad.noEsZip:
      explicacion = 'El fichero no es un ZIP válido o está dañado.';
      break;
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
      explicacion = 'La copia la hizo una versión más nueva de la app o no se entiende. Actualiza Larrea Apícola y vuelve a probar.';
      break;
    case MotivoErrorCopiaSeguridad.deOtraApp:
      explicacion = 'La copia es de otra app, no de Larrea Apícola.';
      break;
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      explicacion = 'El ZIP no trae la base de datos de Larrea Apícola.';
      break;
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      explicacion = 'La base de datos de la copia está dañada.';
      break;
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      explicacion = 'La copia es de una versión más nueva de la app. Actualiza Larrea Apícola antes de restaurarla.';
      break;
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      explicacion = 'La copia intenta escribir fuera de la carpeta de la app y se ha rechazado.';
      break;
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      explicacion = 'No se ha podido guardar antes una copia del estado actual, así que no se ha restaurado nada.';
      break;
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      explicacion = 'Todavía no hay datos que copiar.';
      break;
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      explicacion = 'La restauración ha fallado a mitad y se ha vuelto al estado anterior.';
      break;
    case MotivoErrorCopiaSeguridad.reversionFallida:
      explicacion = 'La restauración ha fallado y no se ha podido volver atrás del todo. '
          'No borres la app: tu estado anterior está en la copia automática '
          '${error.respaldoPrevio != null ? '(${error.respaldoPrevio!.path.split('/').last}) ' : ''}'
          'y puedes restaurarla desde aquí.';
      break;
  }
  return error.datosIntactos ? '$explicacion Tus datos no se han tocado.' : explicacion;
}

/// Pantalla de copia de seguridad y restauración. Operaciones lentas
/// (segundos) y delicadas: la restauración valida la copia y pide
/// confirmación enseñando su fecha antes de tocar nada.
class PantallaBackup extends StatefulWidget {
  const PantallaBackup({super.key});

  @override
  State<PantallaBackup> createState() => _PantallaBackupState();
}

class _PantallaBackupState extends State<PantallaBackup> {
  final _servicio = servicioCopiaSeguridadApicola;
  bool _trabajando = false;
  DateTime? _ultimoBackup;

  @override
  void initState() {
    super.initState();
    _cargarUltimoBackup();
  }

  Future<void> _cargarUltimoBackup() async {
    final ultima = await _servicio.ultimaCopia();
    if (mounted) setState(() => _ultimoBackup = ultima);
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 8), content: Text(texto)),
    );
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await _servicio.crearCopia();
      await _cargarUltimoBackup();
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        subject: 'Copia de seguridad de Larrea Apícola',
      );
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar('No se ha podido crear la copia. ${textoErrorCopiaSeguridad(error)}');
    } catch (error) {
      if (mounted) _avisar('No se ha podido crear la copia: $error');
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
    if (ruta == null || !mounted) return;
    final copia = File(ruta);

    setState(() => _trabajando = true);
    final InformeCopiaSeguridad informe;
    try {
      informe = await _servicio.validarCopia(copia);
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar('Esta copia no se puede restaurar. ${textoErrorCopiaSeguridad(error)}');
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar('No se ha podido leer la copia: $error');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fecha = informe.fechaCreacion;
    final descripcionCopia = fecha != null
        ? 'Copia del ${DateFormat("d/MM/yyyy 'a las' HH:mm").format(fecha)}'
        : 'Copia de una versión anterior de la app (sin fecha guardada)';
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Restaurar esta copia',
      mensaje: '$descripcionCopia, con ${informe.numeroFicherosExtra} fotos.\n\n'
          'Sustituye la base de datos actual por la de la copia y añade sus fotos. '
          'Antes se guarda automáticamente una copia del estado actual.',
      textoConfirmar: 'Restaurar',
      textoCancelar: 'Cancelar',
      icono: Icons.restore,
    );
    if (confirmado != true || !mounted) return;

    setState(() => _trabajando = true);
    try {
      final restauracion = await _servicio.restaurarCopia(copia);
      if (!mounted) return;
      final respaldo = restauracion.respaldoPrevio;
      _avisar(respaldo != null
          ? 'Copia restaurada. El estado anterior se guardó en ${respaldo.path.split('/').last}.'
          : 'Copia restaurada.');
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar(textoErrorCopiaSeguridad(error));
    } catch (error) {
      if (mounted) _avisar('Error al restaurar: $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _ultimoBackup;
    final hace = ultimo == null ? null : DateTime.now().difference(ultimo);
    return Scaffold(
      appBar: AppBar(title: Text('Backup y restauración')),
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
                          Text('Último backup', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimo == null
                                ? 'Nunca — recomendado hacer uno antes de la próxima trashumancia.'
                                : DateFormat("d/MM/yyyy 'a las' HH:mm").format(ultimo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Crear backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Empaqueta la base de datos y todas las fotos en un zip que puedes compartir por WhatsApp, '
              'Drive, correo o copiar al PC. Si reinstalas la app o cambias de móvil podrás restaurar desde aquí.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            FilledButton.icon(
              icon: Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? 'Empaquetando…' : 'Crear backup y compartir'),
            ),
            Divider(height: 32),
            Text('Restaurar desde backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Sustituye la base de datos por la del zip y añade sus fotos. Antes se comprueba la copia '
              'y se guarda automáticamente el estado actual por si quieres deshacer.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text('Elegir copia y restaurar'),
            ),
          ],
        ),
      ),
    );
  }
}
