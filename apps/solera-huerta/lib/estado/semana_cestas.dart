import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/prevision_cosecha.dart';
import '../provisional_core/venta_directa/cesta.dart';
import '../provisional_core/venta_directa/entrega.dart';
import '../provisional_core/venta_directa/semanas.dart';
import '../provisional_core/venta_directa/socio.dart';
import '../provisional_core/venta_directa/suscripcion.dart';
import '../utiles/textos_huerta.dart';
import 'datos_huerta.dart';

/// Todo lo de una semana de cestas, ya cargado.
class SemanaCestas {
  SemanaCestas({
    required this.lunes,
    required this.datos,
    required this.socios,
    required this.suscripciones,
    required this.cestas,
    required this.lineas,
    required this.entregas,
    required this.real,
    required this.prevista,
  });

  final DateTime lunes;
  final DatosHuerta datos;
  final List<Socio> socios;
  final List<Suscripcion> suscripciones;
  final List<Cesta> cestas;
  final List<LineaCesta> lineas;
  final List<Entrega> entregas;
  final Map<int, ({double kg, int unidades})> real;
  final Map<int, double> prevista;

  static Future<SemanaCestas> cargar(DateTime lunes) async {
    final bd = BaseDatosSoleraHuerta.instancia;
    final semana = lunesDeSemana(lunes);
    final (inicio, fin) = intervaloSemana(semana);
    final datos = await DatosHuerta.cargar();
    final cestas =
        await bd.listarCestas(semanaLunesMs: semana.millisecondsSinceEpoch);
    final ids = [for (final cesta in cestas) cesta.id!];
    return SemanaCestas(
      lunes: semana,
      datos: datos,
      socios: await bd.listarSocios(),
      suscripciones: await bd.listarSuscripciones(),
      cestas: cestas,
      lineas: await bd.listarLineasCesta(cestaIds: ids),
      entregas: await bd.listarEntregas(cestaIds: ids),
      real: cosechaRealParaCestas(
          cosechas: await bd.listarCosechas(desdeMs: inicio, hastaMs: fin),
          lunes: semana),
      prevista: cosechaPrevistaSemana(
          siembras: datos.siembras,
          lunes: semana,
          cicloDe: datos.cicloDeCultivo),
    );
  }

  Socio? socio(int id) {
    for (final socio in socios) {
      if (socio.id == id) return socio;
    }
    return null;
  }

  /// Suscripciones a las que les toca cesta esta semana.
  List<Suscripcion> get queTocan => [
        for (final suscripcion in suscripciones)
          if (suscripcion.tocaEnSemana(lunes) &&
              (socio(suscripcion.socioId)?.activo ?? false))
            suscripcion
      ];

  Cesta? cestaDe(int suscripcionId) {
    for (final cesta in cestas) {
      if (cesta.suscripcionId == suscripcionId) return cesta;
    }
    return null;
  }

  List<LineaCesta> lineasDe(int cestaId) => [
        for (final linea in lineas)
          if (linea.cestaId == cestaId) linea
      ];

  Entrega? entregaDe(int cestaId) {
    for (final entrega in entregas) {
      if (entrega.cestaId == cestaId) return entrega;
    }
    return null;
  }

  String nombreSuscripcion(Suscripcion suscripcion) =>
      '${socio(suscripcion.socioId)?.nombre ?? '?'} · '
      '${nombreTamanoCesta(suscripcion.tamano)}';

  /// «Tomate 1,2 kg, Lechuga 2 pzas».
  String resumenLineas(int cestaId) => lineasDe(cestaId)
      .map((linea) => '${datos.nombreDeCultivo(linea.cultivoId)} '
          '${linea.porUnidades ? SoleraL10n.tf('huer.n_piezas', {
                  'n': linea.unidades
                }) : formatearKilos(linea.kg)}')
      .join(', ');
}
