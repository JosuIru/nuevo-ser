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
import '../estado/clave_anthropic_monte.dart';
import '../modelos/rodal.dart';
import '../servicios/identificador_ia.dart';

/// Pantalla de la clave de IA de Larrea Monte.
Widget pantallaClaveMonte() => PantallaClaveAnthropic(
      estado: estadoClaveMonte,
      nombreApp: 'Larrea Monte',
      queIdentifica: SoleraL10n.t('mont.ia_que_hace'),
    );

/// Nombre visible de un nivel de confianza.
String nombreConfianza(String nivel) => switch (nivel) {
      'alta' => SoleraL10n.t('mont.confianza_alta'),
      'media' => SoleraL10n.t('mont.confianza_media'),
      _ => SoleraL10n.t('mont.confianza_baja'),
    };

/// Pide la foto (cámara o galería) y la clave; devuelve la clave y la ruta,
/// o null si la persona cancela o no hay clave (abre su pantalla).
Future<(String, String)?> _pedirFotoYClave(BuildContext context) async {
  final clave = await estadoClaveMonte.cargar();
  if (!context.mounted) return null;
  if (clave == null || !estadoClaveMonte.hayClave.value) {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => pantallaClaveMonte()));
    return null;
  }
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(SoleraL10n.t('mont.hacer_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
        ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(SoleraL10n.t('mont.elegir_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
      ]),
    ),
  );
  if (fuente == null) return null;
  final rutas = await GestorFotos.tomarOSeleccionar(
      fuente: fuente, permitirVarias: false);
  if (rutas.isEmpty) return null;
  return (clave, rutas.first);
}

/// Elige el rodal (para saber la especie) o «otra especie», foto →
/// plagas y daños candidatos del catálogo. Solo informa: nunca abre un
/// tratamiento. La foto se borra siempre.
Future<void> identificarPlagaConFoto(BuildContext context) async {
  final rodales = await BaseDatosSoleraMonte.instancia.listarRodales();
  if (!context.mounted) return;
  final eleccion = await showDialog<Rodal?>(
    context: context,
    builder: (contexto) => SimpleDialog(
      title: Text(SoleraL10n.t('mont.ia_de_que_rodal')),
      children: [
        for (final rodal in rodales)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(contexto, rodal),
            child: Text(
                '${rodal.etiqueta} · ${nombreEspecie(rodal.especiePrincipalId)}'),
          ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(
              contexto, Rodal(codigo: '', especiePrincipalId: '')),
          child: Text(SoleraL10n.t('mont.ia_otra_especie')),
        ),
      ],
    ),
  );
  if (eleccion == null || !context.mounted) return;
  final especieId =
      eleccion.especiePrincipalId.isEmpty ? null : eleccion.especiePrincipalId;
  final pedido = await _pedirFotoYClave(context);
  if (pedido == null || !context.mounted) return;
  final (clave, ruta) = pedido;
  final mensajero = ScaffoldMessenger.of(context);
  mensajero.showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('mont.ia_analizando'))));
  PropuestaPlaga? propuesta;
  try {
    propuesta = await identificarPlagaConIa(
        claveApi: clave,
        especieId: especieId,
        foto: await ImagenClaude.desdeFichero(ruta));
  } catch (error) {
    debugPrint('Identificación fallida: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('mont.ia_error'))));
  } finally {
    await GestorFotos.borrarSiExiste(ruta);
  }
  if (propuesta == null || !context.mounted) return;
  await mostrarPropuestaPlaga(context, propuesta);
}

/// Diálogo con la propuesta. Público para el test de pantalla.
Future<void> mostrarPropuestaPlaga(
    BuildContext context, PropuestaPlaga propuesta) {
  final esquema = Theme.of(context).colorScheme;
  return showDialog<void>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('mont.ia_propuesta')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (propuesta.hayPrioritaria)
              Card(
                color: esquema.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(SoleraL10n.t('mont.ia_aviso_prioritaria')),
                ),
              ),
            if (propuesta.hayUrticante)
              Card(
                color: esquema.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(SoleraL10n.t('mont.ia_aviso_urticante')),
                ),
              ),
            if (!propuesta.legible) Text(SoleraL10n.t('mont.ia_no_legible')),
            for (final candidato in propuesta.candidatos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    '${candidato.plaga.nombre} (${candidato.plaga.nombreCientifico})'),
                subtitle: Text(
                    '${nombreConfianza(candidato.confianza)} · ${candidato.motivo}'),
              ),
            if (propuesta.fueraDelCatalogo)
              Text(SoleraL10n.t('mont.ia_fuera_catalogo')),
            if (propuesta.queComprobar.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(SoleraL10n.tf(
                    'mont.ia_que_comprobar', {'que': propuesta.queComprobar})),
              ),
            if (propuesta.observaciones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(propuesta.observaciones),
              ),
            const SizedBox(height: 8),
            Text(SoleraL10n.t('mont.ia_revisa_plaga'),
                style: Theme.of(contexto).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: Text(SoleraL10n.t('mont.cerrar'))),
      ],
    ),
  );
}
