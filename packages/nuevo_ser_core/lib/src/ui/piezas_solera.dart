import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tema_solera.dart';

/// Piezas de pantalla del rediseño de Zunbeltz que sirven en cualquier app
/// Larrea. Usan el [temaSolera] (`context.coloresSolera`), pero funcionan
/// con cualquier tema.

/// Barra fija abajo de un formulario, sobre una raya: los botones (guardar,
/// guardar y otro…) repartidos a partes iguales. Va en
/// `Scaffold.bottomNavigationBar`, así el botón no se pierde al final del
/// scroll ni queda bajo el teclado o la barra del sistema.
class BarraGuardarSolera extends StatelessWidget {
  const BarraGuardarSolera({super.key, required this.botones});

  final List<Widget> botones;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        border: Border(top: BorderSide(color: esquema.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            for (var indice = 0; indice < botones.length; indice++) ...[
              if (indice > 0) const SizedBox(width: 12),
              Expanded(child: botones[indice]),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Contenido del botón de guardar: el texto o, mientras guarda, una rueda.
Widget textoOGuardando(String texto, {required bool guardando}) => guardando
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : Text(texto);

/// Centra el contenido con un ancho máximo en pantallas anchas (tablet,
/// escritorio), para que formularios y fichas no se estiren de lado a lado.
/// En el móvil ocupa todo el ancho.
class CuerpoResponsivoSolera extends StatelessWidget {
  const CuerpoResponsivoSolera(
      {super.key, required this.child, this.anchoMaximo = 560});

  final Widget child;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: child,
      ),
    );
  }
}

/// [base] más el hueco de la barra de navegación del sistema por abajo.
///
/// Un `ListView` con `padding` explícito deja de sumar ese hueco, y en
/// móviles de pantalla completa (Android 15, borde a borde) el último
/// elemento queda debajo de la barra.
EdgeInsets rellenoInferiorSeguro(BuildContext context, EdgeInsets base) =>
    base.copyWith(bottom: base.bottom + MediaQuery.paddingOf(context).bottom);

/// Una cifra de la cabecera: el número en grande, qué es y un detalle.
class CifraCabecera {
  const CifraCabecera(
      {required this.valor, required this.etiqueta, this.detalle});

  final String valor;
  final String etiqueta;
  final String? detalle;
}

/// Cabecera de color de la pantalla Hoy: logo, título y acciones arriba, la
/// fecha en grande y, debajo, unas cifras del día. Llega hasta arriba (detrás
/// de la barra de estado, con sus iconos en claro), así que va como primer
/// elemento de un `ListView` con `padding` superior cero y sin `AppBar`.
class CabeceraHoySolera extends StatelessWidget {
  const CabeceraHoySolera({
    super.key,
    required this.titulo,
    required this.fecha,
    this.rutaLogo,
    this.acciones = const [],
    this.cifras = const [],
  });

  final String titulo;

  /// Ya formateada en el idioma de la app («Jueves, 5 de noviembre»).
  final String fecha;
  final String? rutaLogo;

  /// Normalmente `IconButton`: toman el color de la cabecera.
  final List<Widget> acciones;
  final List<CifraCabecera> cifras;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresSolera;
    final estilos = Theme.of(context).textTheme;
    final oscura = ThemeData.estimateBrightnessForColor(colores.cabecera) ==
        Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: oscura ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Container(
        decoration: BoxDecoration(
          color: colores.cabecera,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            16, MediaQuery.paddingOf(context).top + 8, 8, 20),
        // El tema fija el color de los IconButton (gris sobre superficie):
        // en la cabecera van del color del texto de la cabecera.
        child: IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(foregroundColor: colores.sobreCabecera),
          ),
          child: IconTheme(
            data: IconThemeData(color: colores.sobreCabecera),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (rutaLogo != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(rutaLogo!,
                          width: 34, height: 34, excludeFromSemantics: true),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(titulo,
                        style: estilos.titleLarge
                            ?.copyWith(color: colores.sobreCabecera)),
                  ),
                  ...acciones,
                ]),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(fecha,
                      style: estilos.headlineMedium
                          ?.copyWith(color: colores.sobreCabecera)),
                ),
                if (cifras.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var indice = 0;
                              indice < cifras.length;
                              indice++) ...[
                            if (indice > 0) const SizedBox(width: 8),
                            Expanded(
                                child: _BloqueCifra(cifra: cifras[indice])),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BloqueCifra extends StatelessWidget {
  const _BloqueCifra({required this.cifra});

  final CifraCabecera cifra;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresSolera;
    final estilos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colores.sobreCabecera.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radioTarjetaSolera),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cifra.valor,
              maxLines: 1,
              style: estilos.headlineSmall
                  ?.copyWith(color: colores.sobreCabecera)),
          const SizedBox(height: 2),
          Text(cifra.etiqueta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  estilos.labelMedium?.copyWith(color: colores.sobreCabecera)),
          if (cifra.detalle != null)
            Text(cifra.detalle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: estilos.bodySmall
                    ?.copyWith(color: colores.sobreCabeceraVariante)),
        ],
      ),
    );
  }
}

/// Título de un bloque de una pantalla («Pendientes hoy»).
class TituloBloqueSolera extends StatelessWidget {
  const TituloBloqueSolera(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
      );
}
