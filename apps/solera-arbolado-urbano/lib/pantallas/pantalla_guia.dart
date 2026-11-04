import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_especies_arboreas.dart';
import '../datos/catalogos_generados/catalogo_plagas_urbanas.dart';
import '../datos/catalogos_generados/catalogo_sustratos_alcorque.dart';
import '../datos/catalogos_generados/catalogo_tipos_poda.dart';
import '../datos/catalogos_generados/flag_revision.dart';

/// Guía consultable de los catálogos curados de arbolado urbano. Cuatro
/// tabs: Plagas, Especies, Tipos de poda, Sustratos. Detalle expandible
/// con banners de declaración obligatoria y riesgo sanitario público.
class PantallaGuia extends StatelessWidget {
  const PantallaGuia({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guía'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.bug_report), text: 'Plagas'),
              Tab(icon: Icon(Icons.park), text: 'Especies'),
              Tab(icon: Icon(Icons.content_cut), text: 'Tipos de poda'),
              Tab(icon: Icon(Icons.terrain), text: 'Sustratos'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!catalogosCompletamenteRevisados)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: BannerCoincidenciaCatalogo(
                  coincidencia: CoincidenciaCatalogo.provisional,
                  mensajeProvisional:
                      'Catálogo provisional con fuente pública trazable. Pendiente de la firma del ingeniero técnico forestal asesor.',
                  mensajeValidado: '',
                  mensajeLibre: '',
                ),
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  _TabPlagas(),
                  _TabEspecies(),
                  _TabTiposPoda(),
                  _TabSustratos(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPlagas extends StatefulWidget {
  const _TabPlagas();
  @override
  State<_TabPlagas> createState() => _TabPlagasState();
}

class _TabPlagasState extends State<_TabPlagas> {
  String _consulta = '';
  TipoPlagaUrbana? _filtroTipo;

  List<PlagaUrbana> get _resultados {
    var lista = _consulta.trim().isEmpty
        ? catalogoPlagasUrbanas
        : buscarPlagasUrbanas(_consulta);
    if (_filtroTipo != null) {
      lista = lista.where((p) => p.tipo == _filtroTipo).toList();
    }
    return lista;
  }

  String _etiquetaTipo(TipoPlagaUrbana t) {
    switch (t) {
      case TipoPlagaUrbana.plagaInsecto:
        return 'Insecto';
      case TipoPlagaUrbana.enfermedadFungica:
        return 'Hongo';
      case TipoPlagaUrbana.enfermedadBacteriana:
        return 'Bacteria';
      case TipoPlagaUrbana.plagaInvasora:
        return 'Invasora';
      case TipoPlagaUrbana.trastornoAbiotico:
        return 'Abiótico';
    }
  }

  IconData _iconoTipo(TipoPlagaUrbana t) {
    switch (t) {
      case TipoPlagaUrbana.plagaInsecto:
        return Icons.bug_report;
      case TipoPlagaUrbana.enfermedadFungica:
        return Icons.coronavirus;
      case TipoPlagaUrbana.enfermedadBacteriana:
        return Icons.biotech;
      case TipoPlagaUrbana.plagaInvasora:
        return Icons.warning;
      case TipoPlagaUrbana.trastornoAbiotico:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _resultados;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar procesionaria, picudo, antracnosis…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _consulta = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: _filtroTipo == null,
                onSelected: (_) => setState(() => _filtroTipo = null),
              ),
              for (final t in TipoPlagaUrbana.values)
                FilterChip(
                  label: Text(_etiquetaTipo(t)),
                  selected: _filtroTipo == t,
                  onSelected: (_) => setState(() => _filtroTipo = t),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('Sin coincidencias.'))
              : ListView.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = lista[i];
                    return ExpansionTile(
                      leading: Icon(_iconoTipo(p.tipo)),
                      title: Row(
                        children: [
                          Expanded(child: Text(p.nombreComun)),
                          if (p.declaracionOficial)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.report,
                                  color: Colors.red, size: 18),
                            ),
                          if (p.riesgoSanitarioPublico)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.health_and_safety,
                                  color: Colors.orange, size: 18),
                            ),
                        ],
                      ),
                      subtitle: p.nombreCientifico.isEmpty
                          ? null
                          : Text(
                              p.nombreCientifico,
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.declaracionOficial) ...[
                          const BannerDeclaracionObligatoria(
                            texto:
                                'PLAGA DE DECLARACIÓN OBLIGATORIA al servicio fitosanitario oficial.',
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (p.riesgoSanitarioPublico) ...[
                          const BannerRiesgoSanitarioPublico(),
                          const SizedBox(height: 12),
                        ],
                        if (p.especiesObjetivo.isNotEmpty) ...[
                          _Seccion('Especies objetivo',
                              p.especiesObjetivo.join(', ')),
                          const SizedBox(height: 8),
                        ],
                        if (p.sintomas.isNotEmpty) ...[
                          _Seccion('Síntomas', p.sintomas),
                          const SizedBox(height: 8),
                        ],
                        if (p.ventanaAviso.isNotEmpty) ...[
                          _Seccion('Ventana de aviso', p.ventanaAviso),
                          const SizedBox(height: 8),
                        ],
                        if (p.manejoCultural.isNotEmpty) ...[
                          _Seccion('Manejo cultural', p.manejoCultural),
                          const SizedBox(height: 8),
                        ],
                        if (p.notas.isNotEmpty) _Seccion('Notas', p.notas),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TabEspecies extends StatefulWidget {
  const _TabEspecies();
  @override
  State<_TabEspecies> createState() => _TabEspeciesState();
}

class _TabEspeciesState extends State<_TabEspecies> {
  String _consulta = '';
  FamiliaEspecieArborea? _filtroFamilia;

  List<EspecieArborea> get _resultados {
    var lista = _consulta.trim().isEmpty
        ? catalogoEspeciesArboreas
        : buscarEspecies(_consulta);
    if (_filtroFamilia != null) {
      lista = lista.where((e) => e.familia == _filtroFamilia).toList();
    }
    return lista;
  }

  String _etiquetaFamilia(FamiliaEspecieArborea f) {
    switch (f) {
      case FamiliaEspecieArborea.caducifolio:
        return 'Caducifolio';
      case FamiliaEspecieArborea.perenneCaducifolio:
        return 'Semi-caduco';
      case FamiliaEspecieArborea.perenne:
        return 'Perenne';
      case FamiliaEspecieArborea.palmacea:
        return 'Palmera';
      case FamiliaEspecieArborea.conifera:
        return 'Conífera';
    }
  }

  String _etiquetaTolerancia(ToleranciaPoda t) {
    switch (t) {
      case ToleranciaPoda.alta:
        return 'Alta';
      case ToleranciaPoda.media:
        return 'Media';
      case ToleranciaPoda.baja:
        return 'Baja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _resultados;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar plátano, palmera, jacarandá…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _consulta = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: _filtroFamilia == null,
                onSelected: (_) => setState(() => _filtroFamilia = null),
              ),
              for (final f in FamiliaEspecieArborea.values)
                FilterChip(
                  label: Text(_etiquetaFamilia(f)),
                  selected: _filtroFamilia == f,
                  onSelected: (_) => setState(() => _filtroFamilia = f),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('Sin coincidencias.'))
              : ListView.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = lista[i];
                    return ExpansionTile(
                      leading: const Icon(Icons.park),
                      title: Text(e.nombreCanonico),
                      subtitle: Text(
                        '${e.nombreCientifico} · ${e.alturaMaxMetros.toStringAsFixed(0)} m',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Seccion('Familia', _etiquetaFamilia(e.familia)),
                        const SizedBox(height: 8),
                        _Seccion(
                          'Tolerancia a poda',
                          _etiquetaTolerancia(e.toleranciaPoda),
                        ),
                        if (e.usoUrbanoTipico.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _Seccion('Uso urbano', e.usoUrbanoTipico),
                        ],
                        if (e.notas.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _Seccion('Notas', e.notas),
                        ],
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TabTiposPoda extends StatelessWidget {
  const _TabTiposPoda();

  String _etiquetaIntensidad(IntensidadPoda i) {
    switch (i) {
      case IntensidadPoda.baja:
        return 'Baja';
      case IntensidadPoda.media:
        return 'Media';
      case IntensidadPoda.alta:
        return 'Alta';
      case IntensidadPoda.muyAlta:
        return 'Muy alta';
      case IntensidadPoda.variable:
        return 'Variable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoTiposPoda.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = catalogoTiposPoda[i];
        return ExpansionTile(
          leading: const Icon(Icons.content_cut),
          title: Row(
            children: [
              Expanded(child: Text(t.nombreCanonico)),
              if (t.controvertida)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.warning_amber,
                      color: Colors.amber, size: 18),
                ),
            ],
          ),
          subtitle: Text(
            'Intensidad: ${_etiquetaIntensidad(t.intensidad)} · ${t.epocaRecomendada}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.controvertida) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tipo de poda controvertido, con debate técnico abierto. Justifica la elección por escrito ante una inspección.',
                        style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            _Seccion('Descripción', t.descripcion),
            const SizedBox(height: 8),
            _Seccion('Época recomendada', t.epocaRecomendada),
            if (t.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              _Seccion('Notas', t.notas),
            ],
          ],
        );
      },
    );
  }
}

class _TabSustratos extends StatelessWidget {
  const _TabSustratos();

  String _etiquetaPermeabilidad(PermeabilidadAlcorque p) {
    switch (p) {
      case PermeabilidadAlcorque.alta:
        return 'Alta';
      case PermeabilidadAlcorque.media:
        return 'Media';
      case PermeabilidadAlcorque.baja:
        return 'Baja';
      case PermeabilidadAlcorque.nula:
        return 'Nula';
    }
  }

  String _etiquetaRiego(FacilidadRiego r) {
    switch (r) {
      case FacilidadRiego.directa:
        return 'Riego directo';
      case FacilidadRiego.indirecta:
        return 'Riego indirecto';
      case FacilidadRiego.dificil:
        return 'Riego difícil';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoSustratosAlcorque.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final s = catalogoSustratosAlcorque[i];
        return ExpansionTile(
          leading: const Icon(Icons.terrain),
          title: Text(s.nombreCanonico),
          subtitle: Text(
            'Permeabilidad: ${_etiquetaPermeabilidad(s.permeabilidad)}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion('Facilidad de riego',
                _etiquetaRiego(s.facilidadRiego)),
            if (s.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              _Seccion('Notas', s.notas),
            ],
          ],
        );
      },
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String texto;
  const _Seccion(this.titulo, this.texto);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(texto, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
