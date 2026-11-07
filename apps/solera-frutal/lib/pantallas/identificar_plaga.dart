import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n;

import '../estado/clave_anthropic_frutal.dart';
import '../modelos/parcela.dart';
import '../servicios/identificador_plagas_ia.dart';
import 'formularios_registros.dart';

/// Pantalla de la clave de IA de Larrea Frutal.
Widget pantallaClaveFrutal() => PantallaClaveAnthropic(
      estado: estadoClaveFrutal,
      nombreApp: 'Larrea Frutal',
      queIdentifica: SoleraL10n.t('frut.ia_que_hace'),
    );

/// Nombre visible de un nivel de confianza.
String nombreConfianza(String nivel) => switch (nivel) {
      'alta' => SoleraL10n.t('frut.confianza_alta'),
      'media' => SoleraL10n.t('frut.confianza_media'),
      _ => SoleraL10n.t('frut.confianza_baja'),
    };

/// Foto → propuesta de la IA → la persona elige y se abre el alta de un
/// muestreo con la plaga rellena. La foto se borra al terminar.
Future<void> identificarPlagaConFoto(
    BuildContext context, Parcela parcela) async {
  final mensajero = ScaffoldMessenger.of(context);
  final clave = await estadoClaveFrutal.cargar();
  if (!context.mounted) return;
  if (clave == null || !estadoClaveFrutal.hayClave.value) {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => pantallaClaveFrutal()));
    return;
  }
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(SoleraL10n.t('frut.hacer_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
        ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(SoleraL10n.t('frut.elegir_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
      ]),
    ),
  );
  if (fuente == null) return;
  final rutas = await GestorFotos.tomarOSeleccionar(
      fuente: fuente, permitirVarias: false);
  if (rutas.isEmpty || !context.mounted) return;
  mensajero.showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('frut.ia_analizando'))));
  IdentificacionPlaga? identificacion;
  try {
    identificacion = await identificarPlagaConIa(
        claveApi: clave,
        especieId: parcela.especieId,
        foto: await ImagenClaude.desdeFichero(rutas.first));
  } catch (error) {
    debugPrint('Identificación fallida: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('frut.ia_error'))));
  } finally {
    await GestorFotos.borrarSiExiste(rutas.first);
  }
  if (identificacion == null || !context.mounted) return;
  final elegido = await showDialog<CandidatoPlaga>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('frut.ia_propuesta')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!identificacion!.legible)
              Text(SoleraL10n.t('frut.ia_no_legible')),
            for (final candidato in identificacion.candidatos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(candidato.plaga.nombre),
                subtitle: Text(
                    '${nombreConfianza(candidato.confianza)} · ${candidato.motivo}'),
                onTap: () => Navigator.pop(contexto, candidato),
              ),
            if (identificacion.fueraDelCatalogo)
              Text(SoleraL10n.t('frut.ia_fuera_catalogo')),
            if (identificacion.observaciones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(identificacion.observaciones),
              ),
            const SizedBox(height: 8),
            Text(SoleraL10n.t('frut.ia_revisa'),
                style: Theme.of(contexto).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: Text(SoleraL10n.t('cancelar'))),
      ],
    ),
  );
  if (elegido == null || !context.mounted) return;
  await mostrarAltaObservacion(
    context,
    parcelaId: parcela.id!,
    especieId: parcela.especieId,
    plagaPropuesta: elegido.plaga.id,
    notasPropuestas: SoleraL10n.tf('frut.ia_nota_observacion',
        {'confianza': nombreConfianza(elegido.confianza)}),
  );
}
