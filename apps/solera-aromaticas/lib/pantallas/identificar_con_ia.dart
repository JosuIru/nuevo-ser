import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_especies.dart';
import '../dominio/catalogos.dart';
import '../estado/clave_anthropic_aromaticas.dart';
import '../modelos/parcela.dart';
import '../servicios/identificador_ia.dart';
import 'formularios.dart';

/// Pantalla de la clave de IA de Larrea Aromáticas.
Widget pantallaClaveAromaticas() => PantallaClaveAnthropic(
      estado: estadoClaveAromaticas,
      nombreApp: 'Larrea Aromáticas',
      queIdentifica: SoleraL10n.t('arom.ia_que_hace'),
    );

/// Nombre visible de un nivel de confianza.
String nombreConfianza(String nivel) => switch (nivel) {
      'alta' => SoleraL10n.t('arom.confianza_alta'),
      'media' => SoleraL10n.t('arom.confianza_media'),
      _ => SoleraL10n.t('arom.confianza_baja'),
    };

/// Pide la foto (cámara o galería) y la clave; devuelve la clave y la ruta,
/// o null si la persona cancela o no hay clave (abre su pantalla).
Future<(String, String)?> _pedirFotoYClave(BuildContext context) async {
  final clave = await estadoClaveAromaticas.cargar();
  if (!context.mounted) return null;
  if (clave == null || !estadoClaveAromaticas.hayClave.value) {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => pantallaClaveAromaticas()));
    return null;
  }
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(SoleraL10n.t('arom.hacer_foto')),
            onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
        ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(SoleraL10n.t('arom.elegir_foto')),
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

/// Llama a la IA con la foto y la borra siempre al terminar.
Future<T?> _analizar<T>(BuildContext context, String ruta,
    Future<T> Function(ImagenClaude foto) llamar) async {
  final mensajero = ScaffoldMessenger.of(context);
  mensajero.showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('arom.ia_analizando'))));
  try {
    return await llamar(await ImagenClaude.desdeFichero(ruta));
  } catch (error) {
    debugPrint('Identificación fallida: $error');
    mensajero
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('arom.ia_error'))));
    return null;
  } finally {
    await GestorFotos.borrarSiExiste(ruta);
  }
}

/// Aviso fijo del hard limit, siempre junto a la propuesta de especie.
Widget avisoIdentificacionEspecie(BuildContext context) => Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(SoleraL10n.t('arom.ia_aviso_no_consumo')),
      ),
    );

/// Foto → especies candidatas → la persona elige y se abre el alta de una
/// cosecha con la especie rellena (o cierra sin apuntar nada).
Future<void> identificarEspecieConFoto(BuildContext context) async {
  final pedido = await _pedirFotoYClave(context);
  if (pedido == null || !context.mounted) return;
  final (clave, ruta) = pedido;
  final propuesta = await _analizar(context, ruta,
      (foto) => identificarEspecieConIa(claveApi: clave, foto: foto));
  if (propuesta == null || !context.mounted) return;
  final elegida = await showDialog<EspecieCatalogo>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('arom.ia_propuesta_especie')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avisoIdentificacionEspecie(contexto),
            if (!propuesta.legible) Text(SoleraL10n.t('arom.ia_no_legible')),
            for (final candidato in propuesta.candidatos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    '${candidato.fila.nombre} (${candidato.fila.nombreCientifico})'),
                subtitle: Text([
                  '${nombreConfianza(candidato.confianza)} · ${candidato.motivo}',
                  if (candidato.fila.proteccion.isNotEmpty)
                    SoleraL10n.t('arom.aviso_especie_protegida'),
                  if (candidato.fila.confundibles.isNotEmpty)
                    SoleraL10n.tf('arom.aviso_confundibles', {
                      'especies': candidato.fila.confundibles
                          .map(nombreConfundible)
                          .join(', ')
                    }),
                ].join('\n')),
                onTap: () => Navigator.pop(contexto, candidato.fila),
              ),
            if (propuesta.fueraDelCatalogo)
              Text(SoleraL10n.t('arom.ia_fuera_catalogo')),
            if (propuesta.rasgosAComprobar.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(SoleraL10n.tf(
                    'arom.ia_rasgos', {'rasgos': propuesta.rasgosAComprobar})),
              ),
            if (propuesta.observaciones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(propuesta.observaciones),
              ),
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
  if (elegida == null || !context.mounted) return;
  await mostrarAltaCosecha(context, especiePropuesta: elegida.id);
}

/// Elige una parcela de cultivo, foto → plagas candidatas del catálogo de su
/// especie. Solo informa: nunca abre un tratamiento.
Future<void> identificarPlagaConFoto(BuildContext context) async {
  final parcelas = (await BaseDatosSoleraAromaticas.instancia.listarParcelas())
      .where((parcela) => plagasParaIdentificar(parcela.especieId).isNotEmpty)
      .toList();
  if (!context.mounted) return;
  if (parcelas.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('arom.ia_sin_plagas_catalogo'))));
    return;
  }
  final parcela = parcelas.length == 1
      ? parcelas.first
      : await showDialog<Parcela>(
          context: context,
          builder: (contexto) => SimpleDialog(
            title: Text(SoleraL10n.t('arom.parcela')),
            children: [
              for (final candidata in parcelas)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(contexto, candidata),
                  child: Text(
                      '${candidata.nombre} · ${nombreEspecie(candidata.especieId)}'),
                ),
            ],
          ),
        );
  if (parcela == null || !context.mounted) return;
  final pedido = await _pedirFotoYClave(context);
  if (pedido == null || !context.mounted) return;
  final (clave, ruta) = pedido;
  final propuesta = await _analizar(
      context,
      ruta,
      (foto) => identificarPlagaConIa(
          claveApi: clave,
          especieId: parcela.especieId,
          nombreEspecie: nombreEspecie(parcela.especieId),
          foto: foto));
  if (propuesta == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('arom.ia_propuesta_plaga')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!propuesta.legible) Text(SoleraL10n.t('arom.ia_no_legible')),
            for (final candidato in propuesta.candidatos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(candidato.fila.nombre),
                subtitle: Text(
                    '${nombreConfianza(candidato.confianza)} · ${candidato.motivo}'),
              ),
            if (propuesta.fueraDelCatalogo)
              Text(SoleraL10n.t('arom.ia_fuera_catalogo')),
            if (propuesta.observaciones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(propuesta.observaciones),
              ),
            const SizedBox(height: 8),
            Text(SoleraL10n.t('arom.ia_revisa_plaga'),
                style: Theme.of(contexto).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: Text(SoleraL10n.t('arom.cerrar'))),
      ],
    ),
  );
}
