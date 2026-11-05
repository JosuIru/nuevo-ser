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
  const _GrupoAyuda(this.clave, this.titulo, this.apartados);

  /// Clave del grupo en el índice (da el color de los iconos).
  final String clave;
  final String titulo;
  final List<_ApartadoAyuda> apartados;
}

/// Fondo y tinta del cuadro del icono según el grupo: los cuadros del
/// logotipo para fincas, ganado y proyectos; neutro el resto.
(Color, Color) _coloresGrupo(BuildContext context, String grupo) {
  final esquema = context.esquemaZunbeltz;
  return switch (grupo) {
    'ayudaGrupoFincas' => (colorCuadroEsmeralda, colorSobreCuadroClaro),
    'ayudaGrupoGanado' => (colorCuadroSalvia, colorSobreCuadroClaro),
    'ayudaGrupoProyectos' => (colorCuadroPino, Colors.white),
    _ => (esquema.surfaceContainerHighest, esquema.onSurfaceVariant),
  };
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
    'ayudaMapaSinCobertura': Icons.signal_wifi_off_outlined,
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
        _GrupoAyuda(entrada.key, texto(entrada.key), [
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
        _GrupoAyuda(grupo.clave, grupo.titulo,
            grupo.apartados.where(_coincide).toList(growable: false)),
    ].where((grupo) => grupo.apartados.isNotEmpty).toList(growable: false);

    final esquema = context.esquemaZunbeltz;
    final etiquetaNota =
        textoAyuda(cambiados, idioma, textosAyudaDeSerie(t), 'ayudaConsejo');
    void abrir(_ApartadoAyuda apartado) =>
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: CuerpoResponsivo(
              maxAncho: 640,
              child: ListView(
                padding: rellenoSobreBarraSistema(
                    context, const EdgeInsets.fromLTRB(20, 0, 20, 24)),
                children: [
                  Text(apartado.titulo, style: estilos.headlineSmall),
                  const SizedBox(height: 8),
                  _CuerpoApartado(
                      cuerpo: apartado.cuerpo, etiquetaNota: etiquetaNota),
                ],
              ),
            ),
          ),
        ));

    Widget fila(_GrupoAyuda grupo, _ApartadoAyuda apartado) {
      final (fondo, tinta) = _coloresGrupo(context, grupo.clave);
      return ListTile(
        key: ValueKey('ayuda|${apartado.titulo}'),
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Icon(apartado.icono, color: tinta),
        ),
        title: Text(apartado.titulo, style: estilos.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => abrir(apartado),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.ayudaTitulo)),
      body: CuerpoResponsivo(
        maxAncho: 640,
        child: ListView(
          padding: rellenoSobreBarraSistema(
              context, const EdgeInsets.fromLTRB(16, 8, 16, 24)),
          children: [
            TextField(
              controller: _controladorBusqueda,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: esquema.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
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
            if (_esTester)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: esquema.secondaryContainer,
                  borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
                ),
                child: Row(children: [
                  Icon(Icons.badge_outlined,
                      color: esquema.onSecondaryContainer),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                        textoAyuda(cambiados, idioma, textosAyudaDeSerie(t),
                            'ayudaPerfilTester'),
                        style: estilos.bodyMedium
                            ?.copyWith(color: esquema.onSecondaryContainer)),
                  ),
                ]),
              ),
            if (!buscando)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                child: Text(
                    textoAyuda(
                        cambiados, idioma, textosAyudaDeSerie(t), 'ayudaIntro'),
                    style: estilos.bodyMedium
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              ),
            if (gruposVisibles.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.ayudaSinResultados, style: estilos.bodyMedium),
              ),
            for (final grupo in gruposVisibles) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
                child: Text(grupo.titulo,
                    style: estilos.titleSmall?.copyWith(
                        color: esquema.primary, fontWeight: FontWeight.w600)),
              ),
              if (buscando)
                // Al buscar, cada apartado que coincide sale abierto.
                for (final apartado in grupo.apartados)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ExpansionTile(
                      key: ValueKey('${apartado.titulo}|$buscando'),
                      initiallyExpanded: true,
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
                            etiquetaNota: etiquetaNota),
                      ],
                    ),
                  )
              else
                Container(
                  decoration: BoxDecoration(
                    color: esquema.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (var indice = 0;
                        indice < grupo.apartados.length;
                        indice++) ...[
                      if (indice > 0)
                        Divider(
                            height: 1,
                            indent: 80,
                            endIndent: 16,
                            color: esquema.outlineVariant),
                      fila(grupo, grupo.apartados[indice]),
                    ],
                  ]),
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 24, 4, 0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.forum_outlined,
                    size: 20, color: esquema.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      textoAyuda(
                          cambiados, idioma, textosAyudaDeSerie(t), 'ayudaPie'),
                      style: estilos.bodyMedium
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ),
              ]),
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
            color: context.esquemaZunbeltz.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            numero,
            style: TextStyle(
              color: context.esquemaZunbeltz.onPrimary,
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
          color: context.coloresZunbeltz.hecha,
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
      decoration: BoxDecoration(
        color: context.esquemaZunbeltz.surfaceContainer,
        border: Border(
            left:
                BorderSide(color: context.coloresZunbeltz.bloqueada, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta,
              style: estilos.labelMedium?.copyWith(
                  color: context.coloresZunbeltz.bloqueada,
                  fontWeight: FontWeight.w700)),
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
