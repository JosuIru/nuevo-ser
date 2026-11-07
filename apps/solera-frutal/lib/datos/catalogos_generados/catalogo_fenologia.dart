// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/frutal/fenologia_frutal.csv
// Generado: 2026-11-07
// Filas: 15 (0 firmadas por persona, 0 con alguna revisión, 15 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-frutal && dart run tool/compilar_catalogos.dart

class EstadoFenologicoCatalogo {
  const EstadoFenologicoCatalogo({
    required this.id,
    required this.especieId,
    required this.codigo,
    required this.estado,
    required this.mesInicio,
    required this.mesFin,
    required this.sensibleHelada,
    required this.temperaturaCriticaC,
  });

  final String id;
  final String especieId;
  final String codigo;
  final String estado;
  final int? mesInicio;
  final int? mesFin;
  final bool? sensibleHelada;
  final double? temperaturaCriticaC;
}

const List<EstadoFenologicoCatalogo> catalogoFenologia = [
  EstadoFenologicoCatalogo(
      id: 'almendro_a',
      especieId: 'almendro',
      codigo: 'A',
      estado: 'Yema de invierno',
      mesInicio: 11,
      mesFin: 1,
      sensibleHelada: false,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'almendro_b',
      especieId: 'almendro',
      codigo: 'B',
      estado: 'Yema hinchada',
      mesInicio: 1,
      mesFin: 2,
      sensibleHelada: false,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'almendro_c',
      especieId: 'almendro',
      codigo: 'C',
      estado: 'Cáliz visible',
      mesInicio: 1,
      mesFin: 3,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'almendro_d',
      especieId: 'almendro',
      codigo: 'D',
      estado: 'Corola visible',
      mesInicio: 2,
      mesFin: 3,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'almendro_f',
      especieId: 'almendro',
      codigo: 'F',
      estado: 'Flor abierta',
      mesInicio: 2,
      mesFin: 3,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'almendro_g',
      especieId: 'almendro',
      codigo: 'G',
      estado: 'Caída de pétalos',
      mesInicio: 2,
      mesFin: 4,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'almendro_h',
      especieId: 'almendro',
      codigo: 'H',
      estado: 'Fruto cuajado',
      mesInicio: 3,
      mesFin: 4,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'avellano_floracion',
      especieId: 'avellano',
      codigo: '',
      estado: 'Floración',
      mesInicio: 12,
      mesFin: 2,
      sensibleHelada: false,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'avellano_brotacion',
      especieId: 'avellano',
      codigo: '',
      estado: 'Brotación',
      mesInicio: 3,
      mesFin: 4,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'nogal_brotacion',
      especieId: 'nogal',
      codigo: '',
      estado: 'Brotación',
      mesInicio: 3,
      mesFin: 4,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'nogal_floracion',
      especieId: 'nogal',
      codigo: '',
      estado: 'Floración',
      mesInicio: 4,
      mesFin: 5,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'castano_floracion',
      especieId: 'castano',
      codigo: '',
      estado: 'Floración',
      mesInicio: 6,
      mesFin: 7,
      sensibleHelada: false,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'pistachero_floracion',
      especieId: 'pistachero',
      codigo: '',
      estado: 'Floración',
      mesInicio: 4,
      mesFin: 4,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'hueso_floracion',
      especieId: 'hueso',
      codigo: '',
      estado: 'Floración',
      mesInicio: 2,
      mesFin: 4,
      sensibleHelada: true,
      temperaturaCriticaC: null),
  EstadoFenologicoCatalogo(
      id: 'pepita_floracion',
      especieId: 'pepita',
      codigo: '',
      estado: 'Floración',
      mesInicio: 3,
      mesFin: 5,
      sensibleHelada: true,
      temperaturaCriticaC: null),
];
