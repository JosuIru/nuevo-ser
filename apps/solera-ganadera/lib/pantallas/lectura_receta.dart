import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n;

import '../estado/clave_anthropic_ganadera.dart';
import '../modelos/ganado.dart';
import '../servicios/lector_receta_ia.dart';
import '../utiles/textos_ganadera.dart';
import 'formularios_ganado.dart';

/// Abre la pantalla de la clave de Anthropic de Ganadera.
Future<void> abrirClaveIaGanadera(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => PantallaClaveAnthropic(
              estado: estadoClaveGanadera,
              nombreApp: 'Larrea Ganadera',
              queIdentifica: SoleraL10n.t('gana.ia_que_hace'),
            )));

/// Foto de la receta → la IA la transcribe → la persona la compara con la
/// receta → el formulario del tratamiento se abre ya relleno y ella guarda.
/// La foto se borra al terminar.
Future<void> leerRecetaYApuntar(BuildContext context, LoteGanado lote,
    {Animal? animal}) async {
  final mensajero = ScaffoldMessenger.of(context);
  final clave = await estadoClaveGanadera.cargar();
  if (!context.mounted) return;
  if (clave == null || !estadoClaveGanadera.hayClave.value) {
    await abrirClaveIaGanadera(context);
    return;
  }
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(SoleraL10n.t('gana.hacer_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
        ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(SoleraL10n.t('gana.elegir_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
      ]),
    ),
  );
  if (fuente == null) return;
  final rutas = await GestorFotos.tomarOSeleccionar(
      fuente: fuente, permitirVarias: false);
  if (rutas.isEmpty || !context.mounted) return;
  LecturaReceta? lectura;
  try {
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('gana.ia_leyendo'))));
    lectura = await leerRecetaConIa(
        claveApi: clave, foto: await ImagenClaude.desdeFichero(rutas.first));
  } catch (error) {
    debugPrint('Lectura de receta fallida: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('gana.ia_error'))));
  } finally {
    await GestorFotos.borrarSiExiste(rutas.first);
  }
  if (lectura == null || !context.mounted) return;
  final usar = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('gana.ia_propuesta')),
      content: SingleChildScrollView(child: Text(textoLectura(lectura!))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(SoleraL10n.t('gana.ia_usar'))),
      ],
    ),
  );
  if (usar != true || !context.mounted) return;
  await mostrarAltaEvento(context, lote,
      animal: animal,
      propuesta: PropuestaEvento(
        medicamento: lectura.medicamento,
        sustanciaActiva: lectura.sustanciaPropuesta,
        dosis: lectura.dosis,
        duracionDias: lectura.duracionDias,
        esperaCarneDias: lectura.esperaCarneDias,
        esperaLecheDias: lectura.esperaLecheDias,
        veterinario: lectura.veterinario,
        receta: lectura.numeroReceta,
        fecha: lectura.fecha,
      ));
}

/// La propuesta en texto, para que la persona la compare con la receta.
String textoLectura(LecturaReceta lectura) {
  String o(int? dias) => dias == null ? '—' : '$dias';
  return [
    if (!lectura.legible) SoleraL10n.t('gana.ia_no_legible'),
    '${SoleraL10n.t('gana.col_medicamento')}: ${lectura.medicamento.isEmpty ? '—' : lectura.medicamento}',
    '${SoleraL10n.t('gana.sustancia_activa')}: ${lectura.sustanciasLeidas.isEmpty ? '—' : lectura.sustanciasLeidas.join(', ')}'
        '${lectura.sustanciaCatalogo == null ? ' (${SoleraL10n.t('gana.ia_fuera_catalogo')})' : ''}',
    '${SoleraL10n.t('gana.col_cantidad')}: ${lectura.dosis.isEmpty ? '—' : lectura.dosis}',
    '${SoleraL10n.t('gana.col_espera_carne')}: ${o(lectura.esperaCarneDias)} · '
        '${SoleraL10n.t('gana.col_espera_leche')}: ${o(lectura.esperaLecheDias)}',
    if (lectura.fecha != null)
      '${SoleraL10n.t('gana.fecha')}: ${formatearDia(lectura.fecha!)}',
    if (lectura.observaciones.isNotEmpty) lectura.observaciones,
    SoleraL10n.t('gana.ia_revisa'),
  ].join('\n\n');
}
