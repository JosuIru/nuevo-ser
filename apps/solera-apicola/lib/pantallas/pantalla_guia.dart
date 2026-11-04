import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_plagas_apicolas.dart';
import '../datos/catalogos_generados/catalogo_razas_abeja.dart';
import '../datos/catalogos_generados/catalogo_sustancias_varroa.dart';
import '../datos/catalogos_generados/catalogo_tipos_colmena.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import 'widgets/imagen_commons_widget.dart';
import 'widgets/miniatura_commons.dart';

/// Guía consultable de los catálogos curados de apicultura. Cuatro tabs:
/// Patologías, Sustancias varroa, Razas y Tipos de colmena. Detalle
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
              Tab(icon: Icon(Icons.coronavirus), text: 'Patologías'),
              Tab(icon: Icon(Icons.science), text: 'Sustancias contra varroa'),
              Tab(icon: Icon(Icons.hive), text: 'Razas'),
              Tab(icon: Icon(Icons.dashboard), text: 'Tipos de colmena'),
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
                      'Catálogo provisional con fuente pública trazable. Pendiente de la firma del veterinario apícola asesor.',
                  mensajeValidado: '',
                  mensajeLibre: '',
                ),
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  _TabPatologias(),
                  _TabSustanciasVarroa(),
                  _TabRazas(),
                  _TabTiposColmena(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPatologias extends StatefulWidget {
  const _TabPatologias();
  @override
  State<_TabPatologias> createState() => _TabPatologiasState();
}

class _TabPatologiasState extends State<_TabPatologias> {
  String _consulta = '';
  TipoPlagaApicola? _filtroTipo;

  List<PlagaApicola> get _resultados {
    var lista = _consulta.trim().isEmpty
        ? catalogoPlagasApicolas
        : buscarPlagasApicolas(_consulta);
    if (_filtroTipo != null) {
      lista = lista.where((p) => p.tipo == _filtroTipo).toList();
    }
    return lista;
  }

  String _etiquetaTipo(TipoPlagaApicola t) {
    switch (t) {
      case TipoPlagaApicola.parasito:
        return 'Parásito';
      case TipoPlagaApicola.infeccion:
        return 'Infección';
      case TipoPlagaApicola.plagaFisica:
        return 'Plaga física';
      case TipoPlagaApicola.depredador:
        return 'Depredador';
      case TipoPlagaApicola.abiotico:
        return 'Abiótico';
    }
  }

  IconData _iconoTipo(TipoPlagaApicola t) {
    switch (t) {
      case TipoPlagaApicola.parasito:
        return Icons.bug_report;
      case TipoPlagaApicola.infeccion:
        return Icons.coronavirus;
      case TipoPlagaApicola.plagaFisica:
        return Icons.pest_control;
      case TipoPlagaApicola.depredador:
        return Icons.flutter_dash;
      case TipoPlagaApicola.abiotico:
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
              hintText: 'Buscar varroa, loque, vespa velutina…',
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
              for (final t in TipoPlagaApicola.values)
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
                          const BannerDeclaracionObligatoria(
                            texto:
                                'PATOLOGÍA DE DECLARACIÓN OBLIGATORIA. Notifícala a los servicios veterinarios oficiales de tu comunidad autónoma.',
                          ),
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

class _TabSustanciasVarroa extends StatelessWidget {
  const _TabSustanciasVarroa();

  String _etiquetaFamilia(FamiliaSustanciaVarroa f) {
    switch (f) {
      case FamiliaSustanciaVarroa.organica:
        return 'Orgánica';
      case FamiliaSustanciaVarroa.sintetica:
        return 'Sintética';
      case FamiliaSustanciaVarroa.naturalAceiteEsencial:
        return 'Aceite esencial';
    }
  }

  String _etiquetaVehiculo(VehiculoSustanciaVarroa v) {
    switch (v) {
      case VehiculoSustanciaVarroa.sublimacion:
        return 'Sublimación';
      case VehiculoSustanciaVarroa.goteo:
        return 'Goteo';
      case VehiculoSustanciaVarroa.sandwich:
        return 'Sandwich';
      case VehiculoSustanciaVarroa.tiraPolimero:
        return 'Tira de polímero';
      case VehiculoSustanciaVarroa.nebulizacion:
        return 'Nebulización';
    }
  }

  String _etiquetaEficacia(EficaciaSustanciaVarroa e) {
    switch (e) {
      case EficaciaSustanciaVarroa.baja:
        return 'Baja';
      case EficaciaSustanciaVarroa.media:
        return 'Media';
      case EficaciaSustanciaVarroa.alta:
        return 'Alta';
      case EficaciaSustanciaVarroa.muyAlta:
        return 'Muy alta';
    }
  }

  String _etiquetaVentana(VentanaAplicacionVarroa v) {
    switch (v) {
      case VentanaAplicacionVarroa.invernada:
        return 'Invernada';
      case VentanaAplicacionVarroa.primavera:
        return 'Primavera';
      case VentanaAplicacionVarroa.otono:
        return 'Otoño';
      case VentanaAplicacionVarroa.sinPostura:
        return 'Sin postura';
      case VentanaAplicacionVarroa.conPostura:
        return 'Con postura';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoSustanciasVarroa.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final s = catalogoSustanciasVarroa[i];
        return ExpansionTile(
          leading: const Icon(Icons.science),
          title: Row(
            children: [
              Expanded(child: Text(s.nombreCanonico)),
              if (s.autorizadaEcologico)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.eco, color: Colors.green, size: 18),
                ),
            ],
          ),
          subtitle: Text(
            '${_etiquetaFamilia(s.familia)} · Plazo: ${s.plazoSeguridadDias} d',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion('Vehículo', _etiquetaVehiculo(s.vehiculoPrincipal)),
            const SizedBox(height: 8),
            _Seccion('Eficacia orientativa', _etiquetaEficacia(s.eficaciaOrientativa)),
            const SizedBox(height: 8),
            _Seccion('Ventana de aplicación', _etiquetaVentana(s.ventanaAplicacion)),
            const SizedBox(height: 8),
            _Seccion(
              'Autorizada en ecológico',
              s.autorizadaEcologico ? 'Sí' : 'No',
            ),
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

class _TabRazas extends StatelessWidget {
  const _TabRazas();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoRazasAbeja.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = catalogoRazasAbeja[i];
        return ExpansionTile(
          leading: const Icon(Icons.hive),
          title: Text(r.nombreCanonico),
          subtitle: r.subespecie.isEmpty
              ? Text(r.origenGeografico)
              : Text(
                  '${r.subespecie} · ${r.origenGeografico}',
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.sinonimias.isNotEmpty) ...[
              _Seccion('Sinonimias', r.sinonimias.join(', ')),
              const SizedBox(height: 8),
            ],
            if (r.caracter.isNotEmpty) ...[
              _Seccion('Carácter', r.caracter.join(' · ')),
              const SizedBox(height: 8),
            ],
            if (r.notas.isNotEmpty) _Seccion('Notas', r.notas),
          ],
        );
      },
    );
  }
}

class _TabTiposColmena extends StatelessWidget {
  const _TabTiposColmena();

  String _etiquetaFormato(FormatoColmena f) {
    switch (f) {
      case FormatoColmena.fijaHorizontal:
        return 'Fija horizontal';
      case FormatoColmena.verticalAlza:
        return 'Vertical con alzas';
      case FormatoColmena.topBar:
        return 'Top-bar';
      case FormatoColmena.tronco:
        return 'Tronco artesanal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: catalogoTiposColmena.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = catalogoTiposColmena[i];
        return ExpansionTile(
          leading: const Icon(Icons.dashboard),
          title: Text(t.nombreCanonico),
          subtitle: Text(
            '${_etiquetaFormato(t.formato)}'
            '${t.numeroCuadrosCamara > 0 ? " · ${t.numeroCuadrosCamara} cuadros" : ""}'
            '${t.apilableAlzas ? " · apilable" : ""}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion('Uso tradicional', t.usoTradicional),
            const SizedBox(height: 8),
            if (t.ventajas.isNotEmpty) ...[
              _Seccion('Ventajas', t.ventajas.join(' · ')),
              const SizedBox(height: 8),
            ],
            if (t.desventajas.isNotEmpty) ...[
              _Seccion('Desventajas', t.desventajas.join(' · ')),
              const SizedBox(height: 8),
            ],
            if (t.notas.isNotEmpty) _Seccion('Notas', t.notas),
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
