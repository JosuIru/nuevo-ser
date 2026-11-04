import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogo_cultivos.dart';
import '../datos/catalogo_plagas.dart';
import '../datos/info_cultivos.dart';
import 'widgets/imagen_commons_widget.dart';

/// Pantalla "Guía" con dos tabs:
/// 1) Cultivos: lista navegable; detalle con descripción agronómica,
///    exigencias, calendario y lista de plagas/enfermedades vinculadas.
/// 2) Plagas y enfermedades: lista filtrable por cultivo y por tipo
///    (plaga, enfermedad, fisiológico, abiótico).
///
/// El detalle de un cultivo enlaza con sus plagas; el detalle de una
/// plaga enlaza con los cultivos afectados (navegación cruzada).
class PantallaGuia extends StatelessWidget {
  const PantallaGuia({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(SoleraL10n.t('agro.guia')),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.eco), text: SoleraL10n.t('agro.cultivos')),
              Tab(icon: Icon(Icons.bug_report), text: SoleraL10n.t('agro.plagas_y_enfermedades')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ListaCultivos(),
            _ListaPlagas(),
          ],
        ),
      ),
    );
  }
}

class _ListaCultivos extends StatefulWidget {
  _ListaCultivos();

  @override
  State<_ListaCultivos> createState() => _ListaCultivosState();
}

class _ListaCultivosState extends State<_ListaCultivos> {
  // Buscador de cultivos: el tester (2026-05-15) reportó que la pestaña
  // "Plagas" tenía filtros por cultivo y tipo, pero la pestaña
  // "Cultivos" no tenía buscador y había que scrollear toda la lista
  // para encontrar uno concreto.
  String _consulta = '';

  @override
  Widget build(BuildContext context) {
    final consultaLimpia = _consulta.trim().toLowerCase();
    final cultivosFiltrados = consultaLimpia.isEmpty
        ? catalogoCultivos
        : catalogoCultivos.where((c) {
            final texto = '${c.nombreVisible} ${c.nombreCientifico}'
                .toLowerCase();
            return texto.contains(consultaLimpia);
          }).toList();
    final porCategoria = <CategoriaCultivo, List<Cultivo>>{};
    for (final c in cultivosFiltrados) {
      porCategoria.putIfAbsent(c.categoria, () => []).add(c);
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              labelText: SoleraL10n.t('agro.buscar_cultivo'),
              hintText: SoleraL10n.t('agro.ejemplo_buscar_cultivo'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: _consulta.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _consulta = ''),
                    ),
            ),
            onChanged: (v) => setState(() => _consulta = v),
          ),
        ),
        Expanded(
          child: cultivosFiltrados.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      SoleraL10n.tf('agro.sin_cultivos_para_consulta', {'consulta': _consulta}),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView(
                  children: [
                    for (final cat in CategoriaCultivo.values)
                      if (porCategoria[cat] != null)
                        _BloqueCategoria(
                          categoria: cat,
                          cultivos: porCategoria[cat]!,
                        ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _BloqueCategoria extends StatelessWidget {
  final CategoriaCultivo categoria;
  final List<Cultivo> cultivos;
  _BloqueCategoria({required this.categoria, required this.cultivos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            _nombreCategoriaCultivo(categoria),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        for (final c in cultivos)
          ListTile(
            leading: CircleAvatar(backgroundColor: c.color, child: Icon(c.icono, color: Colors.white)),
            title: Text(c.nombreVisible),
            subtitle: c.nombreCientifico.isEmpty
                ? null
                : Text(c.nombreCientifico, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaDetalleCultivo(cultivo: c)),
            ),
          ),
      ],
    );
  }
}

class PantallaDetalleCultivo extends StatelessWidget {
  final Cultivo cultivo;
  PantallaDetalleCultivo({super.key, required this.cultivo});

  @override
  Widget build(BuildContext context) {
    final info = infoCultivos[cultivo.id];
    final plagas = plagasDeCultivo(cultivo.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(cultivo.nombreVisible),
        backgroundColor: cultivo.color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cultivo.nombreCientifico.isNotEmpty)
            ImagenCommonsWidget(
              tituloWikipedia: _tituloWikipediaParaCultivo(cultivo),
              terminoBusqueda: cultivo.nombreCientifico,
              altura: 220,
            ),
          if (cultivo.nombreCientifico.isNotEmpty) SizedBox(height: 12),
          if (cultivo.nombreCientifico.isNotEmpty)
            Text(
              cultivo.nombreCientifico,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          SizedBox(height: 4),
          Text(
            _nombreCategoriaCultivo(cultivo.categoria),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          if (info?.descripcion.isNotEmpty == true) ...[
            _Subtitulo(SoleraL10n.t('agro.descripcion')),
            Text(info!.descripcion),
            SizedBox(height: 16),
          ],
          if (info?.exigencias.isNotEmpty == true) ...[
            _Subtitulo(SoleraL10n.t('agro.exigencias_agronomicas')),
            Text(info!.exigencias),
            SizedBox(height: 16),
          ],
          if (info?.calendario.isNotEmpty == true) ...[
            _Subtitulo(SoleraL10n.t('agro.calendario')),
            Text(info!.calendario),
            SizedBox(height: 16),
          ],
          if (cultivo.variedadesSugeridas.isNotEmpty) ...[
            _Subtitulo(SoleraL10n.t('agro.variedades_habituales')),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in cultivo.variedadesSugeridas)
                  Chip(label: Text(v, style: TextStyle(fontSize: 12))),
              ],
            ),
            SizedBox(height: 16),
          ],
          if (cultivo.patronesSugeridos.isNotEmpty) ...[
            _Subtitulo(cultivo.categoria == CategoriaCultivo.micorricicoTrufa ? SoleraL10n.t('agro.hospederos_habituales_texto') : SoleraL10n.t('agro.patrones_habituales')),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in cultivo.patronesSugeridos)
                  Chip(label: Text(p, style: TextStyle(fontSize: 12))),
              ],
            ),
            SizedBox(height: 16),
          ],
          if (cultivo.hospederosCultivoIds.isNotEmpty) ...[
            _Subtitulo(SoleraL10n.t('agro.arboles_hospederos_catalogados')),
            Text(
              SoleraL10n.t('agro.explicacion_arboles_hospederos'),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final hospederoId in cultivo.hospederosCultivoIds)
                  if (catalogoCultivos.any((c) => c.id == hospederoId))
                    Builder(builder: (context) {
                      final hospedero = catalogoCultivos.firstWhere((c) => c.id == hospederoId);
                      return ActionChip(
                        avatar: Icon(hospedero.icono, color: hospedero.color, size: 18),
                        label: Text(hospedero.nombreVisible, style: TextStyle(fontSize: 12)),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PantallaDetalleCultivo(cultivo: hospedero)),
                        ),
                      );
                    }),
              ],
            ),
            SizedBox(height: 16),
          ],
          if (cultivo.trufasHospedables.isNotEmpty) ...[
            _Subtitulo(SoleraL10n.t('agro.trufas_que_puede_albergar')),
            Text(
              SoleraL10n.t('agro.explicacion_trufas_hospedables'),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final trufaId in cultivo.trufasHospedables)
                  if (catalogoCultivos.any((c) => c.id == trufaId))
                    Builder(builder: (context) {
                      final trufa = catalogoCultivos.firstWhere((c) => c.id == trufaId);
                      return ActionChip(
                        avatar: Icon(trufa.icono, color: trufa.color, size: 18),
                        label: Text(trufa.nombreVisible, style: TextStyle(fontSize: 12)),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PantallaDetalleCultivo(cultivo: trufa)),
                        ),
                      );
                    }),
              ],
            ),
            SizedBox(height: 16),
          ],
          _Subtitulo(SoleraL10n.t('agro.plagas_y_enfermedades')),
          if (plagas.isEmpty)
            Text(
              SoleraL10n.t('agro.sin_plagas_catalogadas_cultivo'),
              style: TextStyle(color: Colors.grey),
            )
          else
            for (final p in plagas)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.tipo.color,
                    child: Icon(p.tipo.icono, color: Colors.white, size: 20),
                  ),
                  title: Text(p.nombreComun),
                  subtitle: Text(
                    [
                      if (p.nombreCientifico.isNotEmpty) p.nombreCientifico,
                      _nombreTipoPlaga(p.tipo),
                    ].join(' · '),
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PantallaDetallePlaga(plaga: p)),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ListaPlagas extends StatefulWidget {
  _ListaPlagas();

  @override
  State<_ListaPlagas> createState() => _ListaPlagasState();
}

class _ListaPlagasState extends State<_ListaPlagas> {
  String? _filtroCultivo;
  TipoPlaga? _filtroTipo;

  @override
  Widget build(BuildContext context) {
    final filtradas = catalogoPlagas.where((p) {
      if (_filtroCultivo != null && !p.cultivoIds.contains(_filtroCultivo)) return false;
      if (_filtroTipo != null && p.tipo != _filtroTipo) return false;
      return true;
    }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _filtroCultivo,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.cultivo'),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text(SoleraL10n.t('todos'))),
                    for (final c in catalogoCultivos)
                      if (c.id != 'generico')
                        DropdownMenuItem<String?>(value: c.id, child: Text(c.nombreVisible)),
                  ],
                  onChanged: (v) => setState(() => _filtroCultivo = v),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<TipoPlaga?>(
                  initialValue: _filtroTipo,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.tipo'),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem<TipoPlaga?>(value: null, child: Text(SoleraL10n.t('todos'))),
                    for (final t in TipoPlaga.values)
                      DropdownMenuItem<TipoPlaga?>(value: t, child: Text(_nombreTipoPlaga(t))),
                  ],
                  onChanged: (v) => setState(() => _filtroTipo = v),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtradas.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      SoleraL10n.t('agro.sin_resultados_filtros'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: filtradas.length,
                  itemBuilder: (_, i) {
                    final p = filtradas[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: p.tipo.color,
                        child: Icon(p.tipo.icono, color: Colors.white, size: 20),
                      ),
                      title: Text(p.nombreComun),
                      subtitle: Text(
                        [
                          if (p.nombreCientifico.isNotEmpty) p.nombreCientifico,
                          _nombreTipoPlaga(p.tipo),
                        ].join(' · '),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                        // Sin esto los nombres científicos largos
                        // (típico en trufas: "Tuber melanosporum Vittad.")
                        // sobresalen del card y rompen la cuadrícula.
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PantallaDetallePlaga(plaga: p)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class PantallaDetallePlaga extends StatelessWidget {
  final Plaga plaga;
  PantallaDetallePlaga({super.key, required this.plaga});

  @override
  Widget build(BuildContext context) {
    final cultivosAfectados = [
      for (final c in catalogoCultivos)
        if (plaga.cultivoIds.contains(c.id)) c,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(plaga.nombreComun),
        backgroundColor: plaga.tipo.color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (plaga.nombreCientifico.isNotEmpty || plaga.nombreComun.isNotEmpty)
            ImagenCommonsWidget(
              tituloWikipedia: _tituloWikipediaParaPlaga(plaga),
              terminoBusqueda: plaga.nombreCientifico.isNotEmpty ? plaga.nombreCientifico : plaga.nombreComun,
              altura: 200,
            ),
          if (plaga.nombreCientifico.isNotEmpty || plaga.nombreComun.isNotEmpty)
            SizedBox(height: 12),
          if (plaga.nombreCientifico.isNotEmpty)
            Text(
              plaga.nombreCientifico,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(plaga.tipo.icono, color: plaga.tipo.color, size: 18),
              SizedBox(width: 4),
              Text(_nombreTipoPlaga(plaga.tipo), style: TextStyle(fontWeight: FontWeight.bold, color: plaga.tipo.color)),
            ],
          ),
          SizedBox(height: 16),
          _Subtitulo(SoleraL10n.t('agro.descripcion')),
          Text(plaga.descripcion),
          SizedBox(height: 16),
          _Subtitulo(SoleraL10n.t('agro.sintomas')),
          Text(plaga.sintomas),
          if (plaga.condicionesFavorables.isNotEmpty) ...[
            SizedBox(height: 16),
            _Subtitulo(SoleraL10n.t('agro.condiciones_favorables')),
            Text(plaga.condicionesFavorables),
          ],
          if (plaga.manejoCultural.isNotEmpty) ...[
            SizedBox(height: 16),
            _Subtitulo(SoleraL10n.t('agro.manejo_cultural')),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              // Color del texto fijo: el fondo es verde claro siempre,
              // así que no debemos heredar el color del tema (en dark
              // mode salía blanco-en-blanco — bug reportado por tester
              // 2026-05-15).
              child: Text(
                plaga.manejoCultural,
                style: TextStyle(color: Colors.green.shade900),
              ),
            ),
            SizedBox(height: 6),
            Text(
              SoleraL10n.t('agro.aviso_recomendaciones_fitosanitarios_futuras'),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
          SizedBox(height: 16),
          _Subtitulo(SoleraL10n.t('agro.cultivos_afectados')),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in cultivosAfectados)
                ActionChip(
                  avatar: Icon(c.icono, color: c.color, size: 16),
                  label: Text(c.nombreVisible, style: TextStyle(fontSize: 12)),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PantallaDetalleCultivo(cultivo: c)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Subtitulo extends StatelessWidget {
  final String texto;
  _Subtitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(texto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

/// Nombre visible traducido del tipo de plaga (el de `TipoPlaga.nombreVisible`
/// del catálogo se queda en castellano).
String _nombreTipoPlaga(TipoPlaga tipo) {
  switch (tipo) {
    case TipoPlaga.plaga:
      return SoleraL10n.t('agro.plaga');
    case TipoPlaga.enfermedad:
      return SoleraL10n.t('agro.enfermedad');
    case TipoPlaga.fisiologico:
      return SoleraL10n.t('agro.trastorno_fisiologico');
    case TipoPlaga.abiotico:
      return SoleraL10n.t('agro.dano_abiotico');
  }
}

/// Nombre visible traducido de la categoría de cultivo.
String _nombreCategoriaCultivo(CategoriaCultivo categoria) {
  switch (categoria) {
    case CategoriaCultivo.micorricicoTrufa:
      return SoleraL10n.t('agro.categoria_truficultura');
    case CategoriaCultivo.forestal:
      return SoleraL10n.t('agro.categoria_forestal_dehesa');
    case CategoriaCultivo.frutalPepita:
      return SoleraL10n.t('agro.categoria_frutal_pepita');
    case CategoriaCultivo.frutalHueso:
      return SoleraL10n.t('agro.categoria_frutal_hueso');
    case CategoriaCultivo.frutoSeco:
      return SoleraL10n.t('agro.categoria_fruto_seco');
    case CategoriaCultivo.oleoso:
      return SoleraL10n.t('agro.categoria_cultivo_oleoso');
    case CategoriaCultivo.vid:
      return SoleraL10n.t('agro.categoria_vid');
    case CategoriaCultivo.otro:
      return SoleraL10n.t('agro.otro');
  }
}

/// Construye el título de Wikipedia para buscar la lead image. Para
/// taxones la convención es nombre científico con guión bajo. Si el
/// cultivo no tiene nombre científico (caso 'generico') devolvemos
/// el nombre visible que rara vez tendrá artículo, lo que hará que
/// el servicio caiga al fallback de búsqueda Commons.
String _tituloWikipediaParaCultivo(Cultivo cultivo) {
  if (cultivo.nombreCientifico.isNotEmpty) {
    return cultivo.nombreCientifico.replaceAll(' ', '_');
  }
  return cultivo.nombreVisible.replaceAll(' ', '_');
}

String _tituloWikipediaParaPlaga(Plaga plaga) {
  if (plaga.nombreCientifico.isNotEmpty) {
    return plaga.nombreCientifico.replaceAll(' ', '_');
  }
  return plaga.nombreComun.replaceAll(' ', '_');
}
