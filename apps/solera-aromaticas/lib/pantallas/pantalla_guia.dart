// Guía de especies (Campo → icono de libro), al estilo de la guía de Fósiles:
// lista buscable agrupada por familia y ficha deslizable con fotos de
// Wikimedia Commons, rasgos para reconocerla, hábitat, época, parte que se
// recolecta, protección y especies con las que se confunde.
//
// HARD LIMIT: nada de usos de salud. Solo botánica, y el aviso de que la
// guía no habilita el consumo va arriba de la lista y en cada ficha.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/flag_revision.dart';
import '../dominio/catalogos.dart';
import '../dominio/guia.dart';
import '../servicios/fotos_wikipedia.dart';

class PantallaGuia extends StatefulWidget {
  const PantallaGuia({super.key, this.buscarFotos});

  /// Se sustituye en los tests para no salir a la red; si falta, el de
  /// [buscadorFotosGuia].
  final BuscadorFotos? buscarFotos;

  @override
  State<PantallaGuia> createState() => _PantallaGuiaState();
}

class _PantallaGuiaState extends State<PantallaGuia> {
  final _controladorBusqueda = TextEditingController();
  String _consulta = '';

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grupos = guiaPorFamilia(consulta: _consulta);
    final elementos = <Widget>[
      _AvisoNoConsumo(),
      if (!catalogosCompletamenteRevisados)
        AvisoCatalogosProvisionales(
            texto: SoleraL10n.t('arom.catalogos_provisionales')),
      if (grupos.isEmpty)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(SoleraL10n.t('arom.guia_sin_resultados'),
              textAlign: TextAlign.center),
        ),
      for (final grupo in grupos) ...[
        _CabeceraFamilia(familia: grupo.familia),
        for (final (indice, entrada) in grupo.entradas.indexed)
          _TarjetaEspecie(
            entrada: entrada,
            buscarFotos: widget.buscarFotos ?? buscadorFotosGuia,
            alPulsar: () => abrirFichaGuia(context,
                lista: grupo.entradas,
                indiceInicial: indice,
                buscarFotos: widget.buscarFotos ?? buscadorFotosGuia),
          ),
      ],
    ];
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arom.guia'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: (texto) => setState(() => _consulta = texto),
              decoration: InputDecoration(
                hintText: SoleraL10n.t('arom.guia_buscar'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _consulta.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _controladorBusqueda.clear();
                          _consulta = '';
                        }),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
              itemCount: elementos.length,
              itemBuilder: (_, indice) => elementos[indice],
            ),
          ),
        ],
      ),
    );
  }
}

/// Abre la ficha de [lista] en [indiceInicial], deslizable a izquierda y
/// derecha entre las especies de la lista.
void abrirFichaGuia(BuildContext context,
    {required List<EntradaGuia> lista,
    required int indiceInicial,
    BuscadorFotos? buscarFotos}) {
  final buscador = buscarFotos ?? buscadorFotosGuia;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controladorScroll) => _FichasDeslizables(
        lista: lista,
        indiceInicial: indiceInicial,
        controladorScroll: controladorScroll,
        buscarFotos: buscador,
      ),
    ),
  );
}

/// Abre la ficha de una sola especie (desde una confundible).
void _abrirFichaDeEspecie(
    BuildContext context, String especieId, BuscadorFotos buscarFotos) {
  final especie = especiePorId(especieId);
  if (especie == null) return;
  abrirFichaGuia(context,
      lista: [(especie: especie, ficha: fichaGuiaDe(especieId))],
      indiceInicial: 0,
      buscarFotos: buscarFotos);
}

class _AvisoNoConsumo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      color: colores.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: colores.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(SoleraL10n.t('arom.guia_aviso'),
                  style: TextStyle(color: colores.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabeceraFamilia extends StatelessWidget {
  const _CabeceraFamilia({required this.familia});

  final String familia;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: colores.secondaryContainer,
          borderRadius: BorderRadius.circular(4)),
      child: Text(familia,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: colores.onSecondaryContainer)),
    );
  }
}

class _TarjetaEspecie extends StatelessWidget {
  const _TarjetaEspecie(
      {required this.entrada,
      required this.buscarFotos,
      required this.alPulsar});

  final EntradaGuia entrada;
  final BuscadorFotos buscarFotos;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final especie = entrada.especie;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: _Miniatura(
              tituloWikipedia: tituloWikipediaDe(especie),
              buscarFotos: buscarFotos),
        ),
        title: Text(especie.nombre),
        subtitle: Text(especie.nombreCientifico,
            style: const TextStyle(fontStyle: FontStyle.italic)),
        trailing: especie.proteccion.isEmpty
            ? null
            : Tooltip(
                message: SoleraL10n.t('arom.aviso_especie_protegida'),
                child: Icon(Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.error),
              ),
        onTap: alPulsar,
      ),
    );
  }
}

Widget _huecoSinFoto({double tamanoIcono = 24}) => Container(
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.center,
      child: Icon(Icons.local_florist_outlined,
          size: tamanoIcono, color: Colors.black38),
    );

Widget _imagenRed(String direccion, {required int anchoCache}) =>
    CachedNetworkImage(
      imageUrl: direccion,
      httpHeaders: cabecerasWikimedia,
      fit: BoxFit.cover,
      memCacheWidth: anchoCache,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => Container(color: Colors.black12),
      errorWidget: (_, __, ___) => _huecoSinFoto(),
    );

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.tituloWikipedia, required this.buscarFotos});

  final String tituloWikipedia;
  final BuscadorFotos buscarFotos;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: buscarFotos(tituloWikipedia),
      builder: (_, instantanea) {
        final fotos = instantanea.data ?? const <String>[];
        if (fotos.isEmpty) return _huecoSinFoto();
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _imagenRed(fotos.first, anchoCache: 200),
        );
      },
    );
  }
}

class _FichasDeslizables extends StatefulWidget {
  const _FichasDeslizables({
    required this.lista,
    required this.indiceInicial,
    required this.controladorScroll,
    required this.buscarFotos,
  });

  final List<EntradaGuia> lista;
  final int indiceInicial;
  final ScrollController controladorScroll;
  final BuscadorFotos buscarFotos;

  @override
  State<_FichasDeslizables> createState() => _FichasDeslizablesState();
}

class _FichasDeslizablesState extends State<_FichasDeslizables> {
  late final PageController _controladorPaginas =
      PageController(initialPage: widget.indiceInicial);
  late int _indiceActual = widget.indiceInicial;

  @override
  void dispose() {
    _controladorPaginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.lista.length > 1)
          Text('${_indiceActual + 1} / ${widget.lista.length}',
              style: Theme.of(context).textTheme.labelMedium),
        Expanded(
          child: PageView.builder(
            controller: _controladorPaginas,
            itemCount: widget.lista.length,
            onPageChanged: (indice) => setState(() => _indiceActual = indice),
            itemBuilder: (_, indice) => SingleChildScrollView(
              controller: widget.controladorScroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: _ContenidoFicha(
                  entrada: widget.lista[indice],
                  buscarFotos: widget.buscarFotos),
            ),
          ),
        ),
      ],
    );
  }
}

String _nombreMes(int mes) =>
    DateFormat.MMMM(SoleraL10n.idioma).format(DateTime(2026, mes));

String _textoOrigen(String origen) => switch (origen) {
      'cultivo' => SoleraL10n.t('arom.cultivo'),
      'silvestre' => SoleraL10n.t('arom.silvestre'),
      _ => SoleraL10n.t('arom.guia_origen_ambos'),
    };

class _ContenidoFicha extends StatelessWidget {
  const _ContenidoFicha({required this.entrada, required this.buscarFotos});

  final EntradaGuia entrada;
  final BuscadorFotos buscarFotos;

  @override
  Widget build(BuildContext context) {
    final especie = entrada.especie;
    final ficha = entrada.ficha;
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final epoca = especie.mesInicio == null || especie.mesFin == null
        ? SoleraL10n.t('arom.guia_sin_epoca')
        : especie.mesInicio == especie.mesFin
            ? _nombreMes(especie.mesInicio!)
            : '${_nombreMes(especie.mesInicio!)} – ${_nombreMes(especie.mesFin!)}';

    Widget apartado(String titulo, Widget contenido) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: tema.textTheme.titleSmall),
              const SizedBox(height: 4),
              contenido,
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Galeria(
            tituloWikipedia: tituloWikipediaDe(especie),
            buscarFotos: buscarFotos),
        const SizedBox(height: 12),
        Text(especie.nombre, style: tema.textTheme.headlineSmall),
        Text(especie.nombreCientifico,
            style: tema.textTheme.titleMedium
                ?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(
                label: Text(
                    '${SoleraL10n.t('arom.guia_familia')}: ${especie.familia}')),
            Chip(label: Text(_textoOrigen(especie.origen))),
          ],
        ),
        if (especie.proteccion.isNotEmpty)
          Card(
            color: colores.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                [
                  SoleraL10n.t('arom.aviso_especie_protegida'),
                  if (especie.notaProteccion.isNotEmpty) especie.notaProteccion,
                ].join('\n\n'),
                style: TextStyle(color: colores.onErrorContainer),
              ),
            ),
          ),
        if (ficha != null && ficha.rasgos.isNotEmpty)
          apartado(
            SoleraL10n.t('arom.guia_rasgos'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final rasgo in ficha.rasgos)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2),
                    child: Text('• $rasgo'),
                  ),
              ],
            ),
          ),
        if (especie.confundibles.isNotEmpty)
          apartado(
            SoleraL10n.t('arom.guia_confundibles'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final confundible in especie.confundibles)
                  especiePorId(confundible) != null
                      ? ActionChip(
                          avatar: const Icon(Icons.compare_arrows, size: 18),
                          label: Text(nombreConfundible(confundible)),
                          onPressed: () => _abrirFichaDeEspecie(
                              context, confundible, buscarFotos),
                        )
                      : Text(confundible),
              ],
            ),
          ),
        if (ficha != null && ficha.habitat.isNotEmpty)
          apartado(SoleraL10n.t('arom.guia_habitat'), Text(ficha.habitat)),
        apartado(
            SoleraL10n.t('arom.parte_recolectada'), Text(especie.parteUsada)),
        apartado(SoleraL10n.t('arom.guia_epoca'), Text(epoca)),
        if (especie.notas.isNotEmpty)
          apartado(SoleraL10n.t('arom.notas'), Text(especie.notas)),
        const SizedBox(height: 16),
        Text(SoleraL10n.t('arom.guia_aviso'),
            style: tema.textTheme.bodySmall?.copyWith(color: colores.error)),
        if (ficha != null && ficha.revisadoPor.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(SoleraL10n.t('arom.guia_sin_revisar'),
                style: tema.textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _Galeria extends StatefulWidget {
  const _Galeria({required this.tituloWikipedia, required this.buscarFotos});

  final String tituloWikipedia;
  final BuscadorFotos buscarFotos;

  @override
  State<_Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<_Galeria> {
  // El future se resuelve una vez (en initState o al reintentar): si viviera
  // en build, cada cambio de página volvería a pedirlo y parpadearía.
  late Future<List<String>> _futuroFotos =
      widget.buscarFotos(widget.tituloWikipedia);
  int _fotoActual = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _futuroFotos,
      builder: (context, instantanea) {
        if (instantanea.connectionState != ConnectionState.done) {
          return Container(
            height: 240,
            color: Colors.black12,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }
        final fotos = instantanea.data ?? const <String>[];
        if (fotos.isEmpty) {
          return Container(
            height: 180,
            color: Colors.black12,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_florist_outlined,
                    size: 56, color: Colors.black38),
                const SizedBox(height: 4),
                Text(SoleraL10n.t('arom.guia_sin_fotos')),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _futuroFotos = widget.buscarFotos(widget.tituloWikipedia);
                  }),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(SoleraL10n.t('arom.guia_reintentar')),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: fotos.length,
                      onPageChanged: (indice) =>
                          setState(() => _fotoActual = indice),
                      itemBuilder: (_, indice) =>
                          _imagenRed(fotos[indice], anchoCache: 1200),
                    ),
                    if (fotos.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text('${_fotoActual + 1} / ${fotos.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(SoleraL10n.t('arom.guia_fotos'),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        );
      },
    );
  }
}
