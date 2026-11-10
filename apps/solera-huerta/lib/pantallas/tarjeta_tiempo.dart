// Tarjeta «El tiempo en la huerta» de Hoy: helada, calor y días sin lluvia
// (lógica en `dominio/avisos_tiempo.dart`). Sin ubicación, una línea
// discreta; sin red, sin previsión o sin nada que avisar, no ocupa sitio.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/avisos_tiempo.dart';
import '../estado/aviso_helada_programado.dart';
import '../estado/datos_huerta.dart';
import '../servicios/tiempo_huerta.dart';
import '../utiles/textos_huerta.dart';

/// Lo que sale de cargar el tiempo para Hoy.
class EstadoTiempoHoy {
  const EstadoTiempoHoy({
    this.sinUbicacion = false,
    this.avisos = AvisosTiempoHuerta.ninguno,
  });

  static const EstadoTiempoHoy nada = EstadoTiempoHoy();

  final bool sinUbicacion;
  final AvisosTiempoHuerta avisos;
}

/// Busca la ubicación, descarga (o reutiliza) la previsión, calcula los
/// avisos y reprograma el recordatorio de helada. Nunca lanza.
Future<EstadoTiempoHoy> cargarTiempoHoy(DatosHuerta datos,
    {DateTime? ahora}) async {
  try {
    if (datos.parcelas.isEmpty) return EstadoTiempoHoy.nada;
    final momento = ahora ?? DateTime.now();
    final enTierra = siembrasEnTierra(datos.siembras).toList();
    final parcelasConSiembras = {
      for (final siembra in enTierra) datos.bancal(siembra.bancalId)?.parcelaId,
    }.whereType<int>().toSet();
    final lugar = ubicacionParaElTiempo(
        parcelas: datos.parcelas, parcelasConSiembras: parcelasConSiembras);
    if (lugar == null) {
      await reprogramarAvisoHelada(
          helada: null, titulo: _tituloAviso, cuerpo: _cuerpoAviso);
      return const EstadoTiempoHoy(sinUbicacion: true);
    }
    final prevision =
        await TiempoHuerta.instancia.prevision(lugar, ahora: momento);
    // Sin red se deja el aviso que hubiera programado con la última
    // previsión buena: mejor un aviso algo viejo que ninguno.
    if (prevision == null) return EstadoTiempoHoy.nada;
    final avisos = calcularAvisosTiempo(
      prevision: prevision,
      siembras: datos.siembras,
      cultivos: {for (final cultivo in datos.cultivos) cultivo.id!: cultivo},
      bancales: {for (final bancal in datos.bancales) bancal.id!: bancal},
      ahora: momento,
    );
    await reprogramarAvisoHelada(
        helada: avisos.helada,
        titulo: _tituloAviso,
        cuerpo: _cuerpoAviso,
        ahora: momento);
    return EstadoTiempoHoy(avisos: avisos);
  } catch (error) {
    debugPrint('Sin avisos del tiempo: $error');
    return EstadoTiempoHoy.nada;
  }
}

String _grados(double valor) => formatearNumero(valor, decimales: 0);

String _nombreDia(DateTime fecha) =>
    DateFormat.EEEE(SoleraL10n.idioma).format(fecha);

String _tituloAviso(AvisoHeladaHuerta helada) =>
    SoleraL10n.t('huer.tiempo_notificacion_titulo');

String _cuerpoAviso(AvisoHeladaHuerta helada) =>
    SoleraL10n.tf('huer.tiempo_notificacion_cuerpo', {
      'minima': _grados(helada.minimaC),
      'cultivos': helada.cultivosSensibles.join(', '),
    });

/// «Esta noche −2 °C: riesgo de helada.»
String textoHelada(AvisoHeladaHuerta helada) {
  final minima = _grados(helada.minimaC);
  return switch (helada.diasDesdeHoy) {
    0 => SoleraL10n.tf('huer.tiempo_helada_esta_madrugada', {'minima': minima}),
    1 => SoleraL10n.tf('huer.tiempo_helada_esta_noche', {'minima': minima}),
    _ => SoleraL10n.tf('huer.tiempo_helada_dia',
        {'dia': _nombreDia(helada.fecha), 'minima': minima}),
  };
}

class TarjetaTiempo extends StatelessWidget {
  const TarjetaTiempo({super.key, required this.estado});

  final EstadoTiempoHoy estado;

  @override
  Widget build(BuildContext context) {
    if (estado.sinUbicacion) {
      return ListTile(
        key: const ValueKey('tiempo-sin-ubicacion'),
        dense: true,
        leading: const Icon(Icons.location_off_outlined),
        title: Text(SoleraL10n.t('huer.tiempo_sin_ubicacion'),
            style: Theme.of(context).textTheme.bodySmall),
      );
    }
    final avisos = estado.avisos;
    if (avisos.vacio) return const SizedBox.shrink();
    final helada = avisos.helada;
    final calor = avisos.calor;
    final diasSinLluvia = avisos.diasSinLluvia;
    final colores = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('tarjeta-tiempo'),
      color: helada != null ? colores.errorContainer : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.wb_cloudy_outlined),
            title: Text(SoleraL10n.t('huer.tiempo_titulo'),
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(SoleraL10n.t('huer.tiempo_orientativo')),
          ),
          if (helada != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.ac_unit),
              title: Text(textoHelada(helada)),
              subtitle: helada.cultivosSensibles.isEmpty
                  ? null
                  : Text(SoleraL10n.tf('huer.tiempo_helada_proteger',
                      {'cultivos': helada.cultivosSensibles.join(', ')})),
            ),
          if (calor != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text(calor.esOla
                  ? SoleraL10n.tf('huer.tiempo_ola_calor', {
                      'maxima': _grados(calor.maximaC),
                      'dia': _nombreDia(calor.fecha),
                    })
                  : SoleraL10n.tf('huer.tiempo_calor', {
                      'maxima': _grados(calor.maximaC),
                      'dia': _nombreDia(calor.fecha),
                    })),
              subtitle: Text(SoleraL10n.t('huer.tiempo_calor_consejo')),
            ),
          if (diasSinLluvia != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(SoleraL10n.tf(
                  'huer.tiempo_sin_lluvia', {'dias': diasSinLluvia})),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(SoleraL10n.t('huer.tiempo_fuente'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
