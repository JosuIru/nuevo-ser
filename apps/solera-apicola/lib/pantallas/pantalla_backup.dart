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
      explicacion = SoleraL10n.t('api.copia_error_fichero_no_existe');
      break;
    case MotivoErrorCopiaSeguridad.noEsZip:
      explicacion = SoleraL10n.t('api.copia_error_no_es_zip');
      break;
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
      explicacion = SoleraL10n.t('api.copia_error_formato_desconocido');
      break;
    case MotivoErrorCopiaSeguridad.deOtraApp:
      explicacion = SoleraL10n.t('api.copia_error_de_otra_app');
      break;
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      explicacion = SoleraL10n.t('api.copia_error_sin_base_datos');
      break;
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      explicacion = SoleraL10n.t('api.copia_error_base_datos_danada');
      break;
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      explicacion = SoleraL10n.t('api.copia_error_esquema_mas_nuevo');
      break;
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      explicacion = SoleraL10n.t('api.copia_error_ruta_peligrosa');
      break;
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      explicacion = SoleraL10n.t('api.copia_error_respaldo_previo_fallido');
      break;
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      explicacion = SoleraL10n.t('api.copia_error_sin_datos');
      break;
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      explicacion = SoleraL10n.t('api.copia_error_restauracion_revertida');
      break;
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldoPrevio = error.respaldoPrevio;
      explicacion = respaldoPrevio != null
          ? SoleraL10n.tf('api.copia_error_reversion_fallida_fichero',
              {'fichero': respaldoPrevio.path.split('/').last})
          : SoleraL10n.t('api.copia_error_reversion_fallida');
      break;
  }
  return error.datosIntactos
      ? '$explicacion ${SoleraL10n.t('api.copia_datos_intactos')}'
      : explicacion;
}

/// «d/MM/yyyy a las HH:mm» en el idioma actual (solo cambia el «a las»).
String _fechaYHora(DateTime momento) => SoleraL10n.tf('api.copia_fecha_a_las_hora', {
      'fecha': DateFormat('d/MM/yyyy').format(momento),
      'hora': DateFormat('HH:mm').format(momento),
    });

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
        subject: SoleraL10n.t('api.copia_asunto_compartir'),
      );
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar('${SoleraL10n.t('api.copia_no_se_pudo_crear')} ${textoErrorCopiaSeguridad(error)}');
    } catch (error) {
      if (mounted) _avisar(SoleraL10n.tf('api.copia_no_se_pudo_crear_detalle', {'error': error}));
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
        _avisar('${SoleraL10n.t('api.copia_no_se_puede_restaurar')} ${textoErrorCopiaSeguridad(error)}');
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(SoleraL10n.tf('api.copia_no_se_pudo_leer', {'error': error}));
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fecha = informe.fechaCreacion;
    final descripcionCopia = fecha != null
        ? SoleraL10n.tf('api.copia_del_fecha', {'fecha': _fechaYHora(fecha)})
        : SoleraL10n.t('api.copia_sin_fecha');
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: SoleraL10n.t('api.copia_restaurar_esta_copia'),
      mensaje: '${SoleraL10n.tf('api.copia_descripcion_con_fotos', {'copia': descripcionCopia, 'n': informe.numeroFicherosExtra})}\n\n'
          '${SoleraL10n.t('api.copia_explicacion_restaurar_dialogo')}',
      textoConfirmar: SoleraL10n.t('api.copia_restaurar'),
      textoCancelar: SoleraL10n.t('cancelar'),
      icono: Icons.restore,
    );
    if (confirmado != true || !mounted) return;

    setState(() => _trabajando = true);
    try {
      final restauracion = await _servicio.restaurarCopia(copia);
      if (!mounted) return;
      final respaldo = restauracion.respaldoPrevio;
      _avisar(respaldo != null
          ? SoleraL10n.tf('api.copia_restaurada_con_respaldo',
              {'fichero': respaldo.path.split('/').last})
          : SoleraL10n.t('api.copia_restaurada'));
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) _avisar(textoErrorCopiaSeguridad(error));
    } catch (error) {
      if (mounted) _avisar(SoleraL10n.tf('api.copia_error_al_restaurar', {'error': error}));
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
                          Text(SoleraL10n.t('api.copia_ultima_copia'), style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimo == null
                                ? SoleraL10n.t('api.copia_nunca')
                                : _fechaYHora(ultimo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(SoleraL10n.t('api.copia_crear_copia'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              SoleraL10n.t('api.copia_explicacion_crear'),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            FilledButton.icon(
              icon: Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? SoleraL10n.t('api.copia_empaquetando') : SoleraL10n.t('crear_y_compartir_backup')),
            ),
            Divider(height: 32),
            Text(SoleraL10n.t('api.copia_restaurar_una_copia'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              SoleraL10n.t('api.copia_explicacion_restaurar'),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text(SoleraL10n.t('api.copia_elegir_y_restaurar')),
            ),
          ],
        ),
      ),
    );
  }
}
