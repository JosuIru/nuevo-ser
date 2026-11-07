import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../utiles/textos_huerta.dart';
import 'formularios_huerta.dart';
import 'hoja_formulario.dart';
import 'pantalla_ficha_bancal.dart';

/// Ficha de una parcela: sus datos y sus bancales con lo que tienen ahora.
class PantallaFichaParcela extends StatefulWidget {
  const PantallaFichaParcela({super.key, required this.parcelaId});

  final int parcelaId;

  @override
  State<PantallaFichaParcela> createState() => _PantallaFichaParcelaState();
}

class _PantallaFichaParcelaState extends State<PantallaFichaParcela> {
  late Future<DatosHuerta> _datos;

  @override
  void initState() {
    super.initState();
    _datos = DatosHuerta.cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = DatosHuerta.cargar();
    });
  }

  Future<void> _borrar() async {
    if (!await confirmarBorrado(context, SoleraL10n.t('huer.borrar_parcela'))) {
      return;
    }
    try {
      await BaseDatosSoleraHuerta.instancia.borrarParcela(widget.parcelaId);
      avisarCambioDatos();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) avisar(context, SoleraL10n.t('huer.parcela_con_registros'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatosHuerta>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        final parcela = datos?.parcela(widget.parcelaId);
        if (datos == null || parcela == null) {
          return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
        }
        final bancales = [
          for (final bancal in datos.bancales)
            if (bancal.parcelaId == parcela.id) bancal
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(parcela.nombre),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    mostrarFormularioParcela(context, parcela: parcela),
              ),
              IconButton(
                tooltip: SoleraL10n.t('borrar'),
                icon: const Icon(Icons.delete_outline),
                onPressed: _borrar,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                mostrarFormularioBancal(context, parcelaId: parcela.id!),
            icon: const Icon(Icons.add),
            label: Text(SoleraL10n.t('huer.nuevo_bancal')),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              ListTile(
                title: Text(nombreEstadoEcologico(parcela.estadoEcologico)),
                subtitle: Text([
                  if (parcela.codigoSigpac.isNotEmpty)
                    'SIGPAC ${parcela.codigoSigpac}',
                  if (parcela.superficieHa > 0)
                    '${formatearNumero(parcela.superficieHa, decimales: 2)} ha',
                  if (parcela.fechaInicioConversionMs != null)
                    SoleraL10n.tf('huer.conversion_desde', {
                      'fecha': formatearFecha(parcela.fechaInicioConversionMs!)
                    }),
                  SoleraL10n.t(
                      parcela.regadio ? 'huer.regadio' : 'huer.secano'),
                ].join(' · ')),
              ),
              const Divider(),
              ListTile(
                title: Text(SoleraL10n.t('huer.bancales'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (bancales.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('huer.sin_bancales')),
                ),
              for (final bancal in bancales)
                ListTile(
                  leading: Icon(bancal.invernadero
                      ? Icons.house_siding_outlined
                      : Icons.view_week_outlined),
                  enabled: bancal.activo,
                  title: Text(bancal.nombre),
                  subtitle: Text(() {
                    final ocupacion = datos.ocupacionDe(bancal.id!);
                    return ocupacion.isEmpty
                        ? SoleraL10n.t('huer.bancal_libre')
                        : ocupacion
                            .map((siembra) =>
                                datos.nombreDeCultivo(siembra.cultivoId))
                            .join(', ');
                  }()),
                  trailing: bancal.superficieM2 == null
                      ? null
                      : Text(
                          '${formatearNumero(bancal.superficieM2!, decimales: 1)} m²'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PantallaFichaBancal(bancalId: bancal.id!))),
                ),
            ],
          ),
        );
      },
    );
  }
}
