import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_materias_activas.dart';
import '../datos/catalogos_generados/catalogo_plagas_vid.dart';
import '../datos/catalogos_generados/catalogo_portainjertos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import 'widgets/imagen_commons_widget.dart';
import 'widgets/miniatura_commons.dart';

/// Guía consultable de los catálogos curados de viticultura. Cuatro
/// tabs: Variedades, Portainjertos, Plagas y Materias activas. Detalle
/// expandible con banners de declaración obligatoria si aplica.
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
              Tab(icon: Icon(Icons.local_florist), text: 'Variedades'),
              Tab(icon: Icon(Icons.account_tree), text: 'Portainjertos'),
              Tab(icon: Icon(Icons.bug_report), text: 'Plagas'),
              Tab(icon: Icon(Icons.science), text: 'Materias activas'),
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
                      'Catálogo provisional con fuente pública trazable. Pendiente de la firma del enólogo y del agrónomo asesores.',
                  mensajeValidado: '',
                  mensajeLibre: '',
                ),
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  _TabVariedades(),
                  _TabPortainjertos(),
                  _TabPlagas(),
                  _TabMateriasActivas(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabVariedades extends StatefulWidget {
  const _TabVariedades();
  @override
  State<_TabVariedades> createState() => _TabVariedadesState();
}

class _TabVariedadesState extends State<_TabVariedades> {
  String _consulta = '';
  ColorVariedad? _filtroColor;

  List<Variedad> get _resultados {
    var lista = _consulta.trim().isEmpty
        ? catalogoVariedades
        : buscarVariedades(_consulta);
    if (_filtroColor != null) {
      lista = lista.where((v) => v.color == _filtroColor).toList();
    }
    return lista;
  }

  String _etiquetaColor(ColorVariedad c) {
    switch (c) {
      case ColorVariedad.tinta:
        return 'Tinta';
      case ColorVariedad.blanca:
        return 'Blanca';
      case ColorVariedad.rosada:
        return 'Rosada';
    }
  }

  Color _colorChip(ColorVariedad c) {
    switch (c) {
      case ColorVariedad.tinta:
        return const Color(0xFF7A1F2D);
      case ColorVariedad.blanca:
        return const Color(0xFFE5C56C);
      case ColorVariedad.rosada:
        return const Color(0xFFE89999);
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
              hintText: 'Buscar tempranillo, albariño…',
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
                selected: _filtroColor == null,
                onSelected: (_) => setState(() => _filtroColor = null),
              ),
              for (final c in ColorVariedad.values)
                FilterChip(
                  label: Text(_etiquetaColor(c)),
                  selected: _filtroColor == c,
                  selectedColor: _colorChip(c).withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _filtroColor = c),
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
                    final v = lista[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorChip(v.color),
                        radius: 12,
                      ),
                      title: Text(v.nombreCanonico),
                      subtitle: v.sinonimias.isEmpty
                          ? null
                          : Text('Sinonimias: ${v.sinonimias.join(", ")}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TabPortainjertos extends StatelessWidget {
  const _TabPortainjertos();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoPortainjertos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final p = catalogoPortainjertos[i];
        final caliza = p.toleranciaCalizaActivaPorcentaje;
        return ExpansionTile(
          leading: const Icon(Icons.account_tree),
          title: Text(p.nombreCanonico),
          subtitle: Text(
            'Vigor: ${p.vigor}'
            '${caliza == null ? "" : " · Caliza activa: $caliza %"}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion('Resistencia a sequía', p.resistenciaSequia),
            if (p.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              _Seccion('Notas', p.notas),
            ],
          ],
        );
      },
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
  TipoPlagaVid? _filtroTipo;

  List<PlagaVid> get _resultados {
    var lista = _consulta.trim().isEmpty
        ? catalogoPlagasVid
        : buscarPlagasVid(_consulta);
    if (_filtroTipo != null) {
      lista = lista.where((p) => p.tipo == _filtroTipo).toList();
    }
    return lista;
  }

  String _etiquetaTipo(TipoPlagaVid t) {
    switch (t) {
      case TipoPlagaVid.plaga:
        return 'Plaga';
      case TipoPlagaVid.enfermedad:
        return 'Enfermedad';
      case TipoPlagaVid.fisiologico:
        return 'Fisiológico';
      case TipoPlagaVid.abiotico:
        return 'Abiótico';
    }
  }

  IconData _iconoTipo(TipoPlagaVid t) {
    switch (t) {
      case TipoPlagaVid.plaga:
        return Icons.bug_report;
      case TipoPlagaVid.enfermedad:
        return Icons.coronavirus;
      case TipoPlagaVid.fisiologico:
        return Icons.eco;
      case TipoPlagaVid.abiotico:
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
              hintText: 'Buscar mildiu, oídio, Xylella…',
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
              for (final t in TipoPlagaVid.values)
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
                      leading: MiniaturaCommons(
                        tituloWikipedia: p.nombreCientifico,
                        terminoBusqueda: p.nombreCientifico,
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(p.nombreComun)),
                          if (p.declaracionOficial)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.report,
                                  color: Colors.red, size: 18),
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
                        if (p.nombreCientifico.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ImagenCommonsWidget(
                                tituloWikipedia: p.nombreCientifico,
                                terminoBusqueda: p.nombreCientifico,
                                altura: 200,
                              ),
                            ),
                          ),
                        if (p.declaracionOficial) ...[
                          const BannerDeclaracionObligatoria(),
                          const SizedBox(height: 12),
                        ],
                        if (p.sintomas.isNotEmpty) ...[
                          _Seccion('Síntomas', p.sintomas),
                          const SizedBox(height: 8),
                        ],
                        if (p.condicionesFavorables.isNotEmpty) ...[
                          _Seccion('Condiciones favorables',
                              p.condicionesFavorables),
                          const SizedBox(height: 8),
                        ],
                        if (p.manejoCultural.isNotEmpty)
                          _Seccion('Manejo cultural', p.manejoCultural),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TabMateriasActivas extends StatelessWidget {
  const _TabMateriasActivas();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoMateriasActivas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final m = catalogoMateriasActivas[i];
        return ExpansionTile(
          leading: const Icon(Icons.science),
          title: Row(
            children: [
              Expanded(child: Text(m.nombreCanonico)),
              if (m.autorizadaEcologico)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.eco, color: Colors.green, size: 18),
                ),
            ],
          ),
          subtitle: Text(
            'Plazo de seguridad: ${m.plazoSeguridadOrientativoDias} días · ${m.tipoAccion}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.plagasObjetivo.isNotEmpty) ...[
              _Seccion('Plagas/enfermedades objetivo',
                  m.plagasObjetivo.join(', ')),
              const SizedBox(height: 8),
            ],
            _Seccion('Tipo de acción', m.tipoAccion),
            const SizedBox(height: 8),
            _Seccion(
              'Autorizada en ecológico',
              m.autorizadaEcologico ? 'Sí' : 'No',
            ),
            if (m.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              _Seccion('Notas', m.notas),
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
