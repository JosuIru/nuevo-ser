import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/ocupacion_pastos.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_ganado.dart';
import '../modelos/pieza_pasto.dart';
import '../utiles/recinto_sigpac.dart';
import '../utiles/textos_ganadera.dart';
import 'hoja_formulario.dart';
import 'pantalla_mapa_pastos.dart';

/// Las piezas de pasto con lo que tienen ahora: rebaños, cabezas y carga.
class PantallaPastos extends StatefulWidget {
  const PantallaPastos({super.key});

  @override
  State<PantallaPastos> createState() => _PantallaPastosState();
}

class _PantallaPastosState extends State<PantallaPastos> {
  late Future<DatosGanado> _datos = DatosGanado.cargar();

  @override
  void initState() {
    super.initState();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _datos = DatosGanado.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('gana.pastos')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('gana.mapa_pastos'),
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaMapaPastos())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('gana.nueva_pieza'),
        onPressed: () => mostrarEdicionPieza(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<DatosGanado>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return instantanea.hasError
                ? Center(child: Text(SoleraL10n.t('gana.error_cargar')))
                : const Center(child: CircularProgressIndicator());
          }
          final ocupacion = ocupacionDePiezas(
              datos.piezas,
              estadosDeLotes(
                  lotes: datos.lotes,
                  animales: datos.animales,
                  movimientos: datos.movimientos,
                  tabla: tablaUgmPantallas,
                  ahora: DateTime.now()));
          if (ocupacion.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('gana.sin_piezas'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final pieza in ocupacion)
                ListTile(
                  leading: Icon(pieza.lotes.isEmpty
                      ? Icons.crop_square_outlined
                      : Icons.grass),
                  title: Text(pieza.pieza.nombre),
                  subtitle: Text(_resumenPieza(pieza)),
                  onTap: () => mostrarEdicionPieza(context, pieza.pieza),
                ),
            ],
          );
        },
      ),
    );
  }

  String _resumenPieza(OcupacionPieza ocupacion) {
    final pieza = ocupacion.pieza;
    final recinto = partesRecintoSigpac(pieza.recintoSigpac)?.join(' · ') ??
        pieza.recintoSigpac;
    final carga = ocupacion.carga;
    return [
      if (pieza.superficieHa != null)
        '${formatearNumero(pieza.superficieHa!, decimales: 2)} ha',
      nombreTipoPasto(pieza.tipoPasto),
      nombreTitularidad(pieza.titularidad),
      if (recinto.isNotEmpty) 'SIGPAC $recinto',
      if (ocupacion.lotes.isEmpty)
        SoleraL10n.t('gana.sin_ganado')
      else
        '${ocupacion.lotes.map((estado) => estado.lote.nombre).join(', ')}'
            ' (${ocupacion.cabezas})'
            '${carga == null ? '' : ' · ${formatearNumero(carga, decimales: 2)} UGM/ha'}',
    ].join(' · ');
  }
}

/// Alta o edición de una pieza de pasto.
Future<void> mostrarEdicionPieza(BuildContext context,
    [PiezaPasto? existente]) async {
  final nombre = TextEditingController(text: existente?.nombre);
  final recinto = TextEditingController(text: existente?.recintoSigpac);
  final superficie = TextEditingController(
      text: existente?.superficieHa == null
          ? ''
          : formatearNumero(existente!.superficieHa!, decimales: 2));
  final notas = TextEditingController(text: existente?.notas);
  var tipoPasto = existente?.tipoPasto ?? pastoMediterraneo;
  var titularidad = existente?.titularidad ?? titularidadesPieza.first;
  var activa = existente?.activa ?? true;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        existente == null ? 'gana.nueva_pieza' : 'gana.editar_pieza'),
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('gana.nombre')),
      campoTexto(recinto, SoleraL10n.t('gana.recinto_sigpac')),
      campoNumero(superficie, SoleraL10n.t('gana.superficie_ha')),
      DropdownButtonFormField<String>(
        initialValue: tipoPasto,
        decoration: InputDecoration(labelText: SoleraL10n.t('gana.tipo_pasto')),
        items: [
          for (final opcion in tiposPasto)
            DropdownMenuItem(
                value: opcion, child: Text(nombreTipoPasto(opcion)))
        ],
        onChanged: (valor) => refrescar(() => tipoPasto = valor ?? tipoPasto),
      ),
      DropdownButtonFormField<String>(
        initialValue: titularidad,
        decoration:
            InputDecoration(labelText: SoleraL10n.t('gana.titularidad')),
        items: [
          for (final opcion in titularidadesPieza)
            DropdownMenuItem(
                value: opcion, child: Text(nombreTitularidad(opcion)))
        ],
        onChanged: (valor) =>
            refrescar(() => titularidad = valor ?? titularidad),
      ),
      if (existente != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('gana.pieza_en_uso')),
          value: activa,
          onChanged: (valor) => refrescar(() => activa = valor),
        ),
      campoTexto(notas, SoleraL10n.t('gana.notas')),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      await BaseDatosSoleraGanadera.instancia.guardarPieza(PiezaPasto(
        id: existente?.id,
        nombre: nombre.text.trim(),
        recintoSigpac: recinto.text.trim(),
        superficieHa: leerNumero(superficie.text),
        tipoPasto: tipoPasto,
        titularidad: titularidad,
        contorno: existente?.contorno ?? const [],
        activa: activa,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}
