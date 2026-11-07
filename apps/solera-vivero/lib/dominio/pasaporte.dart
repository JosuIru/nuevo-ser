// Datos del pasaporte fitosanitario. Lógica pura, sin Flutter.
//
// Fuentes (verificadas el 2026-11-07, ver CLAUDE.md):
// - Reglamento (UE) 2016/2031, arts. 79, 81 y 83.
// - Reglamento de Ejecución (UE) 2017/2313 (13/12/2017): formato y letras A-D.
// - Reglamento de Ejecución (UE) 2019/2072, anexos XIII y XIV.
// - RD 1054/2021, arts. 8, 16 y 20.
//
// La app PREPARA los datos; el pasaporte lo expide el operador autorizado.

import '../modelos/partida_planta.dart';
import '../modelos/salida.dart';
import '../modelos/vivero.dart';

/// Lo que dice la app sobre si una salida lleva pasaporte. Es una
/// orientación con el motivo: la decisión es del operador.
enum NecesidadPasaporte {
  /// Vegetal para plantación que se traslada entre profesionales.
  necesario,

  /// Con destino a zona protegida: pasaporte «ZP».
  necesarioZonaProtegida,

  /// Suministro directo a un usuario final, en persona (art. 81.1).
  noUsuarioFinal,

  /// Traslado a otra instalación propia en la misma comunidad (RD 1054/2021,
  /// art. 16.6.b).
  noTrasladoPropio,

  /// La especie no está en el catálogo o su fila no lo dice: hay que
  /// mirarlo.
  porVerificar,
}

/// Decide la necesidad de pasaporte de una salida.
///
/// [necesitaPasaporteEspecie]: el dato del catálogo (anexo XIII) o nulo si
/// la especie no está. Para planta (vegetal para plantación que no es
/// semilla) el anexo XIII punto 1 lo pide siempre.
NecesidadPasaporte evaluarNecesidadPasaporte(
  Salida salida, {
  required bool? necesitaPasaporteEspecie,
}) {
  if (salida.destinoZonaProtegida) {
    return NecesidadPasaporte.necesarioZonaProtegida;
  }
  if (salida.esTrasladoPropioMismaComunidad) {
    return NecesidadPasaporte.noTrasladoPropio;
  }
  if (salida.esUsuarioFinal && !salida.esVentaADistancia) {
    return NecesidadPasaporte.noUsuarioFinal;
  }
  if (necesitaPasaporteEspecie == null) return NecesidadPasaporte.porVerificar;
  return necesitaPasaporteEspecie
      ? NecesidadPasaporte.necesario
      : NecesidadPasaporte.porVerificar;
}

bool necesidadExigePasaporte(NecesidadPasaporte necesidad) =>
    necesidad == NecesidadPasaporte.necesario ||
    necesidad == NecesidadPasaporte.necesarioZonaProtegida;

/// Datos que faltan para poder preparar el pasaporte.
enum DatoPasaporteFaltante {
  nombreBotanico,
  codigoOperador,
  codigoTrazabilidad,
  paisOrigen,
  plagasZonaProtegida,
}

/// Los datos de las letras A-D, listos para la etiqueta o para el registro.
class DatosPasaporte {
  const DatosPasaporte({
    required this.esZonaProtegida,
    required this.nombreBotanico,
    required this.variedad,
    required this.codigoOperador,
    required this.codigoTrazabilidad,
    required this.paisOrigen,
    required this.plagasZonaProtegida,
    required this.cantidad,
    required this.operadorAutorizado,
    required this.faltan,
  });

  final bool esZonaProtegida;
  final String nombreBotanico;
  final String variedad;
  final String codigoOperador;
  final String codigoTrazabilidad;
  final String paisOrigen;
  final String plagasZonaProtegida;
  final int cantidad;
  final bool operadorAutorizado;
  final List<DatoPasaporteFaltante> faltan;

  /// Sin autorización o con datos que faltan: la etiqueta sale como
  /// borrador, nunca como pasaporte.
  bool get esBorrador => !operadorAutorizado || faltan.isNotEmpty;

  /// Título que fija el anexo del Reglamento 2017/2313: «Plant Passport» en
  /// inglés y, separado por una barra, otra lengua oficial de la Unión.
  String get titulo => esZonaProtegida
      ? 'Plant Passport – PZ / Pasaporte fitosanitario – ZP'
      : 'Plant Passport / Pasaporte fitosanitario';

  /// Letra A con la variedad, si la hay.
  String get letraA =>
      variedad.isEmpty ? nombreBotanico : '$nombreBotanico \'$variedad\'';
}

/// Prepara los datos del pasaporte de una salida. [plagasZonaProtegida] lo
/// pone la persona (catálogo o texto): la app no decide de qué zona
/// protegida se trata.
DatosPasaporte prepararDatosPasaporte({
  required Vivero vivero,
  required PartidaPlanta partida,
  required Salida salida,
  String plagasZonaProtegida = '',
}) {
  final codigoOperador = vivero.letraBPasaporte;
  final codigoTrazabilidad = salida.codigoTrazabilidad.trim().isEmpty
      ? partida.codigo.trim()
      : salida.codigoTrazabilidad.trim();
  final paisOrigen = partida.paisOrigen.trim().toUpperCase();
  final faltan = <DatoPasaporteFaltante>[
    if (partida.nombreBotanico.trim().isEmpty)
      DatoPasaporteFaltante.nombreBotanico,
    if (!tieneFormaCodigoRopveg(codigoOperador))
      DatoPasaporteFaltante.codigoOperador,
    if (codigoTrazabilidad.isEmpty) DatoPasaporteFaltante.codigoTrazabilidad,
    if (paisOrigen.isEmpty) DatoPasaporteFaltante.paisOrigen,
    if (salida.destinoZonaProtegida && plagasZonaProtegida.trim().isEmpty)
      DatoPasaporteFaltante.plagasZonaProtegida,
  ];
  return DatosPasaporte(
    esZonaProtegida: salida.destinoZonaProtegida,
    nombreBotanico: partida.nombreBotanico.trim(),
    variedad: partida.variedad.trim(),
    codigoOperador: codigoOperador,
    codigoTrazabilidad: codigoTrazabilidad,
    paisOrigen: paisOrigen,
    plagasZonaProtegida: plagasZonaProtegida.trim(),
    cantidad: salida.cantidad,
    operadorAutorizado: vivero.autorizadoPasaporte,
    faltan: faltan,
  );
}

/// Contenido del QR de la etiqueta (letra C con soporte de datos, que el
/// anexo admite «si procede»): los datos A-D separados por «|», legibles
/// sin la app. Formato propio: **por verificar** con la autoridad
/// competente si se quiere usar como soporte oficial.
String contenidoQrPasaporte(DatosPasaporte datos) => [
      datos.esZonaProtegida ? 'PP-ZP' : 'PP',
      'A=${datos.letraA}',
      'B=${datos.codigoOperador}',
      'C=${datos.codigoTrazabilidad}',
      'D=${datos.paisOrigen}',
      if (datos.esZonaProtegida) 'ZP=${datos.plagasZonaProtegida}',
    ].join('|');
