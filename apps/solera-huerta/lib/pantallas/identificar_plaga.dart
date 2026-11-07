import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../estado/clave_anthropic_huerta.dart';
import '../estado/datos_huerta.dart';
import '../modelos/cultivo.dart';
import '../modelos/observacion_plaga.dart';
import '../servicios/identificador_plagas_ia.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

/// Pantalla de la clave de IA de Larrea Huerta.
Widget pantallaClaveHuerta() => PantallaClaveAnthropic(
      estado: estadoClaveHuerta,
      nombreApp: 'Larrea Huerta',
      queIdentifica: SoleraL10n.t('huer.ia_que_hace'),
    );

/// Nombre visible de un nivel de confianza.
String nombreConfianza(String nivel) => switch (nivel) {
      'alta' => SoleraL10n.t('huer.confianza_alta'),
      'media' => SoleraL10n.t('huer.confianza_media'),
      _ => SoleraL10n.t('huer.confianza_baja'),
    };

/// Alta (o edición) de una observación de plaga, enfermedad o carencia.
Future<bool> mostrarAltaObservacion(
  BuildContext context, {
  required DatosHuerta datos,
  required int bancalId,
  int? cultivoId,
  ObservacionPlaga? observacion,
  String? plagaPropuesta,
  String? notasPropuestas,
}) async {
  final cultivo = datos.cultivo(observacion?.cultivoId ?? cultivoId);
  final opciones = opcionesPlagas(familiaId: cultivo?.familiaId);
  final plaga = TextEditingController(
      text: nombrePlaga(observacion?.plagaId ?? plagaPropuesta ?? ''));
  final notas =
      TextEditingController(text: observacion?.notas ?? notasPropuestas);
  var fecha = observacion == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(observacion.fechaMs);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('huer.nueva_observacion'),
    controladores: [plaga, notas],
    construir: (refrescar) => [
      if (cultivo != null) Text(nombreCultivo(cultivo)),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      CampoCatalogo(
        controlador: plaga,
        opciones: opciones,
        etiqueta: SoleraL10n.t('huer.problema'),
        alElegir: (_) => refrescar(() {}),
      ),
      Builder(builder: (contexto) {
        final elegida = plagaPorId(idDesdeTexto(plaga.text, opciones));
        if (elegida == null || elegida.seguimiento.isEmpty) {
          return const SizedBox.shrink();
        }
        return Text(
            SoleraL10n.tf(
                'huer.seguimiento_guia', {'texto': elegida.seguimiento}),
            style: Theme.of(contexto).textTheme.bodySmall);
      }),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      final plagaId = idDesdeTexto(plaga.text, opciones);
      if (plagaId.isEmpty) return false;
      await BaseDatosSoleraHuerta.instancia.guardarObservacionPlaga(
          ObservacionPlaga(
              id: observacion?.id,
              bancalId: bancalId,
              cultivoId: cultivo?.id,
              fechaMs: fecha.millisecondsSinceEpoch,
              plagaId: plagaId,
              notas: notas.text.trim()));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Foto de una hoja → propuesta de la IA → la persona elige y se abre el
/// alta de una **observación** con la plaga rellena. Nunca un tratamiento.
/// La foto se borra al terminar.
Future<void> identificarPlagaConFoto(BuildContext context,
    {required DatosHuerta datos, required int bancalId}) async {
  final mensajero = ScaffoldMessenger.of(context);
  final clave = await estadoClaveHuerta.cargar();
  if (!context.mounted) return;
  if (clave == null || !estadoClaveHuerta.hayClave.value) {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => pantallaClaveHuerta()));
    return;
  }
  final enBancal = datos.ocupacionDe(bancalId).map((s) => s.cultivoId).toSet();
  final candidatosCultivo = [
    for (final cultivo in datos.cultivos)
      if (enBancal.isEmpty || enBancal.contains(cultivo.id)) cultivo
  ];
  if (candidatosCultivo.isEmpty) {
    avisar(context, SoleraL10n.t('huer.falta_bancal_o_cultivo'));
    return;
  }
  final cultivo = candidatosCultivo.length == 1
      ? candidatosCultivo.single
      : await showDialog<Cultivo>(
          context: context,
          builder: (contexto) => SimpleDialog(
            title: Text(SoleraL10n.t('huer.que_cultivo')),
            children: [
              for (final opcion in candidatosCultivo)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(contexto, opcion),
                  child: Text(nombreCultivo(opcion)),
                ),
            ],
          ),
        );
  if (cultivo == null || !context.mounted) return;
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(SoleraL10n.t('huer.hacer_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
        ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(SoleraL10n.t('huer.elegir_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
      ]),
    ),
  );
  if (fuente == null) return;
  final rutas = await GestorFotos.tomarOSeleccionar(
      fuente: fuente, permitirVarias: false);
  if (rutas.isEmpty || !context.mounted) return;
  mensajero.showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('huer.ia_analizando'))));
  IdentificacionPlaga? identificacion;
  try {
    identificacion = await identificarPlagaConIa(
        claveApi: clave,
        nombreCultivo: nombreCultivo(cultivo),
        familiaId: cultivo.familiaId,
        foto: await ImagenClaude.desdeFichero(rutas.first));
  } catch (error) {
    debugPrint('Identificación fallida: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('huer.ia_error'))));
  } finally {
    await GestorFotos.borrarSiExiste(rutas.first);
  }
  if (identificacion == null || !context.mounted) return;
  final elegido = await showDialog<CandidatoPlaga>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('huer.ia_propuesta')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!identificacion!.legible)
              Text(SoleraL10n.t('huer.ia_no_legible')),
            for (final candidato in identificacion.candidatos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(candidato.plaga.nombre),
                subtitle: Text(
                    '${nombreConfianza(candidato.confianza)} · ${candidato.motivo}'),
                onTap: () => Navigator.pop(contexto, candidato),
              ),
            if (identificacion.fueraDelCatalogo)
              Text(SoleraL10n.t('huer.ia_fuera_catalogo')),
            if (identificacion.observaciones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(identificacion.observaciones),
              ),
            const SizedBox(height: 8),
            Text(SoleraL10n.t('huer.ia_revisa'),
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
    datos: datos,
    bancalId: bancalId,
    cultivoId: cultivo.id,
    plagaPropuesta: elegido.plaga.id,
    notasPropuestas: SoleraL10n.tf('huer.ia_nota_observacion',
        {'confianza': nombreConfianza(elegido.confianza)}),
  );
}
