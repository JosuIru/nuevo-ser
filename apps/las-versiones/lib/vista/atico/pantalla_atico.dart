import 'package:flutter/material.dart';

import '../../datos/registro_maestria_archivo.dart';
import '../../dominio/atico/oficios_atico.dart';
import '../../dominio/atico/partida_documento_roto.dart';
import '../../dominio/atico/partida_tres_fichas.dart';
import '../../dominio/atico/voz_andres_atico.dart';
import '../../nucleo/paleta_archivo.dart';
import '../../sonido/catalogo_sonidos_archivo.dart';
import '../../sonido/servicio_sonoro_archivo.dart';
import '../pintura/trazo_a_mano.dart';
import 'objetos_atico.dart';
import 'pantalla_documento_roto.dart';
import 'pantalla_tres_fichas.dart';

/// El ático de Andrés: los oficios del Archivo para repasar con lo ya
/// investigado (`docs/el-atico-de-andres.md`). Suena la lluvia en la
/// claraboya; no hay música.
class PantallaAtico extends StatefulWidget {
  const PantallaAtico({super.key, required this.flagsActivos, this.registro});

  final Set<String> flagsActivos;

  /// Motor de maestría del juego; se pasa a los oficios que apuntan.
  final RegistroMaestriaArchivo? registro;

  @override
  State<PantallaAtico> createState() => _EstadoPantallaAtico();
}

class _EstadoPantallaAtico extends State<PantallaAtico> {
  @override
  void initState() {
    super.initState();
    ServicioSonoroArchivo.instancia.reproducirAmbiente(CatalogoSonidosArchivo.ambienteAtico);
  }

  @override
  void dispose() {
    ServicioSonoroArchivo.instancia.detenerAmbiente();
    super.dispose();
  }

  Future<void> _abrir(OficioAtico oficio) async {
    switch (oficio) {
      case OficioAtico.tresFichas:
        final partida = PartidaTresFichas.montar(brechasCerradas(widget.flagsActivos));
        if (partida == null) return;
        ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.papelTomar);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PantallaTresFichas(partida: partida, registro: widget.registro)),
        );
      case OficioAtico.documentoRoto:
        final partida = PartidaDocumentoRoto.montar(brechasCerradas(widget.flagsActivos));
        if (partida == null) return;
        ServicioSonoroArchivo.instancia.reproducirEfecto(CatalogoSonidosArchivo.papelTomar);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PantallaDocumentoRoto(partida: partida, registro: widget.registro)),
        );
    }
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'EL ÁTICO',
          style: TextStyle(fontSize: 13, letterSpacing: 5, color: PaletaArchivo.textoPrincipal),
        ),
        centerTitle: true,
      ),
      body: MesaDeMadera(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              const LineaDeAndres(texto: VozAndresAtico.bienvenida),
              const SizedBox(height: 22),
              for (final oficio in OficioAtico.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Semantics(
                    button: true,
                    label: oficio.titulo,
                    child: GestureDetector(
                      onTap: () => _abrir(oficio),
                      child: HojaDePapel(
                        semilla: oficio.index + 40,
                        ladosRasgados: const {LadoPapel.abajo, LadoPapel.derecha},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              oficio.objeto.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  color: PaletaArchivo.tintaTenue),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              oficio.titulo,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: PaletaArchivo.tintaNegra),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              oficio.descripcion,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.4, color: PaletaArchivo.tintaNegra),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const Text(
                'Hay más cosas bajo las sábanas. Andrés las irá destapando.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: PaletaArchivo.textoTenue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
