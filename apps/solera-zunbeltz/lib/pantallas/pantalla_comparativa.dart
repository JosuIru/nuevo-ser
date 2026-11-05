import 'package:flutter/material.dart';

import '../branding.dart';
import '../l10n/app_localizations.dart';
import '../modelos/amortizacion.dart' show mesesDelProyecto;
import '../modelos/balance_convenio.dart';
import '../modelos/proyecto_test.dart';
import '../utiles/resumen_proyecto.dart';
import 'widgets/proyecto_visual.dart';
import 'widgets/relleno_seguro.dart';

/// Los proyectos uno al lado de otro: balance del test por mes (para
/// comparar duraciones distintas), ingresos, gastos del test y parte de
/// los gastos que asume la persona tester. El PDF de siempre, abajo.
class PantallaComparativa extends StatelessWidget {
  const PantallaComparativa({
    super.key,
    required this.proyectos,
    required this.balances,
    required this.alGenerarPdf,
  });

  final List<ProyectoTest> proyectos;
  final Map<int, BalanceConvenio> balances;
  final Future<void> Function() alGenerarPdf;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final colores = context.coloresZunbeltz;
    final filas = [
      for (final proyecto in proyectos)
        if (proyecto.id != null && balances[proyecto.id] != null)
          (proyecto: proyecto, balance: balances[proyecto.id]!),
    ];
    String siglas(ProyectoTest proyecto) => siglasProyecto(proyecto, idioma);
    // Balance por mes: con menos de un mes, el balance entero.
    int balanceMes(ProyectoTest proyecto, BalanceConvenio balance) {
      final meses = mesesDelProyecto(proyecto);
      return meses < 1
          ? balance.balanceTestCentimos
          : (balance.balanceTestCentimos / meses).round();
    }

    Widget tarjeta(String titulo, String? ayuda, List<Widget> lineas) =>
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          decoration: BoxDecoration(
            color: esquema.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(titulo,
                  style: estilos.titleMedium?.copyWith(
                      fontFamily: familiaTitularZunbeltz,
                      fontWeight: FontWeight.w600,
                      fontSize: 19)),
              if (ayuda != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(ayuda,
                      style: estilos.bodyMedium
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ),
              const SizedBox(height: 8),
              ...lineas,
            ],
          ),
        );

    Widget linea(String sigla, Widget barra, String valor, {Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            SizedBox(
              width: 40,
              child: Text(sigla,
                  style: estilos.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: esquema.onSurfaceVariant)),
            ),
            Expanded(child: barra),
            SizedBox(
              width: 96,
              child: Text(valor,
                  textAlign: TextAlign.end,
                  style: estilos.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
        );

    Widget barraSimple(double proporcion) => proporcion <= 0
        ? const SizedBox(height: 22)
        : Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: proporcion.clamp(0.02, 1.0),
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  color: colorCuadroEsmeralda,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );

    // Barras que salen de un eje central: a la derecha lo positivo.
    Widget barraConSigno(int valor, int mayor) {
      final proporcion = mayor == 0 ? 0.0 : (valor.abs() / mayor);
      final color = valor < 0 ? colores.bloqueada : colores.hecha;
      if (valor == 0) {
        return Row(children: [
          const Spacer(),
          Container(width: 2, height: 30, color: esquema.outline),
          const Spacer(),
        ]);
      }
      final barra = FractionallySizedBox(
        widthFactor: proporcion.clamp(0.02, 1.0),
        child: Container(
          height: 22,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(6)),
        ),
      );
      return Row(children: [
        Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: valor < 0 ? barra : const SizedBox.shrink()),
        ),
        Container(width: 2, height: 30, color: esquema.outline),
        Expanded(
          child: Align(
              alignment: Alignment.centerLeft,
              child: valor >= 0 ? barra : const SizedBox.shrink()),
        ),
      ]);
    }

    int mayorDe(Iterable<int> valores) =>
        valores.fold(0, (a, b) => a > b.abs() ? a : b.abs());

    final porMes = {
      for (final fila in filas)
        fila.proyecto.id!: balanceMes(fila.proyecto, fila.balance)
    };
    final mayorMes = mayorDe(porMes.values);
    final mayorIngresos =
        mayorDe(filas.map((fila) => fila.balance.ingresosCentimos));
    final mayorGastos =
        mayorDe(filas.map((fila) => fila.balance.gastosTestCentimos));

    return Scaffold(
      appBar: AppBar(title: Text(textos.compTitulo)),
      body: ListView(
        padding: rellenoSobreBarraSistema(
            context, const EdgeInsets.fromLTRB(16, 4, 16, 24)),
        children: [
          for (final fila in filas)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                AvatarProyecto(
                    proyecto: fila.proyecto,
                    tamano: 44,
                    apagado: fila.proyecto.cerrado),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(fila.proyecto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: estilos.titleMedium),
                ),
                const SizedBox(width: 8),
                Text(
                    [
                      textos.compMeses(
                          numeroMeses(mesesDelProyecto(fila.proyecto))),
                      if (fila.proyecto.cerrado) textos.compCerrado,
                    ].join(' · '),
                    style: estilos.bodyMedium
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              ]),
            ),
          const SizedBox(height: 12),
          tarjeta(textos.compBalanceMes, textos.compBalanceMesAyuda, [
            for (final fila in filas)
              linea(
                siglas(fila.proyecto),
                barraConSigno(porMes[fila.proyecto.id]!, mayorMes),
                eurosConSigno(porMes[fila.proyecto.id]!),
                color: porMes[fila.proyecto.id]! < 0
                    ? colores.bloqueada
                    : colores.hecha,
              ),
          ]),
          tarjeta(textos.balanceIngresos, null, [
            for (final fila in filas)
              linea(
                siglas(fila.proyecto),
                barraSimple(mayorIngresos == 0
                    ? 0
                    : fila.balance.ingresosCentimos / mayorIngresos),
                eurosRedondos(fila.balance.ingresosCentimos),
              ),
          ]),
          tarjeta(textos.proyGastosDelTest, null, [
            for (final fila in filas)
              linea(
                siglas(fila.proyecto),
                barraSimple(mayorGastos == 0
                    ? 0
                    : fila.balance.gastosTestCentimos / mayorGastos),
                eurosRedondos(fila.balance.gastosTestCentimos),
              ),
          ]),
          tarjeta(textos.compParteTester, null, [
            for (final fila in filas)
              Builder(builder: (_) {
                final reparto = repartoDeGastos(fila.balance);
                return linea(
                  siglas(fila.proyecto),
                  barraSimple((reparto?.tester ?? 0) / 100),
                  reparto == null
                      ? textos.compSinGastos
                      : '${reparto.tester} %',
                );
              }),
          ]),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: filas.isEmpty ? null : alGenerarPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(textos.comparativaPdf),
          ),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 18, color: esquema.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(textos.convenioProvisional,
                  style: estilos.bodySmall
                      ?.copyWith(color: esquema.onSurfaceVariant)),
            ),
          ]),
        ],
      ),
    );
  }
}

/// 8 → «8»; 23,8 → «23,8».
String numeroMeses(double meses) {
  final redondo = (meses * 10).round() / 10;
  return redondo == redondo.roundToDouble()
      ? redondo.toStringAsFixed(0)
      : redondo.toStringAsFixed(1).replaceAll('.', ',');
}
