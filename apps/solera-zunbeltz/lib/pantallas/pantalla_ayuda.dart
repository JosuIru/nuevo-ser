import 'package:flutter/material.dart';

import '../branding.dart';
import '../l10n/app_localizations.dart';
import 'widgets/cuerpo_responsivo.dart';

/// Manual y ayuda dentro de la app, en lenguaje sencillo para personas no
/// familiarizadas con apps. Apartados desplegables agrupados por tema, con
/// buscador.
///
/// El cuerpo de cada apartado viene del ARB como texto con una línea por
/// bloque, marcada así:
/// - `1. …` paso numerado.
/// - `• …` viñeta.
/// - `» …` nota «Bueno saber».
/// - cualquier otra línea, párrafo.
class PantallaAyuda extends StatefulWidget {
  const PantallaAyuda({super.key});

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

  List<_GrupoAyuda> _grupos(AppLocalizations t) => [
        _GrupoAyuda(t.ayudaGrupoEmpezar, [
          _ApartadoAyuda(t.ayudaQueEsT, t.ayudaQueEsB, Icons.help_outline),
          _ApartadoAyuda(
              t.ayudaPestanasT, t.ayudaPestanasB, Icons.dashboard_outlined),
          _ApartadoAyuda(t.ayudaIdiomaDatosT, t.ayudaIdiomaDatosB,
              Icons.translate_outlined),
        ]),
        _GrupoAyuda(t.ayudaGrupoFincas, [
          _ApartadoAyuda(
              t.ayudaFincasT, t.ayudaFincasB, Icons.add_location_alt_outlined),
          _ApartadoAyuda(t.ayudaZonasT, t.ayudaZonasB, Icons.pentagon_outlined),
          _ApartadoAyuda(t.ayudaEditarMapaT, t.ayudaEditarMapaB,
              Icons.edit_location_alt_outlined),
          _ApartadoAyuda(t.ayudaTareasT, t.ayudaTareasB, Icons.add_task),
          _ApartadoAyuda(
              t.ayudaRecurrentesT, t.ayudaRecurrentesB, Icons.repeat),
          _ApartadoAyuda(t.ayudaTableroT, t.ayudaTableroB, Icons.checklist),
        ]),
        _GrupoAyuda(t.ayudaGrupoProyectos, [
          _ApartadoAyuda(
              t.ayudaProyectosT, t.ayudaProyectosB, Icons.science_outlined),
          _ApartadoAyuda(
              t.ayudaApuntarT, t.ayudaApuntarB, Icons.edit_note_outlined),
          _ApartadoAyuda(
              t.ayudaNumerosT, t.ayudaNumerosB, Icons.bar_chart_outlined),
          _ApartadoAyuda(t.ayudaInformesT, t.ayudaInformesB, Icons.ios_share),
        ]),
        _GrupoAyuda(t.ayudaGrupoEquipo, [
          _ApartadoAyuda(t.ayudaSyncT, t.ayudaSyncB, Icons.sync_outlined),
          _ApartadoAyuda(t.ayudaRolesT, t.ayudaRolesB, Icons.badge_outlined),
        ]),
        _GrupoAyuda(t.ayudaGrupoProblemas, [
          _ApartadoAyuda(
              t.ayudaProblemasT, t.ayudaProblemasB, Icons.build_outlined),
        ]),
      ];

  bool _coincide(_ApartadoAyuda apartado) {
    if (_textoBuscado.isEmpty) return true;
    final busqueda = _sinTildes(_textoBuscado);
    return _sinTildes(apartado.titulo).contains(busqueda) ||
        _sinTildes(apartado.cuerpo).contains(busqueda);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    final buscando = _textoBuscado.isNotEmpty;
    final gruposVisibles = [
      for (final grupo in _grupos(t))
        _GrupoAyuda(grupo.titulo,
            grupo.apartados.where(_coincide).toList(growable: false)),
    ].where((grupo) => grupo.apartados.isNotEmpty).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(t.ayudaTitulo)),
      body: CuerpoResponsivo(
        maxAncho: 640,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Text(t.ayudaIntro, style: estilos.bodyLarge),
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
                          etiquetaNota: t.ayudaConsejo),
                    ],
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
              child: Text(t.ayudaPie, style: estilos.bodySmall),
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
        bloques.add(_Nota(
            etiqueta: etiquetaNota, texto: texto.substring(1).trim()));
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
