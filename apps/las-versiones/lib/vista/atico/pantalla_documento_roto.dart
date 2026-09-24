import 'package:flutter/material.dart';

import '../../dominio/atico/partida_documento_roto.dart';
import '../../dominio/atico/voz_andres_atico.dart';
import '../../dominio/capa_historica.dart';
import '../../nucleo/paleta_archivo.dart';
import '../../nucleo/pigmentos.dart';
import '../../sonido/catalogo_sonidos_archivo.dart';
import '../../sonido/servicio_sonoro_archivo.dart';
import '../pintura/trazo_a_mano.dart';
import 'objetos_atico.dart';

/// El documento roto (doc del ático §2). Documentos sobre la mesa de
/// luz y, abajo, las tiras de catalogación que la humedad despegó. Se
/// arrastra una tira a su documento (o se toca la tira y luego el
/// documento). Si no encaja, vuelve a la mesa y Andrés da el criterio,
/// no la respuesta.
class PantallaDocumentoRoto extends StatefulWidget {
  const PantallaDocumentoRoto({super.key, required this.partida});

  final PartidaDocumentoRoto partida;

  @override
  State<PantallaDocumentoRoto> createState() => _EstadoPantallaDocumentoRoto();
}

class _EstadoPantallaDocumentoRoto extends State<PantallaDocumentoRoto> {
  Tira? _tiraElegida;
  String? _pista;
  bool _terminada = false;

  PartidaDocumentoRoto get _partida => widget.partida;

  void _elegir(Tira tira) {
    ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.papelTomar);
    setState(() => _tiraElegida = identical(_tiraElegida, tira) ? null : tira);
  }

  void _colocar(Tira tira, DocumentoEnMesa documento) {
    final encaja = _partida.colocar(tira, documento);
    ServicioSonoroArchivo.instancia.reproducirEfecto(
        encaja ? CatalogoSonidosArchivo.pinzaMadera : CatalogoSonidosArchivo.papelDejar);
    setState(() {
      _tiraElegida = null;
      _pista = encaja ? null : VozAndresAtico.pistaNoEncaja(tira.tipo);
    });
  }

  void _avanzar() {
    if (_partida.siguienteRonda()) {
      ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.cajaAbrir);
      setState(() => _pista = null);
      return;
    }
    final capa = _capaMasPresente();
    if (capa != null) {
      ServicioSonoroArchivo.instancia.reproducirFragmentoDeCapa(capa.codigo);
    }
    setState(() => _terminada = true);
  }

  CapaHistorica? _capaMasPresente() {
    final usos = <CapaHistorica, int>{};
    for (final ronda in _partida.rondas) {
      for (final documento in ronda.documentos) {
        final capa = capaPrincipalDeBrecha[documento.brecha.id];
        if (capa != null) usos[capa] = (usos[capa] ?? 0) + 1;
      }
    }
    if (usos.isEmpty) return null;
    return usos.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  @override
  void dispose() {
    ServicioSonoroArchivo.instancia.detenerFragmento();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaArchivo.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaArchivo.fondoProfundo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: PaletaArchivo.textoPrincipal,
          tooltip: 'Volver al ático',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'EL DOCUMENTO ROTO',
          style: TextStyle(fontSize: 13, letterSpacing: 5, color: PaletaArchivo.textoPrincipal),
        ),
        centerTitle: true,
      ),
      body: MesaDeMadera(
        child: SafeArea(
          top: false,
          child: _terminada ? _construirCierre() : _construirRonda(),
        ),
      ),
    );
  }

  Widget _construirRonda() {
    final ronda = _partida.rondaActual;
    final sueltas = _partida.tirasSueltas;
    final soloQuedaLaDeSobra = _partida.rondaCompleta;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: LineaDeAndres(
            texto: _pista ?? VozAndresAtico.instruccionDocumentoRoto(_partida.indiceRonda),
            semilla: _partida.indiceRonda + (_pista == null ? 0 : 50),
          ),
        ),
        Text(
          'Mesa ${_partida.indiceRonda + 1} de ${_partida.rondas.length}',
          style: const TextStyle(color: PaletaArchivo.textoTenue, fontSize: 12),
        ),
        Expanded(
          child: _MesaDeLuz(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                for (final documento in ronda.documentos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _Documento(
                      documento: documento,
                      pegadas: _partida.tirasPegadasA(documento),
                      tiraElegida: _tiraElegida,
                      alRecibir: (tira) => _colocar(tira, documento),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 230),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: soloQuedaLaDeSobra
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sueltas.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'La que sobra se queda en la caja.',
                          style: TextStyle(color: PaletaArchivo.textoPrincipal),
                        ),
                      ),
                    BotonDePapel(
                      texto: _partida.esUltimaRonda ? 'Cerrar la caja' : 'Siguiente mesa',
                      alPulsar: _avanzar,
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final tira in sueltas)
                        Draggable<Tira>(
                          data: tira,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _TiraRasgada(tira: tira, elegida: true),
                          ),
                          childWhenDragging:
                              Opacity(opacity: 0.3, child: _TiraRasgada(tira: tira)),
                          child: GestureDetector(
                            onTap: () => _elegir(tira),
                            child: _TiraRasgada(
                                tira: tira, elegida: identical(tira, _tiraElegida)),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _construirCierre() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      children: [
        LineaDeAndres(
          texto: VozAndresAtico.cierreDocumentoRoto(_partida.tipoConMasVueltas),
          semilla: 31,
        ),
        const SizedBox(height: 12),
        const LineaDeAndres(texto: VozAndresAtico.cierre, semilla: 32),
        const SizedBox(height: 20),
        Center(
          child: BotonDePapel(
            texto: 'Volver al ático',
            alPulsar: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}

/// La mesa de luz: un panel que brilla por debajo de los papeles.
class _MesaDeLuz extends StatelessWidget {
  const _MesaDeLuz({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Pigmentos.tierraSombra, width: 3),
        gradient: RadialGradient(
          radius: 1.1,
          colors: [
            Pigmentos.blancoPlomo.withValues(alpha: 0.55),
            Pigmentos.ocreAmarillo.withValues(alpha: 0.25),
            Pigmentos.tierraSombra.withValues(alpha: 0.6),
          ],
          stops: const [0, 0.6, 1],
        ),
      ),
      child: child,
    );
  }
}

class _Documento extends StatelessWidget {
  const _Documento({
    required this.documento,
    required this.pegadas,
    required this.tiraElegida,
    required this.alRecibir,
  });

  final DocumentoEnMesa documento;
  final List<Tira> pegadas;
  final Tira? tiraElegida;
  final ValueChanged<Tira> alRecibir;

  @override
  Widget build(BuildContext context) {
    final capa = capaPrincipalDeBrecha[documento.brecha.id];
    final acento = capa == null ? PaletaArchivo.ambarLacre : PaletaDeCapa.de(capa).dominante;
    return DragTarget<Tira>(
      onAcceptWithDetails: (detalles) => alRecibir(detalles.data),
      builder: (context, candidatas, _) {
        final resaltado = candidatas.isNotEmpty || tiraElegida != null;
        return Semantics(
          button: tiraElegida != null,
          label: tiraElegida == null ? null : 'Pegar la tira en ${documento.fuente.tipoVisible}',
          child: GestureDetector(
            onTap: tiraElegida == null ? null : () => alRecibir(tiraElegida!),
            child: HojaDePapel(
              semilla: documento.id.hashCode,
              color: resaltado
                  ? Color.lerp(Pigmentos.papelTrapo, Pigmentos.blancoPlomo, 0.6)!
                  : Pigmentos.papelTrapo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, color: acento),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          documento.brecha.titulo.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10, letterSpacing: 1.5, color: PaletaArchivo.tintaTenue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    documento.fuente.tipoVisible,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: PaletaArchivo.tintaNegra),
                  ),
                  const SizedBox(height: 6),
                  _DescripcionPlegable(texto: documento.fuente.descripcion),
                  if (pegadas.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    for (final tira in pegadas)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _TiraRasgada(tira: tira, pegada: true),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Descripción recortada a cuatro líneas: en móvil, con varias
/// fuentes largas en la mesa, no se llega al segundo documento.
class _DescripcionPlegable extends StatefulWidget {
  const _DescripcionPlegable({required this.texto});

  final String texto;

  @override
  State<_DescripcionPlegable> createState() => _EstadoDescripcionPlegable();
}

class _EstadoDescripcionPlegable extends State<_DescripcionPlegable> {
  bool _desplegada = false;

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(fontSize: 13, height: 1.4, color: PaletaArchivo.tintaNegra);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.texto,
          maxLines: _desplegada ? null : 4,
          overflow: _desplegada ? TextOverflow.visible : TextOverflow.ellipsis,
          style: estilo,
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: PaletaArchivo.tintaTenue,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 30),
          ),
          onPressed: () => setState(() => _desplegada = !_desplegada),
          child: Text(_desplegada ? 'plegar' : 'leer entero',
              style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

String _rotulo(TipoTira tipo) {
  switch (tipo) {
    case TipoTira.tipoFuente:
      return 'TIPO';
    case TipoTira.autor:
      return 'AUTORÍA';
    case TipoTira.fecha:
      return 'FECHA';
    case TipoTira.publico:
      return 'PÚBLICO';
  }
}

class _TiraRasgada extends StatelessWidget {
  const _TiraRasgada({required this.tira, this.elegida = false, this.pegada = false});

  final Tira tira;
  final bool elegida;
  final bool pegada;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: pegada ? double.infinity : 300),
      child: HojaDePapel(
        semilla: tira.id.hashCode,
        ladosRasgados: const {LadoPapel.izquierda, LadoPapel.derecha},
        color: elegida
            ? Color.lerp(Pigmentos.papelTrapo, PaletaArchivo.ambarLacre, 0.35)!
            : pegada
                ? Color.lerp(Pigmentos.papelTrapo, Pigmentos.ocreAmarillo, 0.25)!
                : Pigmentos.blancoPlomo,
        relleno: const EdgeInsets.fromLTRB(14, 6, 14, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_rotulo(tira.tipo),
                style: const TextStyle(
                    fontSize: 9, letterSpacing: 1.5, color: PaletaArchivo.tintaTenue)),
            Text(tira.texto,
                style: const TextStyle(fontSize: 13, color: PaletaArchivo.tintaNegra)),
          ],
        ),
      ),
    );
  }
}
