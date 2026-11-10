// Guía del obrador (Hoy → icono de libro; Recetas → «Recetas de la guía»):
// recetas base en porcentaje panadero y fichas de fermentación, tiempos,
// cocción, harinas y trucos, con buscador. Sin fotos en la v1.
//
// HARD LIMIT: orientativo y revisado con IA (aviso fijo arriba y en cada
// ficha). Sin promesas de salud; los alérgenos solo los calcula la app.

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro, separacionCamposSolera;

import '../datos/catalogos_generados/catalogo_guia_fichas.dart';
import '../datos/catalogos_generados/catalogo_guia_recetas.dart';
import '../dominio/comprobacion_denominacion.dart';
import '../dominio/guia_obrador.dart';
import '../dominio/tiempos_guia.dart';
import '../estado/cambios_datos.dart';
import '../servicios/copiar_receta_guia.dart';
import '../utiles/textos_obrador.dart';
import 'pantalla_plan_hornada.dart';
import 'pantalla_recetas.dart';

/// Clave literal por sección: el test de traducciones del core comprueba
/// que cada clave usada existe, y no ve las que se arman con `$`.
String _tituloSeccion(String seccion) => SoleraL10n.t(switch (seccion) {
      'recetas' => 'obra.guia_seccion_recetas',
      'fermentacion' => 'obra.guia_seccion_fermentacion',
      'tiempos' => 'obra.guia_seccion_tiempos',
      'coccion' => 'obra.guia_seccion_coccion',
      'harinas' => 'obra.guia_seccion_harinas',
      _ => 'obra.guia_seccion_trucos',
    });

class PantallaGuiaObrador extends StatefulWidget {
  const PantallaGuiaObrador({super.key, this.seccionInicial = 'recetas'});

  final String seccionInicial;

  @override
  State<PantallaGuiaObrador> createState() => _PantallaGuiaObradorState();
}

class _PantallaGuiaObradorState extends State<PantallaGuiaObrador> {
  final _controladorBusqueda = TextEditingController();
  String _consulta = '';
  late String _seccion = widget.seccionInicial;

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  /// Elementos de una sección; con búsqueda, de todas (con su cabecera).
  List<Widget> _elementos(BuildContext context) {
    final secciones =
        _consulta.trim().isEmpty ? [_seccion] : seccionesGuiaObrador;
    final elementos = <Widget>[];
    for (final seccion in secciones) {
      final filas = <Widget>[
        if (seccion == 'recetas')
          for (final receta in recetasGuiaFiltradas(consulta: _consulta))
            ListTile(
              leading: Icon(receta.esSubreceta
                  ? Icons.layers_outlined
                  : Icons.bakery_dining_outlined),
              title: Text(receta.nombre),
              subtitle: Text('${SoleraL10n.t('obra.guia_hidratacion')}: '
                  '${formatearNumero(receta.hidratacionPorcentaje, decimales: 0)} %'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PantallaRecetaGuia(receta: receta))),
            )
        else
          for (final ficha in fichasGuiaDeSeccion(seccion, consulta: _consulta))
            ListTile(
              leading: Icon(ficha.calculadora.isEmpty
                  ? Icons.article_outlined
                  : Icons.calculate_outlined),
              title: Text(ficha.titulo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PantallaFichaGuiaObrador(ficha: ficha))),
            ),
      ];
      if (filas.isEmpty) continue;
      if (secciones.length > 1) {
        elementos.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(_tituloSeccion(seccion),
              style: Theme.of(context).textTheme.titleSmall),
        ));
      }
      elementos.addAll(filas);
    }
    if (elementos.isEmpty) {
      elementos.add(Padding(
        padding: const EdgeInsets.all(24),
        child: Text(SoleraL10n.t('obra.guia_sin_resultados'),
            textAlign: TextAlign.center),
      ));
    }
    return elementos;
  }

  @override
  Widget build(BuildContext context) {
    final elementos = _elementos(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.guia'))),
      body: Column(
        children: [
          const AvisoGuiaObrador(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: (texto) => setState(() {
                _consulta = texto;
              }),
              decoration: InputDecoration(
                hintText: SoleraL10n.t('obra.guia_buscar'),
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
          if (_consulta.trim().isEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final seccion in seccionesGuiaObrador)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_tituloSeccion(seccion)),
                        selected: seccion == _seccion,
                        onSelected: (_) => setState(() {
                          _seccion = seccion;
                        }),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
              itemCount: elementos.length,
              itemBuilder: (_, indice) => elementos[indice],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso fijo de la guía: orientativo y revisado con IA.
class AvisoGuiaObrador extends StatelessWidget {
  const AvisoGuiaObrador({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esquema.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: esquema.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                SoleraL10n.t('obra.guia_aviso'),
                if (SoleraL10n.idioma != 'es')
                  SoleraL10n.t('obra.guia_contenido_es'),
              ].join(' '),
              style: TextStyle(color: esquema.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _Apartado extends StatelessWidget {
  const _Apartado(this.titulo, this.texto);

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    if (texto.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(texto),
        ],
      ),
    );
  }
}

class _Fuente extends StatelessWidget {
  const _Fuente(this.fuente);

  final String fuente;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text('${SoleraL10n.t('obra.guia_fuente')}: $fuente',
            style: Theme.of(context).textTheme.bodySmall),
      );
}

/// Ficha de una receta base, con «Copiar a mis recetas».
class PantallaRecetaGuia extends StatelessWidget {
  const PantallaRecetaGuia({super.key, required this.receta});

  final RecetaGuia receta;

  Future<void> _copiar(BuildContext context) async {
    final peticion = await showDialog<({bool porHarina, double gramos})>(
        context: context, builder: (_) => const _DialogoCopiarReceta());
    if (peticion == null || !context.mounted) return;
    final copia = await copiarRecetaGuia(
      receta,
      gramosHarina: peticion.porHarina ? peticion.gramos : null,
      gramosMasa: peticion.porHarina ? null : peticion.gramos,
    );
    avisarCambioDatos();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text([
        SoleraL10n.t('obra.guia_copiada'),
        if (copia.ingredientesCreados.isNotEmpty)
          SoleraL10n.tf('obra.guia_ingredientes_creados',
              {'lista': copia.ingredientesCreados.join(', ')}),
      ].join(' ')),
    ));
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaFichaReceta(recetaId: copia.recetaId)));
  }

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    final denominacion = denominacionPorId(receta.denominacion);
    return Scaffold(
      appBar: AppBar(title: Text(receta.nombre)),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 0, 16, 32)),
        children: [
          const AvisoGuiaObrador(),
          if (denominacion != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  '${denominacion.nombre} (RD 308/2019, ${denominacion.articulo})',
                  style: estilo.bodySmall),
            ),
          if (receta.esSubreceta)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child:
                  Text(SoleraL10n.t('obra.guia_base'), style: estilo.bodySmall),
            ),
          const SizedBox(height: 12),
          Text(SoleraL10n.t('obra.guia_ingredientes'),
              style: estilo.titleSmall),
          for (final linea in ingredientesDeRecetaGuia(receta.id))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(linea.nota.isEmpty
                        ? nombreIngredienteBase(linea.ingredienteId)
                        : '${nombreIngredienteBase(linea.ingredienteId)} · ${linea.nota}'),
                  ),
                  Text('${formatearNumero(linea.porcentaje)} %'),
                ],
              ),
            ),
          const Divider(height: 24),
          _Dato(SoleraL10n.t('obra.guia_hidratacion'),
              '${formatearNumero(receta.hidratacionPorcentaje, decimales: 0)} %'),
          _Dato(SoleraL10n.t('obra.guia_temperatura_masa'),
              '${formatearNumero(receta.temperaturaMasaGrados, decimales: 0)} °C'),
          _Dato(SoleraL10n.t('obra.guia_merma'),
              '${formatearNumero(receta.mermaCoccionPorcentaje, decimales: 0)} %'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _copiar(context),
            icon: const Icon(Icons.content_copy_outlined),
            label: Text(SoleraL10n.t('obra.guia_copiar')),
          ),
          if (tiemposRecetasGuia[receta.id] case final plantilla?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PantallaPlanificarHornada(
                            nombre: receta.nombre,
                            plantilla: plantilla,
                            recetaGuiaId: receta.id))),
                icon: const Icon(Icons.schedule),
                label: Text(SoleraL10n.t('obra.plan_planificar')),
              ),
            ),
          _Apartado(SoleraL10n.t('obra.guia_autolisis'), receta.autolisis),
          _Apartado(SoleraL10n.t('obra.guia_amasado'), receta.amasado),
          _Apartado(SoleraL10n.t('obra.guia_primera_fermentacion'),
              receta.primeraFermentacion),
          _Apartado(SoleraL10n.t('obra.guia_formado'), receta.formado),
          _Apartado(SoleraL10n.t('obra.guia_fermentacion_final'),
              receta.fermentacionFinal),
          _Apartado(SoleraL10n.t('obra.guia_coccion'), receta.coccion),
          _Apartado(SoleraL10n.t('obra.guia_senal_hecho'), receta.senalHecho),
          _Apartado(SoleraL10n.t('obra.guia_notas'), receta.notas),
          _Fuente(receta.fuente),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Expanded(child: Text(etiqueta)), Text(valor)]),
      );
}

/// Pide el peso de harina o el de masa total para pasar de % a gramos.
class _DialogoCopiarReceta extends StatefulWidget {
  const _DialogoCopiarReceta();

  @override
  State<_DialogoCopiarReceta> createState() => _DialogoCopiarRecetaState();
}

class _DialogoCopiarRecetaState extends State<_DialogoCopiarReceta> {
  final _gramos = TextEditingController(text: '1000');
  bool _porHarina = true;

  @override
  void dispose() {
    _gramos.dispose();
    super.dispose();
  }

  void _aceptar() {
    final gramos = leerNumero(_gramos.text);
    if (gramos == null || gramos <= 0) return;
    Navigator.pop(context, (porHarina: _porHarina, gramos: gramos));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(SoleraL10n.t('obra.guia_copiar')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SoleraL10n.t('obra.guia_copiar_explicacion')),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                    value: true,
                    label: Text(SoleraL10n.t('obra.guia_copiar_por_harina'))),
                ButtonSegment(
                    value: false,
                    label: Text(SoleraL10n.t('obra.guia_copiar_por_masa'))),
              ],
              selected: {_porHarina},
              onSelectionChanged: (seleccion) => setState(() {
                _porHarina = seleccion.first;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gramos,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: SoleraL10n.t(_porHarina
                    ? 'obra.guia_copiar_por_harina'
                    : 'obra.guia_copiar_por_masa'),
                suffixText: 'g',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _aceptar(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SoleraL10n.t('obra.guia_cancelar'))),
        FilledButton(
            onPressed: _aceptar, child: Text(SoleraL10n.t('obra.guia_copiar'))),
      ],
    );
  }
}

/// Ficha de técnica (fermentación, tiempos, cocción, harinas o trucos).
class PantallaFichaGuiaObrador extends StatelessWidget {
  const PantallaFichaGuiaObrador({super.key, required this.ficha});

  final FichaGuiaObrador ficha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ficha.titulo)),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 0, 16, 32)),
        children: [
          const AvisoGuiaObrador(),
          for (final parrafo in ficha.parrafos)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(parrafo),
            ),
          if (ficha.calculadora == 'temperatura_agua')
            const CalculadoraTemperaturaAgua(),
          _Fuente(ficha.fuente),
        ],
      ),
    );
  }
}

/// Calculadora de la temperatura del agua (ver [temperaturaAguaParaMasa]).
class CalculadoraTemperaturaAgua extends StatefulWidget {
  const CalculadoraTemperaturaAgua({super.key});

  @override
  State<CalculadoraTemperaturaAgua> createState() =>
      _CalculadoraTemperaturaAguaState();
}

class _CalculadoraTemperaturaAguaState
    extends State<CalculadoraTemperaturaAgua> {
  final _objetivo = TextEditingController(text: '24');
  final _harina = TextEditingController();
  final _ambiente = TextEditingController();
  final _friccion = TextEditingController();
  final _prefermento = TextEditingController();

  @override
  void dispose() {
    for (final controlador in [
      _objetivo,
      _harina,
      _ambiente,
      _friccion,
      _prefermento
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Widget _campo(TextEditingController controlador, String clave) => Padding(
        padding: const EdgeInsets.only(top: separacionCamposSolera),
        child: TextField(
          controller: controlador,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          decoration: InputDecoration(
              labelText: SoleraL10n.t(clave),
              border: const OutlineInputBorder(),
              isDense: true),
          onChanged: (_) => setState(() {}),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final objetivo = leerNumero(_objetivo.text);
    final harina = leerNumero(_harina.text);
    final ambiente = leerNumero(_ambiente.text);
    final double? agua = objetivo == null || harina == null || ambiente == null
        ? null
        : temperaturaAguaParaMasa(
            objetivo: objetivo,
            harina: harina,
            ambiente: ambiente,
            friccion: leerNumero(_friccion.text) ?? 0,
            prefermento: leerNumero(_prefermento.text),
          );
    final estilo = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SoleraL10n.t('obra.guia_calc_titulo'),
                style: estilo.titleSmall),
            _campo(_objetivo, 'obra.guia_calc_objetivo'),
            _campo(_harina, 'obra.guia_calc_harina'),
            _campo(_ambiente, 'obra.guia_calc_ambiente'),
            _campo(_friccion, 'obra.guia_calc_friccion'),
            _campo(_prefermento, 'obra.guia_calc_prefermento'),
            const SizedBox(height: 12),
            if (agua == null)
              Text(SoleraL10n.t('obra.guia_calc_falta'))
            else ...[
              Text(
                  SoleraL10n.tf('obra.guia_calc_resultado',
                      {'grados': formatearNumero(agua)}),
                  key: const Key('resultado_temperatura_agua'),
                  style: estilo.titleMedium),
              if (agua < 0 || agua > 60)
                Text(SoleraL10n.t('obra.guia_calc_fuera_rango'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
