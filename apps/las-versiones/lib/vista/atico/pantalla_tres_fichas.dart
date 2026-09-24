import 'package:flutter/material.dart';

import '../../dominio/atico/partida_tres_fichas.dart';
import '../../dominio/atico/voz_andres_atico.dart';
import '../../dominio/brecha.dart';
import '../../nucleo/paleta_archivo.dart';
import '../../nucleo/pigmentos.dart';
import '../../sonido/catalogo_sonidos_archivo.dart';
import '../../sonido/servicio_sonoro_archivo.dart';
import '../pintura/trazo_a_mano.dart';
import 'objetos_atico.dart';

/// Tres fichas (doc del ático §1). Una tarjeta encima de la mesa, tres
/// bandejas de mimbre abajo. Se arrastra (o se toca la bandeja) y la
/// tarjeta cae. Sin acierto ni fallo hasta el final: al cerrar habla
/// la balanza y Andrés comenta una sola tarjeta.
class PantallaTresFichas extends StatefulWidget {
  const PantallaTresFichas({super.key, required this.partida});

  final PartidaTresFichas partida;

  @override
  State<PantallaTresFichas> createState() => _EstadoPantallaTresFichas();
}

class _EstadoPantallaTresFichas extends State<PantallaTresFichas> {
  int _indiceRonda = 0;
  CierreTresFichas? _cierre;

  /// En la ronda de la tarjeta suelta: tarjetas cuyo cajón ya se abrió.
  final Set<String> _cajonesAbiertos = {};

  PartidaTresFichas get _partida => widget.partida;
  RondaTresFichas get _ronda => _partida.rondas[_indiceRonda];

  List<TarjetaAfirmacion> get _pendientes =>
      _ronda.tarjetas.where((t) => _partida.declarado(t) == null).toList();

  void _colocar(TarjetaAfirmacion tarjeta, NivelConfianza nivel) {
    ServicioSonoroArchivo.instancia
        .reproducirEfecto(CatalogoSonidosArchivo.cartulinaEnMimbre);
    setState(() => _partida.declarar(tarjeta, nivel));
  }

  void _retirar(TarjetaAfirmacion tarjeta) {
    ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.papelTomar);
    setState(() => _partida.retirar(tarjeta));
  }

  void _siguienteRonda() {
    if (_indiceRonda < _partida.rondas.length - 1) {
      ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.cajaAbrir);
      setState(() => _indiceRonda++);
      return;
    }
    final cierre = _partida.cerrar();
    ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.balanzaLaton);
    final capa = cierre.capaParaFragmento;
    if (capa != null) {
      ServicioSonoroArchivo.instancia.reproducirFragmentoDeCapa(capa.codigo);
    }
    setState(() => _cierre = cierre);
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
          'TRES FICHAS',
          style: TextStyle(
              fontSize: 13, letterSpacing: 5, color: PaletaArchivo.textoPrincipal),
        ),
        centerTitle: true,
      ),
      body: MesaDeMadera(
        child: SafeArea(
          top: false,
          child: _cierre == null ? _construirRonda() : _construirCierre(_cierre!),
        ),
      ),
    );
  }

  Widget _construirRonda() {
    final pendientes = _pendientes;
    final tarjetaEnMesa = pendientes.isEmpty ? null : pendientes.first;
    // En la ronda de la tarjeta suelta no se clasifica a ciegas: hasta
    // abrir el cajón, las bandejas no reciben esa tarjeta.
    final cajonPendiente = tarjetaEnMesa != null &&
        _ronda.fuentesOcultas &&
        !_cajonesAbiertos.contains(tarjetaEnMesa.id);
    final tarjetaColocable = cajonPendiente ? null : tarjetaEnMesa;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: LineaDeAndres(
            texto: VozAndresAtico.instruccionRonda(_ronda),
            semilla: _indiceRonda,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ronda ${_indiceRonda + 1} de ${_partida.rondas.length} · '
            'quedan ${pendientes.length} en la caja',
            style: const TextStyle(color: PaletaArchivo.textoTenue, fontSize: 12),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: tarjetaEnMesa == null
                ? _ControlSiguiente(
                    esUltima: _indiceRonda == _partida.rondas.length - 1,
                    alPulsar: _siguienteRonda,
                  )
                : Draggable<TarjetaAfirmacion>(
                    data: tarjetaEnMesa,
                    maxSimultaneousDrags: cajonPendiente ? 0 : 1,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 260,
                        child: _TarjetaReducida(tarjeta: tarjetaEnMesa),
                      ),
                    ),
                    childWhenDragging: const SizedBox(height: 120),
                    child: _TarjetaEnMesa(
                      tarjeta: tarjetaEnMesa,
                      fuentesOcultas: cajonPendiente,
                      alAbrirCajon: () {
                        ServicioSonoroArchivo.instancia
                            .reproducirEfecto(CatalogoSonidosArchivo.cajaAbrir);
                        setState(() => _cajonesAbiertos.add(tarjetaEnMesa.id));
                      },
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
          child: Row(
            children: [
              for (final nivel in NivelConfianza.values)
                Expanded(
                  child: _Bandeja(
                    nivel: nivel,
                    tarjetas: _ronda.tarjetas
                        .where((t) => _partida.declarado(t) == nivel)
                        .toList(),
                    tarjetaEnMesa: tarjetaColocable,
                    alRecibir: (tarjeta) => _colocar(tarjeta, nivel),
                    alRetirar: _retirar,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirCierre(CierreTresFichas cierre) {
    final inclinacion = switch (cierre.inclinacion) {
      InclinacionBalanza.equilibrio => 0.0,
      InclinacionBalanza.sobreconfianza => 1.0,
      InclinacionBalanza.timidez => -1.0,
    };
    final comentada = cierre.paraComentar;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        SizedBox(
          height: 170,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: inclinacion),
            duration: const Duration(milliseconds: 1600),
            curve: Curves.easeOutBack,
            builder: (_, valor, __) => CustomPaint(
              painter: PintorBalanza(inclinacion: valor),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('duda', style: TextStyle(color: PaletaArchivo.textoTenue)),
              Text('seguridad', style: TextStyle(color: PaletaArchivo.textoTenue)),
            ],
          ),
        ),
        LineaDeAndres(texto: VozAndresAtico.sobreLaBalanza(cierre.inclinacion), semilla: 21),
        if (comentada != null) ...[
          const SizedBox(height: 12),
          LineaDeAndres(texto: VozAndresAtico.sobreUnaTarjeta(comentada), semilla: 22),
        ],
        const SizedBox(height: 12),
        const LineaDeAndres(texto: VozAndresAtico.cierre, semilla: 23),
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

/// La tarjeta que está encima de la mesa, con sus fuentes cosidas.
class _TarjetaEnMesa extends StatelessWidget {
  const _TarjetaEnMesa({
    required this.tarjeta,
    required this.fuentesOcultas,
    required this.alAbrirCajon,
  });

  final TarjetaAfirmacion tarjeta;
  final bool fuentesOcultas;
  final VoidCallback alAbrirCajon;

  @override
  Widget build(BuildContext context) {
    final capa = tarjeta.capa;
    final acento = capa == null ? PaletaArchivo.ambarLacre : PaletaDeCapa.de(capa).dominante;
    return HojaDePapel(
      semilla: tarjeta.id.hashCode,
      ladosRasgados: const {LadoPapel.abajo, LadoPapel.arriba},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, color: acento),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${tarjeta.brecha.titulo.toUpperCase()}'
                  '${capa == null ? '' : ' · ${capa.codigo}'}',
                  style: const TextStyle(
                      fontSize: 11, letterSpacing: 1.5, color: PaletaArchivo.tintaTenue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tarjeta.afirmacion.texto,
            style: const TextStyle(fontSize: 16, height: 1.45, color: PaletaArchivo.tintaNegra),
          ),
          const SizedBox(height: 14),
          if (fuentesOcultas)
            Align(
              alignment: Alignment.centerLeft,
              child: BotonDePapel(texto: 'Abrir el cajón de las fuentes', alPulsar: alAbrirCajon),
            )
          else if (tarjeta.fuentesAnclaje.isEmpty)
            const Text(
              'Sin fuentes cosidas: ninguna la sostiene directamente.',
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 13, color: PaletaArchivo.tintaTenue),
            )
          else ...[
            const Text('Cosidas debajo:',
                style: TextStyle(fontSize: 12, color: PaletaArchivo.tintaTenue)),
            const SizedBox(height: 6),
            for (final fuente in tarjeta.fuentesAnclaje) _FuenteCosida(fuente: fuente),
          ],
          const SizedBox(height: 8),
          const Text(
            'Arrástrala a una bandeja, o toca la bandeja.',
            style: TextStyle(fontSize: 11, color: PaletaArchivo.tintaTenue),
          ),
        ],
      ),
    );
  }
}

class _FuenteCosida extends StatelessWidget {
  const _FuenteCosida({required this.fuente});

  final Fuente fuente;

  @override
  Widget build(BuildContext context) {
    final propiedades = fuente.propiedadesCanonicas;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        dense: true,
        iconColor: PaletaArchivo.tintaTenue,
        collapsedIconColor: PaletaArchivo.tintaTenue,
        title: Text(
          '— ${fuente.tipoVisible} (${propiedades.tipo == TipoFuente.primaria ? 'primaria' : 'secundaria'})',
          style: const TextStyle(fontSize: 13, color: PaletaArchivo.tintaNegra),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              fuente.descripcion,
              style: const TextStyle(fontSize: 13, height: 1.4, color: PaletaArchivo.tintaTenue),
            ),
          ),
        ],
      ),
    );
  }
}

/// Versión pequeña de la tarjeta: la que se arrastra y la que queda en
/// la bandeja.
class _TarjetaReducida extends StatelessWidget {
  const _TarjetaReducida({required this.tarjeta});

  final TarjetaAfirmacion tarjeta;

  @override
  Widget build(BuildContext context) {
    return HojaDePapel(
      semilla: tarjeta.id.hashCode + 1,
      relleno: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Text(
        tarjeta.afirmacion.texto,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, height: 1.3, color: PaletaArchivo.tintaNegra),
      ),
    );
  }
}

class _Bandeja extends StatelessWidget {
  const _Bandeja({
    required this.nivel,
    required this.tarjetas,
    required this.tarjetaEnMesa,
    required this.alRecibir,
    required this.alRetirar,
  });

  final NivelConfianza nivel;
  final List<TarjetaAfirmacion> tarjetas;
  final TarjetaAfirmacion? tarjetaEnMesa;
  final ValueChanged<TarjetaAfirmacion> alRecibir;
  final ValueChanged<TarjetaAfirmacion> alRetirar;

  @override
  Widget build(BuildContext context) {
    final nombre = VozAndresAtico.nombreNivel(nivel);
    return DragTarget<TarjetaAfirmacion>(
      onWillAcceptWithDetails: (_) => tarjetaEnMesa != null,
      onAcceptWithDetails: (detalles) => alRecibir(detalles.data),
      builder: (context, candidatas, _) {
        return Semantics(
          button: tarjetaEnMesa != null,
          label: 'Bandeja $nombre, ${tarjetas.length} tarjetas',
          child: GestureDetector(
            onTap: tarjetaEnMesa == null ? null : () => alRecibir(tarjetaEnMesa!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomPaint(
                painter: PintorBandejaMimbre(
                  resaltada: candidatas.isNotEmpty,
                  semilla: nivel.index,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 110),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: PaletaArchivo.tintaNegra,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Monton(numero: tarjetas.length, semilla: nivel.index),
                        if (tarjetas.isNotEmpty)
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: PaletaArchivo.tintaNegra,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: () => alRetirar(tarjetas.last),
                            child: const Text('sacar la última',
                                style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Montón de tarjetas en una bandeja: tantas hojas como tarjetas (hasta
/// cuatro visibles), ligeramente descuadradas. No dice si están bien.
class _Monton extends StatelessWidget {
  const _Monton({required this.numero, required this.semilla});

  final int numero;
  final int semilla;

  @override
  Widget build(BuildContext context) {
    final visibles = numero.clamp(0, 4);
    return SizedBox(
      height: 34,
      width: 56,
      child: Stack(
        children: [
          for (var indice = 0; indice < visibles; indice++)
            Positioned(
              left: 4.0 + indice * 3,
              top: 10.0 - indice * 3,
              child: Transform.rotate(
                angle: ((semilla + indice) % 3 - 1) * 0.06,
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Pigmentos.papelTrapo,
                    border: Border.all(color: Pigmentos.tierraSombra.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
          if (numero > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Text('$numero',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: PaletaArchivo.tintaNegra)),
            ),
        ],
      ),
    );
  }
}

class _ControlSiguiente extends StatelessWidget {
  const _ControlSiguiente({required this.esUltima, required this.alPulsar});

  final bool esUltima;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'La caja está vacía. Aún puedes sacar alguna tarjeta de su bandeja.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PaletaArchivo.textoPrincipal),
        ),
        const SizedBox(height: 16),
        BotonDePapel(
          texto: esUltima ? 'Que hable la balanza' : 'Siguiente caja',
          alPulsar: alPulsar,
        ),
      ],
    );
  }
}
