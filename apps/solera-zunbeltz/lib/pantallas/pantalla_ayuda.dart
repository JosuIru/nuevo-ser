import 'package:flutter/material.dart';

import '../branding.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../servicios/servicio_textos_ayuda.dart';
import 'indice_ayuda.dart';
import 'textos_ayuda_de_serie.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Manual y ayuda dentro de la app (el orden está en `indice_ayuda.dart`), en lenguaje sencillo para personas no
/// familiarizadas con apps. Apartados desplegables agrupados por tema, con
/// buscador.
///
/// El cuerpo de cada apartado viene del ARB como texto con una línea por
/// bloque, marcada así:
/// - `1. …` paso numerado.
/// - `• …` viñeta.
/// - `» …` nota «Bueno saber».
/// - cualquier otra línea, párrafo.
///
/// Algunos apartados tienen una versión para personas tester (claves
/// `<clave>TesterT` / `<clave>TesterB` en el ARB): cuentan lo que su rol
/// puede hacer (consultar, pedir, avisar) en vez de cómo se edita el
/// espacio. Se enseña cuando la sesión es de alguien que no puede editar el
/// espacio; en modo local y para coordinación va la versión general.
class PantallaAyuda extends StatefulWidget {
  const PantallaAyuda({super.key, this.perfilTester});

  /// Fuerza la versión para tester (o la general con `false`). `null` =
  /// según la sesión actual.
  final bool? perfilTester;

  @override
  State<PantallaAyuda> createState() => _PantallaAyudaState();
}

class _ApartadoAyuda {
  const _ApartadoAyuda(this.titulo, this.cuerpo, this.icono);

  final String titulo;
  final String cuerpo;
  final IconData icono;
}

class _GrupoAyuda {
  const _GrupoAyuda(this.titulo, this.apartados);

  final String titulo;
  final List<_ApartadoAyuda> apartados;
}

class _PantallaAyudaState extends State<PantallaAyuda> {
  final _controladorBusqueda = TextEditingController();
  String _textoBuscado = '';

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  bool get _esTester {
    final forzado = widget.perfilTester;
    if (forzado != null) return forzado;
    final politica = politicaEspacioActual;
    return !politica.modoLocal && !politica.puedeEditarEspacio;
  }

  /// Icono de cada apartado, por clave del índice.
  static const Map<String, IconData> _iconos = {
    'ayudaQueEs': Icons.help_outline,
    'ayudaPestanas': Icons.dashboard_outlined,
    'ayudaIdiomaDatos': Icons.translate_outlined,
    'ayudaHoyAvisos': Icons.campaign_outlined,
    'ayudaWidget': Icons.widgets_outlined,
    'ayudaActualizaciones': Icons.system_update,
    'ayudaFincas': Icons.add_location_alt_outlined,
    'ayudaZonas': Icons.pentagon_outlined,
    'ayudaEditarMapa': Icons.edit_location_alt_outlined,
    'ayudaImportar': Icons.layers_outlined,
    'ayudaCierres': Icons.fence,
    'ayudaTareas': Icons.add_task,
    'ayudaRecurrentes': Icons.repeat,
    'ayudaTablero': Icons.checklist,
    'ayudaGanadoLotes': Icons.pets_outlined,
    'ayudaGanadoMover': Icons.moving,
    'ayudaGanadoManejo': Icons.medication_outlined,
    'ayudaProyectos': Icons.science_outlined,
    'ayudaApuntar': Icons.edit_note_outlined,
    'ayudaNumeros': Icons.bar_chart_outlined,
    'ayudaConvenio': Icons.handshake_outlined,
    'ayudaCalculadora': Icons.calculate_outlined,
    'ayudaInformes': Icons.ios_share,
    'ayudaSync': Icons.sync_outlined,
    'ayudaWeb': Icons.computer_outlined,
    'ayudaRoles': Icons.badge_outlined,
    'ayudaPeticiones': Icons.add_comment_outlined,
    'ayudaContactos': Icons.contacts_outlined,
    'ayudaNotificaciones': Icons.notifications_outlined,
    'ayudaProblemas': Icons.build_outlined,
  };

  /// Los grupos y apartados del índice, con el texto de serie o el que
  /// coordinación haya cambiado en el panel ([cambiados]), y la versión
  /// para tester donde la hay y toca.
  List<_GrupoAyuda> _grupos(AppLocalizations t, String idioma,
      Map<String, Map<String, String>> cambiados) {
    final deSerie = textosAyudaDeSerie(t);
    final tester = _esTester;
    String texto(String clave) => textoAyuda(cambiados, idioma, deSerie, clave);
    return [
      for (final entrada in indiceAyuda.entries)
        _GrupoAyuda(texto(entrada.key), [
          for (final clave in entrada.value)
            _ApartadoAyuda(
              texto(tester && apartadosConVersionTester.contains(clave)
                  ? '${clave}TesterT'
                  : '${clave}T'),
              texto(tester && apartadosConVersionTester.contains(clave)
                  ? '${clave}TesterB'
                  : '${clave}B'),
              _iconos[clave] ?? Icons.article_outlined,
            ),
        ]),
    ];
  }

  bool _coincide(_ApartadoAyuda apartado) {
    if (_textoBuscado.isEmpty) return true;
    final busqueda = _sinTildes(_textoBuscado);
    return _sinTildes(apartado.titulo).contains(busqueda) ||
        _sinTildes(apartado.cuerpo).contains(busqueda);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: ServicioTextosAyuda.actuales,
        builder: (contexto, cambiados, _) => _pantalla(contexto, cambiados),
      );

  Widget _pantalla(
      BuildContext context, Map<String, Map<String, String>> cambiados) {
    final t = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final estilos = Theme.of(context).textTheme;
    final buscando = _textoBuscado.isNotEmpty;
    final gruposVisibles = [
      for (final grupo in _grupos(t, idioma, cambiados))
        _GrupoAyuda(grupo.titulo,
            grupo.apartados.where(_coincide).toList(growable: false)),
    ].where((grupo) => grupo.apartados.isNotEmpty).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(t.ayudaTitulo)),
      body: CuerpoResponsivo(
        maxAncho: 640,
        child: ListView(
          padding: rellenoSobreBarraSistema(
              context, const EdgeInsets.fromLTRB(12, 8, 12, 24)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Text(
                  textoAyuda(
                      cambiados, idioma, textosAyudaDeSerie(t), 'ayudaIntro'),
                  style: estilos.bodyLarge),
            ),
            if (_esTester)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                    textoAyuda(cambiados, idioma, textosAyudaDeSerie(t),
                        'ayudaPerfilTester'),
                    style: estilos.bodySmall
                        ?.copyWith(color: colorTintaApagadaZunbeltz)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _controladorBusqueda,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: t.ayudaBuscar,
                  suffixIcon: buscando
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controladorBusqueda.clear();
                            setState(() => _textoBuscado = '');
                          },
                        )
                      : null,
                ),
                onChanged: (valor) =>
                    setState(() => _textoBuscado = valor.trim()),
              ),
            ),
            if (gruposVisibles.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.ayudaSinResultados, style: estilos.bodyMedium),
              ),
            for (final grupo in gruposVisibles) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 6),
                child: Text(grupo.titulo, style: estilos.titleMedium),
              ),
              for (final apartado in grupo.apartados)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    // Al buscar, la clave cambia para que se abran solos los
                    // apartados que coinciden.
                    key: ValueKey('${apartado.titulo}|$buscando'),
                    initiallyExpanded: buscando,
                    leading: Icon(apartado.icono),
                    title: Text(apartado.titulo,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CuerpoApartado(
                          cuerpo: apartado.cuerpo,
                          etiquetaNota: textoAyuda(cambiados, idioma,
                              textosAyudaDeSerie(t), 'ayudaConsejo')),
                    ],
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
              child: Text(
                  textoAyuda(
                      cambiados, idioma, textosAyudaDeSerie(t), 'ayudaPie'),
                  style: estilos.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinta el cuerpo de un apartado según las marcas de cada línea (ver
/// [PantallaAyuda]).
class _CuerpoApartado extends StatelessWidget {
  const _CuerpoApartado({required this.cuerpo, required this.etiquetaNota});

  final String cuerpo;
  final String etiquetaNota;

  static final _patronPaso = RegExp(r'^(\d+)\.\s+(.*)$');

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    final bloques = <Widget>[];
    for (final linea in cuerpo.split('\n')) {
      final texto = linea.trim();
      if (texto.isEmpty) continue;
      final paso = _patronPaso.firstMatch(texto);
      if (paso != null) {
        bloques.add(_Paso(numero: paso.group(1)!, texto: paso.group(2)!));
      } else if (texto.startsWith('•')) {
        bloques.add(_Vineta(texto: texto.substring(1).trim()));
      } else if (texto.startsWith('»')) {
        bloques.add(
            _Nota(etiqueta: etiquetaNota, texto: texto.substring(1).trim()));
      } else {
        bloques.add(Text(texto, style: estilos.bodyMedium));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final bloque in bloques)
          Padding(padding: const EdgeInsets.only(top: 8), child: bloque),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.numero, required this.texto});

  final String numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 10, top: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorMonteZunbeltz,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            numero,
            style: const TextStyle(
              color: colorPapelZunbeltz,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _Vineta extends StatelessWidget {
  const _Vineta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 9, right: 19, top: 9),
          color: colorPastoZunbeltz,
        ),
        Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _Nota extends StatelessWidget {
  const _Nota({required this.etiqueta, required this.texto});

  final String etiqueta;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: colorPapelHundidoZunbeltz,
        border: Border(left: BorderSide(color: colorSenalZunbeltz, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta,
              style: estilos.labelMedium?.copyWith(
                  color: colorSenalZunbeltz, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(texto, style: estilos.bodyMedium),
        ],
      ),
    );
  }
}

/// Minúsculas y sin tildes, para que «dia» encuentre «día» al buscar.
String _sinTildes(String texto) {
  const conTilde = 'áéíóúüñ';
  const sinTilde = 'aeiouun';
  final minusculas = texto.toLowerCase();
  final resultado = StringBuffer();
  for (final caracter in minusculas.split('')) {
    final posicion = conTilde.indexOf(caracter);
    resultado.write(posicion == -1 ? caracter : sinTilde[posicion]);
  }
  return resultado.toString();
}
