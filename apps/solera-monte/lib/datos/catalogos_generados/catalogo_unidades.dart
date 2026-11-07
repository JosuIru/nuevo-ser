// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/monte/unidades_volumen.csv
// Generado: 2026-11-07
// Filas: 3 (0 firmadas por persona, 3 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-monte && dart run tool/compilar_catalogos.dart

class UnidadVolumen {
  const UnidadVolumen({
    required this.id,
    required this.nombre,
    required this.simbolo,
    required this.m3PorUnidad,
    required this.nota,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String simbolo;
  final double? m3PorUnidad;
  final String nota;
  final String fuente;
  final String revisadoPor;
}

const List<UnidadVolumen> catalogoUnidades = [
  UnidadVolumen(
      id: 'm3',
      nombre: 'Metro cúbico',
      simbolo: 'm³',
      m3PorUnidad: 1.0,
      nota: 'Madera sólida (en rollo o en pie)',
      fuente: 'Definición',
      revisadoPor: 'fuente_publica: Ley 43/2003, art. 37.2.b'),
  UnidadVolumen(
      id: 'estereos',
      nombre: 'Estéreo',
      simbolo: 'est',
      m3PorUnidad: 0.65,
      nota:
          'Metro cúbico de leña apilada; el factor real depende del grosor y del apilado',
      fuente: 'FAO, Padovani, tabla 2',
      revisadoPor:
          'fuente_publica: FAO, The Measurement of Forest products, tabla 2 (1 estéreo = 0,65 m³ sólidos sin corteza)'),
  UnidadVolumen(
      id: 'toneladas',
      nombre: 'Tonelada',
      simbolo: 't',
      m3PorUnidad: null,
      nota: 'Sin conversión a volumen: depende de la especie y la humedad',
      fuente: 'FAO, Factores de conversión útiles, anexo 4',
      revisadoPor:
          'fuente_publica: FAO, Factores de conversión útiles (anexo 4): el peso de un estéreo va de 550 a 900 kg según especie y secado, https://www.fao.org/4/X5595S/X5595S19.htm'),
];
