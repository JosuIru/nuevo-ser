// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/obrador/denominaciones_pan.csv
// Generado: 2026-11-07
// Filas: 9 (0 firmadas por persona, 9 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

class DenominacionPan {
  const DenominacionPan(
      {required this.id,
      required this.nombre,
      required this.articulo,
      required this.requisito,
      this.salMaximaGramosPor100g});

  final String id;
  final String nombre;
  final String articulo;
  final String requisito;
  final double? salMaximaGramosPor100g;
}

const List<DenominacionPan> catalogoDenominacionesPan = [
  DenominacionPan(
      id: 'pan_comun',
      nombre: 'Pan común',
      articulo: 'art. 3',
      requisito:
          'Consumo habitual en las 24 h siguientes a la cocción; harina o harina integral de cereales, puede llevar salvado. Sal máxima 1,31 g/100 g por cloruros (1,66 g por sodio total), art. 11.2.c, obligatorio desde el 01/04/2022',
      salMaximaGramosPor100g: 1.31),
  DenominacionPan(
      id: 'pan_especial',
      nombre: 'Pan especial',
      articulo: 'art. 5',
      requisito:
          'No es pan común y cumple una condición de composición (harina tratada o ingrediente del art. 11.3) o de elaboración (rallado, en molde, formas especiales, escaldado parcial…)',
      salMaximaGramosPor100g: null),
  DenominacionPan(
      id: 'pan_integral',
      nombre: 'Pan integral / 100 % integral',
      articulo: 'art. 4.3.a',
      requisito:
          'Harina exclusivamente integral; se completa con el nombre del cereal',
      salMaximaGramosPor100g: 1.31),
  DenominacionPan(
      id: 'pan_con_harina_integral',
      nombre: 'Pan elaborado con harina integral X %',
      articulo: 'art. 4.3.b',
      requisito:
          'Harina no exclusivamente integral: indicar el % de harina integral sobre la harina total. Sin mínimo',
      salMaximaGramosPor100g: 1.31),
  DenominacionPan(
      id: 'pan_un_cereal',
      nombre: 'Pan 100 % de / pan de (cereal distinto del trigo)',
      articulo: 'art. 4.4.a',
      requisito:
          'Solo harina de un cereal distinto del trigo (centeno, espelta…)',
      salMaximaGramosPor100g: 1.31),
  DenominacionPan(
      id: 'pan_varios_cereales',
      nombre: 'Pan de (dos o más cereales)',
      articulo: 'art. 4.4.b',
      requisito:
          'Dos o más harinas de cereales: indicar el % de cada harina sobre el total. Sin mínimo',
      salMaximaGramosPor100g: 1.31),
  DenominacionPan(
      id: 'pan_multicereal',
      nombre: 'Pan multicereal',
      articulo: 'art. 6.2',
      requisito:
          'Tres o más harinas, al menos dos de cereales; cada una de las tres mayoritarias ≥ 10 %; las de cereales ≥ 30 % del total de harinas',
      salMaximaGramosPor100g: null),
  DenominacionPan(
      id: 'mencion_masa_madre',
      nombre: 'Mención «elaborado con masa madre»',
      articulo: 'art. 14.5',
      requisito:
          'Masa madre ≥ 5 % del peso total de harina de la masa final, sin aditivos; pH de la masa madre < 4,2; pH de la masa y del pan < 4,8; levadura ≤ 0,2 % de la harina solo en la última fase',
      salMaximaGramosPor100g: null),
  DenominacionPan(
      id: 'pan_sin_gluten',
      nombre: 'Pan sin gluten',
      articulo: 'art. 3 y art. 5.3',
      requisito:
          'Incluido desde el 01/03/2026 (RD 142/2026). La app nunca declara un producto sin gluten: lo decide el obrador con su control',
      salMaximaGramosPor100g: null),
];
