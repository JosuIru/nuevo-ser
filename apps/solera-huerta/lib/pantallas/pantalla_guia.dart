// Guía del huerto (icono de libro en Hoy): cuatro secciones con buscador
// (cultivos, fauna auxiliar, plantas que ayudan y técnicas) y una ficha por
// entrada. Sin fotos en la v1. El contenido sale de content/huerta/guia_*.csv
// (solo castellano por ahora); los rótulos, de SoleraL10n.
//
// HARD LIMIT: la guía no recomienda tratar con nada, ni productos ni dosis.
// Cada ficha lleva el aviso fijo de que es orientativa y revisada con IA.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/catalogos_generados/catalogo_guia_cultivos.dart';
import '../datos/catalogos_generados/catalogo_guia_fauna.dart';
import '../datos/catalogos_generados/catalogo_guia_plantas.dart';
import '../datos/catalogos_generados/catalogo_guia_tecnicas.dart';
import '../datos/catalogos_generados/catalogo_rotacion.dart';
import '../dominio/catalogos.dart';
import '../dominio/guia.dart';

class PantallaGuia extends StatefulWidget {
  const PantallaGuia({super.key, this.seccionInicial = SeccionGuia.cultivos});

  final SeccionGuia seccionInicial;

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
    return DefaultTabController(
      length: SeccionGuia.values.length,
      initialIndex: widget.seccionInicial.index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(SoleraL10n.t('huer.guia')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: SoleraL10n.t('huer.guia_cultivos')),
              Tab(text: SoleraL10n.t('huer.guia_fauna')),
              Tab(text: SoleraL10n.t('huer.guia_plantas')),
              Tab(text: SoleraL10n.t('huer.guia_tecnicas')),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _controladorBusqueda,
                onChanged: (texto) => setState(() => _consulta = texto),
                decoration: InputDecoration(
                  hintText: SoleraL10n.t('huer.guia_buscar'),
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
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ListaGuia(entradas: [
                    for (final ficha in buscarCultivos(_consulta))
                      _EntradaLista(
                        titulo: nombreCultivoGuia(ficha.id),
                        subtitulo: nombreFamilia(familiaDeEspecie(ficha.id)),
                        icono: Icons.spa_outlined,
                        abrir: (contexto) =>
                            abrirFichaCultivoGuia(contexto, ficha.id),
                      ),
                  ]),
                  _ListaGuia(entradas: [
                    for (final ficha in buscarFauna(_consulta))
                      _EntradaLista(
                        titulo: ficha.nombre,
                        subtitulo: ficha.nombreCientifico,
                        icono: Icons.pest_control_rodent_outlined,
                        abrir: (contexto) =>
                            abrirFichaFaunaGuia(contexto, ficha.id),
                      ),
                  ]),
                  _ListaGuia(entradas: [
                    for (final ficha in buscarPlantas(_consulta))
                      _EntradaLista(
                        titulo: ficha.nombre,
                        subtitulo: _nombreTipoPlanta(ficha.tipo),
                        icono: Icons.local_florist_outlined,
                        abrir: (contexto) =>
                            abrirFichaPlantaGuia(contexto, ficha.id),
                      ),
                  ]),
                  _ListaGuia(entradas: [
                    for (final ficha in buscarTecnicas(_consulta))
                      _EntradaLista(
                        titulo: ficha.titulo,
                        subtitulo: ficha.resumen,
                        icono: Icons.lightbulb_outline,
                        abrir: (contexto) =>
                            _abrirFicha(contexto, _FichaTecnica(ficha: ficha)),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntradaLista {
  const _EntradaLista({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.abrir,
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final void Function(BuildContext) abrir;
}

class _ListaGuia extends StatelessWidget {
  const _ListaGuia({required this.entradas});

  final List<_EntradaLista> entradas;

  @override
  Widget build(BuildContext context) {
    if (entradas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(SoleraL10n.t('huer.guia_sin_resultados'),
            textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      itemCount: entradas.length,
      itemBuilder: (contexto, indice) {
        final entrada = entradas[indice];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: ListTile(
            leading: Icon(entrada.icono),
            title: Text(entrada.titulo),
            subtitle: entrada.subtitulo.isEmpty
                ? null
                : Text(entrada.subtitulo,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => entrada.abrir(contexto),
          ),
        );
      },
    );
  }
}

String _nombreTipoPlanta(String tipo) => switch (tipo) {
      'flor_auxiliares' => SoleraL10n.t('huer.guia_tipo_flor'),
      'abono_verde' => SoleraL10n.t('huer.guia_tipo_abono_verde'),
      'cobertura' => SoleraL10n.t('huer.guia_tipo_cobertura'),
      'reservorio' => SoleraL10n.t('huer.guia_tipo_reservorio'),
      _ => tipo,
    };

String _nombreForma(FormaSiembra forma) => switch (forma) {
      FormaSiembra.semillero => SoleraL10n.t('huer.guia_semillero'),
      FormaSiembra.directa => SoleraL10n.t('huer.guia_directa'),
      FormaSiembra.trasplante => SoleraL10n.t('huer.guia_trasplante'),
    };

String nombreFormaSiembraGuia(FormaSiembra forma) => _nombreForma(forma);

Future<void> _abrirFicha(BuildContext context, Widget ficha) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ficha));

/// Abre la ficha de un cultivo (id del catálogo). Si no tiene ficha, nada.
Future<void> abrirFichaCultivoGuia(
    BuildContext context, String cultivoId) async {
  final ficha = fichaGuiaCultivo(cultivoId);
  if (ficha == null) return;
  await _abrirFicha(context, _FichaCultivo(ficha: ficha));
}

Future<void> abrirFichaFaunaGuia(BuildContext context, String faunaId) async {
  final ficha = fichaGuiaFauna(faunaId);
  if (ficha == null) return;
  await _abrirFicha(context, _FichaFauna(ficha: ficha));
}

Future<void> abrirFichaPlantaGuia(BuildContext context, String plantaId) async {
  final ficha = fichaGuiaPlanta(plantaId);
  if (ficha == null) return;
  await _abrirFicha(context, _FichaPlanta(ficha: ficha));
}

/// Hoja con la fauna auxiliar que, según la guía, combate la plaga.
Future<void> mostrarAuxiliaresDePlaga(
    BuildContext context, String plagaId) async {
  final auxiliares = auxiliaresDePlaga(plagaId);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (contexto) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(SoleraL10n.t('huer.guia_auxiliares'),
                style: Theme.of(contexto).textTheme.titleMedium),
            subtitle: Text(nombrePlaga(plagaId)),
          ),
          if (auxiliares.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(SoleraL10n.t('huer.guia_sin_auxiliares')),
            ),
          for (final ficha in auxiliares)
            ListTile(
              leading: const Icon(Icons.pest_control_rodent_outlined),
              title: Text(ficha.nombre),
              subtitle: Text(ficha.nombreCientifico),
              onTap: () => abrirFichaFaunaGuia(contexto, ficha.id),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(SoleraL10n.t('huer.guia_no_tratar'),
                style: Theme.of(contexto).textTheme.bodySmall),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Piezas comunes de las fichas

class _EsqueletoFicha extends StatelessWidget {
  const _EsqueletoFicha({
    required this.titulo,
    this.subtitulo = '',
    required this.apartados,
    required this.fuente,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> apartados;
  final String fuente;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _AvisoGuia(),
          if (subtitulo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(subtitulo,
                  style: tema.textTheme.titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic)),
            ),
          ...apartados,
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_fuentes'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final cita in citasDe(fuente))
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('• $cita', style: tema.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoGuia extends StatelessWidget {
  const _AvisoGuia();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('aviso-guia'),
      color: colores.secondaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colores.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(SoleraL10n.t('huer.guia_aviso'),
                  style: TextStyle(color: colores.onSecondaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Apartado extends StatelessWidget {
  const _Apartado({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

/// Apartado de texto, o nada si el texto está vacío.
List<Widget> _texto(String titulo, String texto) => texto.trim().isEmpty
    ? const []
    : [_Apartado(titulo: titulo, child: Text(texto))];

class _Fichas extends StatelessWidget {
  const _Fichas({required this.chips});

  final List<Widget> chips;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 4, children: chips);
}

Widget _chipFicha(String texto, VoidCallback? alPulsar) => alPulsar == null
    ? Chip(label: Text(texto))
    : ActionChip(label: Text(texto), onPressed: alPulsar);

// ---------------------------------------------------------------------------
// Ficha de cultivo

class _FichaCultivo extends StatelessWidget {
  const _FichaCultivo({required this.ficha});

  final FichaGuiaCultivo ficha;

  @override
  Widget build(BuildContext context) {
    final calendario = calendarioDe(ficha);
    final especie = especiePorId(ficha.id);
    return _EsqueletoFicha(
      titulo: nombreCultivoGuia(ficha.id),
      subtitulo: especie?.nombreCientifico ?? '',
      fuente: ficha.fuente,
      apartados: [
        _Apartado(
          titulo: SoleraL10n.t('huer.guia_calendario'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (calendario.isEmpty)
                Text(SoleraL10n.t('huer.guia_sin_calendario'))
              else
                _Calendario(calendario: calendario),
              if (ficha.calendario.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                      SoleraL10n.tf('huer.guia_calendario_de',
                          {'zona': ficha.calendario}),
                      style: Theme.of(context).textTheme.bodySmall),
                ),
            ],
          ),
        ),
        if (especie != null && especie.marco.isNotEmpty)
          _Apartado(
              titulo: SoleraL10n.t('huer.guia_marco'),
              child: Text(especie.marco)),
        ..._texto(SoleraL10n.t('huer.guia_siembra'), ficha.siembra),
        ..._texto(SoleraL10n.t('huer.guia_riego'), ficha.riego),
        ..._texto(SoleraL10n.t('huer.guia_cosecha'), ficha.cosecha),
        if (ficha.asociacionesFavorables.isNotEmpty ||
            ficha.asociacionesDesfavorables.isNotEmpty ||
            ficha.notaAsociaciones.isNotEmpty)
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_asociaciones'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ficha.asociacionesFavorables.isNotEmpty) ...[
                  Text(SoleraL10n.t('huer.guia_favorables')),
                  _Fichas(chips: [
                    for (final valor in ficha.asociacionesFavorables)
                      _chipAsociacion(context, valor),
                  ]),
                ],
                if (ficha.asociacionesDesfavorables.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(SoleraL10n.t('huer.guia_desfavorables')),
                  _Fichas(chips: [
                    for (final valor in ficha.asociacionesDesfavorables)
                      _chipAsociacion(context, valor),
                  ]),
                ],
                if (ficha.asociacionesFavorables.isNotEmpty ||
                    ficha.asociacionesDesfavorables.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        SoleraL10n.t('huer.guia_asociaciones_tradicion'),
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                if (ficha.notaAsociaciones.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(ficha.notaAsociaciones),
                  ),
              ],
            ),
          ),
        if (ficha.plagas.isNotEmpty)
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_plagas'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Fichas(chips: [
                  for (final plagaId in ficha.plagas)
                    _chipFicha(
                        nombrePlaga(plagaId),
                        auxiliaresDePlaga(plagaId).isEmpty
                            ? null
                            : () => mostrarAuxiliaresDePlaga(context, plagaId)),
                ]),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(SoleraL10n.t('huer.guia_no_tratar'),
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ..._texto(SoleraL10n.t('huer.guia_curiosidad'), ficha.curiosidad),
      ],
    );
  }

  Widget _chipAsociacion(BuildContext context, String valor) => _chipFicha(
      nombreAsociacion(valor),
      asociacionConFicha(valor) && valor != ficha.id
          ? () => abrirFichaCultivoGuia(context, valor)
          : null);
}

/// Tabla de 12 meses con una fila por forma de siembra.
class _Calendario extends StatelessWidget {
  const _Calendario({required this.calendario});

  final Map<FormaSiembra, Set<int>> calendario;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final estiloMes = Theme.of(context).textTheme.labelSmall;
    String inicial(int mes) => DateFormat.MMM(SoleraL10n.idioma)
        .format(DateTime(2026, mes))
        .substring(0, 1)
        .toUpperCase();
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          const SizedBox.shrink(),
          for (var mes = 1; mes <= 12; mes++)
            Center(child: Text(inicial(mes), style: estiloMes)),
        ]),
        for (final MapEntry(key: forma, value: meses) in calendario.entries)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
              child: Text(_nombreForma(forma), style: estiloMes),
            ),
            for (var mes = 1; mes <= 12; mes++)
              Container(
                height: 14,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: meses.contains(mes)
                      ? colores.primary
                      : colores.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ficha de fauna auxiliar

class _FichaFauna extends StatelessWidget {
  const _FichaFauna({required this.ficha});

  final FichaGuiaFauna ficha;

  @override
  Widget build(BuildContext context) {
    final plantas = plantasParaFauna(ficha.id);
    return _EsqueletoFicha(
      titulo: ficha.nombre,
      subtitulo: ficha.nombreCientifico,
      fuente: ficha.fuente,
      apartados: [
        ..._texto(SoleraL10n.t('huer.guia_que_hace'), ficha.queHace),
        ..._texto(SoleraL10n.t('huer.guia_reconocer'), ficha.comoReconocerla),
        ..._texto(SoleraL10n.t('huer.guia_atraer'), ficha.comoAtraerla),
        if (ficha.plagas.isNotEmpty)
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_plagas_que_controla'),
            child: _Fichas(chips: [
              for (final plagaId in ficha.plagas)
                _chipFicha(nombrePlaga(plagaId), null),
            ]),
          ),
        if (plantas.isNotEmpty)
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_plantas_que_atraen'),
            child: _Fichas(chips: [
              for (final planta in plantas)
                _chipFicha(planta.nombre,
                    () => abrirFichaPlantaGuia(context, planta.id)),
            ]),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ficha de planta que ayuda

class _FichaPlanta extends StatelessWidget {
  const _FichaPlanta({required this.ficha});

  final FichaGuiaPlanta ficha;

  @override
  Widget build(BuildContext context) {
    return _EsqueletoFicha(
      titulo: ficha.nombre,
      subtitulo: ficha.nombreCientifico,
      fuente: ficha.fuente,
      apartados: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _Fichas(
              chips: [Chip(label: Text(_nombreTipoPlanta(ficha.tipo)))]),
        ),
        ..._texto(SoleraL10n.t('huer.guia_que_aporta'), ficha.queAporta),
        ..._texto(SoleraL10n.t('huer.guia_cuando'), ficha.cuandoSembrar),
        ..._texto(SoleraL10n.t('huer.guia_cuidado'), ficha.cuidado),
        if (ficha.fauna.isNotEmpty)
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_fauna_que_atrae'),
            child: _Fichas(chips: [
              for (final faunaId in ficha.fauna)
                _chipFicha(fichaGuiaFauna(faunaId)?.nombre ?? faunaId,
                    () => abrirFichaFaunaGuia(context, faunaId)),
            ]),
          ),
        if (ficha.cultivoId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () => abrirFichaCultivoGuia(context, ficha.cultivoId),
              icon: const Icon(Icons.spa_outlined),
              label: Text(SoleraL10n.tf('huer.guia_ver_cultivo',
                  {'cultivo': nombreCultivoGuia(ficha.cultivoId)})),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ficha de técnica

class _FichaTecnica extends StatelessWidget {
  const _FichaTecnica({required this.ficha});

  final FichaGuiaTecnica ficha;

  @override
  Widget build(BuildContext context) {
    return _EsqueletoFicha(
      titulo: ficha.titulo,
      fuente: ficha.fuente,
      apartados: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(ficha.resumen),
        ),
        if (ficha.pasos.isNotEmpty)
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_pasos'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final paso in ficha.pasos)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text('• $paso'),
                  ),
              ],
            ),
          ),
        ..._texto(SoleraL10n.t('huer.guia_truco'), ficha.truco),
        if (ficha.enlaceApp == 'rotacion')
          _Apartado(
            titulo: SoleraL10n.t('huer.guia_rotacion_tabla'),
            child: Column(
              children: [
                for (final familia in catalogoRotacion)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(familia.nombre),
                    subtitle: familia.ejemplos.isEmpty
                        ? null
                        : Text(familia.ejemplos),
                    trailing: Text(familia.aniosMinimos == null
                        ? SoleraL10n.t('huer.guia_sin_dato')
                        : SoleraL10n.tf(
                            'huer.guia_anios', {'n': familia.aniosMinimos!})),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
