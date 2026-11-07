// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aromaticas/plagas_pam.csv
// Generado: 2026-11-07
// Filas: 10 (0 firmadas por persona, 10 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aromaticas && dart run tool/compilar_catalogos.dart

class PlagaCatalogo {
  const PlagaCatalogo({
    required this.id,
    required this.especies,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.sintomas,
    required this.revisadoPor,
  });

  final String id;
  final List<String> especies;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final String sintomas;
  final String revisadoPor;
}

const List<PlagaCatalogo> catalogoPlagas = [
  PlagaCatalogo(id: 'cecidomia_lavandin', especies: ['lavanda', 'lavandin'], nombre: 'Cecidomia del lavandín', nombreCientifico: '', tipo: 'plaga', sintomas: 'Las larvas secan los ramos; la necrosis se acumula de un año a otro, baja el rendimiento y acorta la vida de la plantación', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 6'),
  PlagaCatalogo(id: 'arima_marginata', especies: ['lavanda', 'lavandin', 'tomillo_comun', 'salvia_esclarea'], nombre: 'Arima', nombreCientifico: 'Arima marginata', tipo: 'plaga', sintomas: 'Ataques de larvas desde marzo', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 7'),
  PlagaCatalogo(id: 'cochinilla_lavandin', especies: ['lavanda', 'lavandin'], nombre: 'Cochinilla del lavandín', nombreCientifico: '', tipo: 'plaga', sintomas: 'Hojas crispadas por las picaduras; en ataques fuertes los tallos se deforman y dan espigas alteradas e improductivas', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 7'),
  PlagaCatalogo(id: 'orugas_filofagas', especies: ['lavanda', 'lavandin', 'salvia_esclarea'], nombre: 'Orugas filófagas (tipo tortrícido)', nombreCientifico: '', tipo: 'plaga', sintomas: 'Orugas que comen las hojas jóvenes y las unen con hilos de seda; la planta toma un aspecto grisáceo', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 8'),
  PlagaCatalogo(id: 'noctuidos', especies: ['salvia_esclarea', 'lavanda', 'lavandin'], nombre: 'Noctuidos', nombreCientifico: 'Autographa gamma, Heliothis spp.', tipo: 'plaga', sintomas: 'Orugas con daños fuertes en siembras de salvia esclarea; capturas de mariposas en trampas', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 9'),
  PlagaCatalogo(id: 'crisomela_americana', especies: ['lavanda', 'lavandin'], nombre: 'Crisomela americana', nombreCientifico: 'Chrysolina americana', tipo: 'plaga', sintomas: 'Presión baja en 2025; el boletín no describe síntomas', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 4 (presión baja)'),
  PlagaCatalogo(id: 'hyalesthes_obsoletus', especies: ['lavanda', 'lavandin'], nombre: 'Cicadela del stolbur', nombreCientifico: 'Hyalesthes obsoletus', tipo: 'vector', sintomas: 'Cicadela que transmite el fitoplasma del stolbur cuando lo porta; se sigue con placas engomadas', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, pp. 10-11'),
  PlagaCatalogo(id: 'decaimiento_stolbur', especies: ['lavanda', 'lavandin'], nombre: 'Decaimiento por fitoplasma del stolbur', nombreCientifico: 'Fitoplasma del stolbur', tipo: 'enfermedad', sintomas: 'Plantas que decaen y mueren, a veces desde la primera corta; en 2025, del 20 al 50 % de mortalidad en algunas parcelas', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 12'),
  PlagaCatalogo(id: 'virus_mosaico_alfalfa', especies: ['lavandin'], nombre: 'Virus del mosaico de la alfalfa (AMV)', nombreCientifico: 'Alfalfa mosaic virus', tipo: 'enfermedad', sintomas: 'Amarilleos; sobre todo en plantas de vivero no certificado o tras alfalfa', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 12'),
  PlagaCatalogo(id: 'clorosis_ferrica', especies: ['lavandin'], nombre: 'Clorosis férrica', nombreCientifico: '', tipo: 'fisiopatia', sintomas: 'Hojas amarillas por bloqueo del hierro; crecimiento lento y, en casos extremos, muerte de la planta', revisadoPor: 'fuente_publica: BSV PAPAM PACA bilan 2025, p. 8'),
];
