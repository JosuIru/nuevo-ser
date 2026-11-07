// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aromaticas/rendimientos_orientativos.csv
// Generado: 2026-11-07
// Filas: 29 (0 firmadas por persona, 29 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aromaticas && dart run tool/compilar_catalogos.dart

class RendimientoOrientativo {
  const RendimientoOrientativo({
    required this.id,
    required this.especieId,
    required this.producto,
    required this.estadoPlanta,
    required this.minimo,
    required this.maximo,
    required this.unidad,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String especieId;
  final String producto;
  final String estadoPlanta;
  final double? minimo;
  final double? maximo;
  final String unidad;
  final String fuente;
  final String revisadoPor;
}

const List<RendimientoOrientativo> catalogoRendimientos = [
  RendimientoOrientativo(id: 'estragon_aceite', especieId: 'estragon', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 1.0, maximo: 4.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 1-3 (b), 3-4 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'hinojo_aceite', especieId: 'hinojo', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 30.0, maximo: 40.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 30-40 (b), sobre grano', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'hiperico_aceite', especieId: 'hiperico', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 0.1, maximo: 2.5, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 2,5 (b), 0,1 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'hisopo_aceite', especieId: 'hisopo', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 0.8, maximo: 2.5, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 0,8-2,5 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'espliego_aceite', especieId: 'espliego', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 4.0, maximo: 8.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 4-8 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'hierba_luisa_aceite', especieId: 'hierba_luisa', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 0.7, maximo: 1.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 0,7-1 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'melisa_aceite', especieId: 'melisa', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 0.1, maximo: 0.3, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 0,1-0,3 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'menta_piperita_aceite', especieId: 'menta_piperita', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 1.5, maximo: 6.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 1,5-4,0 (b), 2-6 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'albahaca_aceite', especieId: 'albahaca', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 0.2, maximo: 1.3, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 0,2-1,3 (b), 0,2-0,7 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'oregano_aceite', especieId: 'oregano', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 0.7, maximo: 3.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: hierba 0,7-3 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'oregano_aceite_seca', especieId: 'oregano', producto: 'aceite_esencial', estadoPlanta: 'seca', minimo: 2.0, maximo: 7.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: hoja + flor seca 2-7 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'romero_aceite', especieId: 'romero', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 2.0, maximo: 6.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 28: 2-6 (b), 5-6 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'salvia_aceite', especieId: 'salvia', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 3.0, maximo: 6.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 29: 3-6 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'ajedrea_aceite', especieId: 'ajedrea', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 2.0, maximo: 3.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 29: 2-3 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'tomillo_comun_aceite', especieId: 'tomillo_comun', producto: 'aceite_esencial', estadoPlanta: 'fresca', minimo: 1.0, maximo: 4.0, unidad: 'g/kg', fuente: 'Tabla 5, p. 29: 1-3 (b), 3-4 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 5'),
  RendimientoOrientativo(id: 'milenrama_secado', especieId: 'milenrama', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 16.7, maximo: 33.3, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (5-6):1 (b), (3-3,6):1 (a)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'estragon_secado', especieId: 'estragon', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 12.5, maximo: 13.3, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (7,5-8):1 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'hiperico_secado', especieId: 'hiperico', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 20.0, maximo: 25.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (4-5):1 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'hisopo_secado', especieId: 'hisopo', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 40.0, maximo: 40.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: 2,5:1 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'espliego_secado', especieId: 'espliego', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 40.0, maximo: 50.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (2-2,5):1 (a), flor', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'lavanda_secado', especieId: 'lavanda', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 50.0, maximo: 50.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: 2:1 (a), flor', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'hierba_luisa_secado', especieId: 'hierba_luisa', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 25.0, maximo: 33.3, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (3-4):1 (c)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'melisa_secado', especieId: 'melisa', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 20.0, maximo: 20.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: 5:1 (a)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'menta_piperita_secado', especieId: 'menta_piperita', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 16.7, maximo: 16.7, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: 6:1 (a)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'albahaca_secado', especieId: 'albahaca', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 10.0, maximo: 10.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: 10:1 (a)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'romero_secado', especieId: 'romero', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 12.5, maximo: 14.3, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (7-8):1 (a), hoja', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'salvia_secado', especieId: 'salvia', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 20.0, maximo: 20.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: 5:1 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'ajedrea_secado', especieId: 'ajedrea', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 16.7, maximo: 25.0, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 21: (4-6):1 (a)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
  RendimientoOrientativo(id: 'tomillo_comun_secado', especieId: 'tomillo_comun', producto: 'planta_seca', estadoPlanta: 'fresca', minimo: 25.0, maximo: 33.3, unidad: 'kg/100 kg', fuente: 'Tabla 8, p. 22: (3-4):1 (b)', revisadoPor: 'fuente_publica: CTFC Transformación PAM, tabla 8'),
];
