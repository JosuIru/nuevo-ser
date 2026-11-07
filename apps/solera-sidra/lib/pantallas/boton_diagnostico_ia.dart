import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n;

import '../dominio/catalogos.dart';
import '../estado/clave_anthropic_sidra.dart';
import '../servicios/diagnostico_plagas_ia.dart';
import 'pantalla_tratamiento.dart';

/// Pantalla de la clave de Anthropic de esta app.
Widget pantallaClaveSidra() => PantallaClaveAnthropic(
      estado: estadoClaveSidra,
      nombreApp: 'Larrea Sagardoa',
      queIdentifica: SoleraL10n.t('sidr.ia_que_hace'),
    );

/// Botón «Mirar con IA»: foto de la hoja, el fruto o la rama → propuesta de
/// plaga del catálogo. La persona decide; la foto se borra al terminar.
class BotonDiagnosticoIa extends StatefulWidget {
  const BotonDiagnosticoIa({super.key, required this.pomaradaId});

  final int pomaradaId;

  @override
  State<BotonDiagnosticoIa> createState() => _BotonDiagnosticoIaState();
}

class _BotonDiagnosticoIaState extends State<BotonDiagnosticoIa> {
  bool _mirando = false;

  Future<void> _diagnosticar() async {
    final mensajero = ScaffoldMessenger.of(context);
    final clave = await estadoClaveSidra.cargar();
    if (!mounted) return;
    if (clave == null || !estadoClaveSidra.hayClave.value) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => pantallaClaveSidra()));
      return;
    }
    final fuente = await showModalBottomSheet<FuenteFoto>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Wrap(children: [
          ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(SoleraL10n.t('sidr.hacer_foto')),
              onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
          ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(SoleraL10n.t('sidr.elegir_foto')),
              onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
        ]),
      ),
    );
    if (fuente == null) return;
    final rutas = await GestorFotos.tomarOSeleccionar(
        fuente: fuente, permitirVarias: false);
    if (rutas.isEmpty || !mounted) return;
    setState(() => _mirando = true);
    try {
      final diagnostico = await diagnosticarPlagaConIa(
          claveApi: clave, foto: await ImagenClaude.desdeFichero(rutas.first));
      if (!mounted) return;
      await _mostrar(diagnostico);
    } catch (error) {
      debugPrint('Diagnóstico con IA fallido: $error');
      mensajero
          .showSnackBar(SnackBar(content: Text(SoleraL10n.t('sidr.ia_error'))));
    } finally {
      await GestorFotos.borrarSiExiste(rutas.first);
      if (mounted) setState(() => _mirando = false);
    }
  }

  Future<void> _mostrar(DiagnosticoPlaga diagnostico) async {
    final plaga = diagnostico.plaga;
    final apuntar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(SoleraL10n.t('sidr.ia_propuesta')),
        content: SingleChildScrollView(
          child: Text(textoDiagnostico(diagnostico)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(SoleraL10n.t('cancelar'))),
          if (diagnostico.esPlagaDelCatalogo)
            FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: Text(SoleraL10n.t('sidr.nuevo_tratamiento'))),
        ],
      ),
    );
    if (apuntar != true || !mounted || plaga == null) return;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaEditarTratamiento(
                pomaradaId: widget.pomaradaId, plagaInicial: plaga.id)));
  }

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: SoleraL10n.t('sidr.ia_mirar'),
        icon: _mirando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.auto_awesome_outlined),
        onPressed: _mirando ? null : _diagnosticar,
      );
}

/// Texto del diálogo con la propuesta (función pura, con test).
String textoDiagnostico(DiagnosticoPlaga diagnostico) {
  final plaga = diagnostico.plaga;
  return [
    if (!diagnostico.fotoValida) SoleraL10n.t('sidr.ia_foto_no_valida'),
    if (diagnostico.fotoValida)
      plaga != null
          ? '${plaga.nombre} (${plaga.nombreCientifico}) · '
              '${SoleraL10n.tf('sidr.ia_confianza', {
                  'confianza':
                      SoleraL10n.t(_claveConfianza(diagnostico.confianza))
                })}'
          : SoleraL10n.t(diagnostico.plagaId == sinPlagaVisible
              ? 'sidr.ia_sin_plaga'
              : 'sidr.ia_no_identificada'),
    if (diagnostico.sintomasObservados.isNotEmpty)
      diagnostico.sintomasObservados,
    if (diagnostico.otrasPosibles.isNotEmpty)
      SoleraL10n.tf('sidr.ia_otras',
          {'plagas': diagnostico.otrasPosibles.map(nombrePlaga).join(', ')}),
    if (plaga?.organismoRegulado == true)
      SoleraL10n.t('sidr.organismo_regulado_aviso'),
    if (diagnostico.observaciones.isNotEmpty) diagnostico.observaciones,
    SoleraL10n.t('sidr.ia_revisa'),
  ].join('\n\n');
}

String _claveConfianza(String confianza) => switch (confianza) {
      'alta' => 'sidr.confianza_alta',
      'media' => 'sidr.confianza_media',
      _ => 'sidr.confianza_baja',
    };
