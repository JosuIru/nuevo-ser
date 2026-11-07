// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/obrador/controles_tipo.csv
// Generado: 2026-11-07
// Filas: 11 (0 firmadas por persona, 0 con alguna revisión, 11 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

class ControlTipo {
  const ControlTipo(
      {required this.id,
      required this.tipo,
      required this.elemento,
      required this.frecuenciaSugerida});

  final String id;
  final String tipo;
  final String elemento;
  final String frecuenciaSugerida;
}

const List<ControlTipo> catalogoControlesTipo = [
  ControlTipo(
      id: 'camara_refrigeracion',
      tipo: 'temperatura',
      elemento: 'Cámara de refrigeración',
      frecuenciaSugerida: 'diaria'),
  ControlTipo(
      id: 'congelador',
      tipo: 'temperatura',
      elemento: 'Congelador',
      frecuenciaSugerida: 'diaria'),
  ControlTipo(
      id: 'vitrina',
      tipo: 'temperatura',
      elemento: 'Vitrina refrigerada del mostrador',
      frecuenciaSugerida: 'diaria'),
  ControlTipo(
      id: 'recepcion_harina',
      tipo: 'proveedor',
      elemento: 'Recepción de harina',
      frecuenciaSugerida: 'cada entrega'),
  ControlTipo(
      id: 'recepcion_refrigerados',
      tipo: 'proveedor',
      elemento: 'Recepción de refrigerados (mantequilla / nata / huevo)',
      frecuenciaSugerida: 'cada entrega'),
  ControlTipo(
      id: 'limpieza_obrador',
      tipo: 'limpieza',
      elemento: 'Superficies y suelo del obrador',
      frecuenciaSugerida: 'diaria'),
  ControlTipo(
      id: 'limpieza_amasadora',
      tipo: 'limpieza',
      elemento: 'Amasadora',
      frecuenciaSugerida: 'diaria'),
  ControlTipo(
      id: 'limpieza_horno',
      tipo: 'limpieza',
      elemento: 'Horno',
      frecuenciaSugerida: 'semanal'),
  ControlTipo(
      id: 'limpieza_camaras',
      tipo: 'limpieza',
      elemento: 'Cámaras y congelador',
      frecuenciaSugerida: 'mensual'),
  ControlTipo(
      id: 'revision_cebos',
      tipo: 'plagas',
      elemento: 'Cebos y trampas',
      frecuenciaSugerida: 'mensual'),
  ControlTipo(
      id: 'formacion_manipuladores',
      tipo: 'formacion',
      elemento: 'Formación de manipuladores',
      frecuenciaSugerida: 'anual'),
];
