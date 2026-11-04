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
          title: Text(SoleraL10n.t('api.guia')),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: const Icon(Icons.coronavirus), text: SoleraL10n.t('api.patologias')),
              Tab(icon: const Icon(Icons.science), text: SoleraL10n.t('api.sustancias_contra_varroa')),
              Tab(icon: const Icon(Icons.hive), text: SoleraL10n.t('api.razas')),
              Tab(icon: const Icon(Icons.dashboard), text: SoleraL10n.t('api.tipos_de_colmena')),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!catalogosCompletamenteRevisados)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: BannerCoincidenciaCatalogo(
                  coincidencia: CoincidenciaCatalogo.provisional,
                  mensajeProvisional: SoleraL10n.t('api.catalogo_provisional_aviso'),
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
        return SoleraL10n.t('api.tipo_plaga_parasito');
      case TipoPlagaApicola.infeccion:
        return SoleraL10n.t('api.tipo_plaga_infeccion');
      case TipoPlagaApicola.plagaFisica:
        return SoleraL10n.t('api.tipo_plaga_fisica');
      case TipoPlagaApicola.depredador:
        return SoleraL10n.t('api.tipo_plaga_depredador');
      case TipoPlagaApicola.abiotico:
        return SoleraL10n.t('api.tipo_plaga_abiotico');
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
            decoration: InputDecoration(
              hintText: SoleraL10n.t('api.buscar_patologias_ejemplo'),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
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
                label: Text(SoleraL10n.t('api.todas')),
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
              ? Center(child: Text(SoleraL10n.t('api.sin_coincidencias')))
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
                          BannerDeclaracionObligatoria(
                            texto: SoleraL10n.t('api.patologia_declaracion_obligatoria_banner'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (p.sintomas.isNotEmpty) ...[
                          _Seccion(SoleraL10n.t('api.sintomas'), p.sintomas),
                          const SizedBox(height: 8),
                        ],
                        if (p.condicionesFavorables.isNotEmpty) ...[
                          _Seccion(SoleraL10n.t('api.condiciones_favorables'),
                              p.condicionesFavorables),
                          const SizedBox(height: 8),
                        ],
                        if (p.manejoCultural.isNotEmpty) ...[
                          _Seccion(SoleraL10n.t('api.manejo_cultural'), p.manejoCultural),
                          const SizedBox(height: 8),
                        ],
                        if (p.notas.isNotEmpty) _Seccion(SoleraL10n.t('api.notas'), p.notas),
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
        return SoleraL10n.t('api.familia_organica');
      case FamiliaSustanciaVarroa.sintetica:
        return SoleraL10n.t('api.familia_sintetica');
      case FamiliaSustanciaVarroa.naturalAceiteEsencial:
        return SoleraL10n.t('api.familia_aceite_esencial');
    }
  }

  String _etiquetaVehiculo(VehiculoSustanciaVarroa v) {
    switch (v) {
      case VehiculoSustanciaVarroa.sublimacion:
        return SoleraL10n.t('api.vehiculo_sublimacion');
      case VehiculoSustanciaVarroa.goteo:
        return SoleraL10n.t('api.vehiculo_goteo');
      case VehiculoSustanciaVarroa.sandwich:
        return SoleraL10n.t('api.vehiculo_sandwich');
      case VehiculoSustanciaVarroa.tiraPolimero:
        return SoleraL10n.t('api.vehiculo_tira_polimero');
      case VehiculoSustanciaVarroa.nebulizacion:
        return SoleraL10n.t('api.vehiculo_nebulizacion');
    }
  }

  String _etiquetaEficacia(EficaciaSustanciaVarroa e) {
    switch (e) {
      case EficaciaSustanciaVarroa.baja:
        return SoleraL10n.t('api.eficacia_baja');
      case EficaciaSustanciaVarroa.media:
        return SoleraL10n.t('api.eficacia_media');
      case EficaciaSustanciaVarroa.alta:
        return SoleraL10n.t('api.eficacia_alta');
      case EficaciaSustanciaVarroa.muyAlta:
        return SoleraL10n.t('api.eficacia_muy_alta');
    }
  }

  String _etiquetaVentana(VentanaAplicacionVarroa v) {
    switch (v) {
      case VentanaAplicacionVarroa.invernada:
        return SoleraL10n.t('api.invernada');
      case VentanaAplicacionVarroa.primavera:
        return SoleraL10n.t('api.primavera');
      case VentanaAplicacionVarroa.otono:
        return SoleraL10n.t('api.otono');
      case VentanaAplicacionVarroa.sinPostura:
        return SoleraL10n.t('api.sin_postura');
      case VentanaAplicacionVarroa.conPostura:
        return SoleraL10n.t('api.con_postura');
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
            '${_etiquetaFamilia(s.familia)} · ${SoleraL10n.tf('api.plazo_dias_abrev', {'n': s.plazoSeguridadDias})}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion(SoleraL10n.t('api.vehiculo'), _etiquetaVehiculo(s.vehiculoPrincipal)),
            const SizedBox(height: 8),
            _Seccion(SoleraL10n.t('api.eficacia_orientativa'), _etiquetaEficacia(s.eficaciaOrientativa)),
            const SizedBox(height: 8),
            _Seccion(SoleraL10n.t('api.ventana_de_aplicacion'), _etiquetaVentana(s.ventanaAplicacion)),
            const SizedBox(height: 8),
            _Seccion(
              SoleraL10n.t('api.autorizada_en_ecologico'),
              s.autorizadaEcologico ? SoleraL10n.t('api.si') : SoleraL10n.t('api.no'),
            ),
            if (s.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              _Seccion(SoleraL10n.t('api.notas'), s.notas),
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
              _Seccion(SoleraL10n.t('api.sinonimias'), r.sinonimias.join(', ')),
              const SizedBox(height: 8),
            ],
            if (r.caracter.isNotEmpty) ...[
              _Seccion(SoleraL10n.t('api.caracter'), r.caracter.join(' · ')),
              const SizedBox(height: 8),
            ],
            if (r.notas.isNotEmpty) _Seccion(SoleraL10n.t('api.notas'), r.notas),
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
        return SoleraL10n.t('api.formato_fija_horizontal');
      case FormatoColmena.verticalAlza:
        return SoleraL10n.t('api.formato_vertical_con_alzas');
      case FormatoColmena.topBar:
        return SoleraL10n.t('api.formato_top_bar');
      case FormatoColmena.tronco:
        return SoleraL10n.t('api.formato_tronco_artesanal');
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
            '${t.numeroCuadrosCamara > 0 ? " · ${SoleraL10n.tf('api.cuadros_n', {'n': t.numeroCuadrosCamara})}" : ""}'
            '${t.apilableAlzas ? " · ${SoleraL10n.t('api.apilable')}" : ""}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion(SoleraL10n.t('api.uso_tradicional'), t.usoTradicional),
            const SizedBox(height: 8),
            if (t.ventajas.isNotEmpty) ...[
              _Seccion(SoleraL10n.t('api.ventajas'), t.ventajas.join(' · ')),
              const SizedBox(height: 8),
            ],
            if (t.desventajas.isNotEmpty) ...[
              _Seccion(SoleraL10n.t('api.desventajas'), t.desventajas.join(' · ')),
              const SizedBox(height: 8),
            ],
            if (t.notas.isNotEmpty) _Seccion(SoleraL10n.t('api.notas'), t.notas),
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
