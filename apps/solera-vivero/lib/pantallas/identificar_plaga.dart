import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n;

import '../estado/clave_anthropic_vivero.dart';
import '../modelos/partida_planta.dart';
import '../servicios/identificador_plagas_ia.dart';
import 'campos_especie.dart';
import 'formularios.dart';

/// Pantalla de la clave de IA de Larrea Vivero.
Widget pantallaClaveVivero() => PantallaClaveAnthropic(
      estado: estadoClaveVivero,
      nombreApp: 'Larrea Vivero',
      queIdentifica: SoleraL10n.t('vive.ia_que_hace'),
    );

/// Nombre visible de un nivel de confianza.
String nombreConfianza(String nivel) => switch (nivel) {
      'alta' => SoleraL10n.t('vive.confianza_alta'),
      'media' => SoleraL10n.t('vive.confianza_media'),
      _ => SoleraL10n.t('vive.confianza_baja'),
    };

/// Foto → propuesta de la IA → la persona elige y se abre el alta de una
/// inspección de la partida con la plaga rellena (con «sospecha» si es
/// regulada). La foto se borra al terminar.
Future<void> identificarPlagaConFoto(
    BuildContext context, PartidaPlanta partida) async {
  final mensajero = ScaffoldMessenger.of(context);
  final clave = await estadoClaveVivero.cargar();
  if (!context.mounted) return;
  if (clave == null || !estadoClaveVivero.hayClave.value) {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => pantallaClaveVivero()));
    return;
  }
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(SoleraL10n.t('vive.hacer_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
        ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(SoleraL10n.t('vive.elegir_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
      ]),
    ),
  );
  if (fuente == null) return;
  final rutas = await GestorFotos.tomarOSeleccionar(
      fuente: fuente, permitirVarias: false);
  if (rutas.isEmpty || !context.mounted) return;
  mensajero.showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('vive.ia_analizando'))));
  final plagas = plagasParaIdentificar(
      especieId: partida.especieId, nombreBotanico: partida.nombreBotanico);
  IdentificacionPlaga? identificacion;
  try {
    identificacion = await identificarPlagaConIa(
        claveApi: clave,
        plagas: plagas,
        descripcionPlanta: [
          nombreEspecieVisible(partida.especieId),
          partida.nombreBotanico,
        ].where((parte) => parte.isNotEmpty).join(', '),
        foto: await ImagenClaude.desdeFichero(rutas.first));
  } catch (error) {
    debugPrint('Identificación fallida: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('vive.ia_error'))));
  } finally {
    await GestorFotos.borrarSiExiste(rutas.first);
  }
  if (identificacion == null || !context.mounted) return;
  final elegido = await showDialog<CandidatoPlaga>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('vive.ia_propuesta')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!identificacion!.legible)
              Text(SoleraL10n.t('vive.ia_no_legible')),
            for (final candidato in identificacion.candidatos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: candidato.plaga.esRegulada
                    ? const Icon(Icons.warning_amber_outlined)
                    : null,
                title: Text(candidato.plaga.nombre),
                subtitle: Text(
                    '${nombreConfianza(candidato.confianza)} · ${candidato.motivo}'),
                onTap: () => Navigator.pop(contexto, candidato),
              ),
            if (identificacion.fueraDelCatalogo)
              Text(SoleraL10n.t('vive.ia_fuera_catalogo')),
            if (identificacion.observaciones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(identificacion.observaciones),
              ),
            const SizedBox(height: 8),
            Text(SoleraL10n.t('vive.ia_revisa'),
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
  await mostrarFormularioInspeccion(
    context,
    partidaId: partida.id,
    // El texto de la opción del catálogo, para que se guarde su id.
    plagaInicial: elegido.plaga.esRegulada
        ? '${elegido.plaga.nombre} (${elegido.plaga.nombreCientifico})'
        : elegido.plaga.nombre,
    resultadoInicial: elegido.plaga.esRegulada ? 'sospecha' : 'detectada',
    notasIniciales: SoleraL10n.tf('vive.ia_nota_inspeccion',
        {'confianza': nombreConfianza(elegido.confianza)}),
  );
}
