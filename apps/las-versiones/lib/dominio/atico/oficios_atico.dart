import '../brecha.dart';
import '../catalogo_brechas.dart';

/// Los oficios del ático de Andrés (`docs/el-atico-de-andres.md`).
/// Repasan, no enseñan: sólo usan material de Brechas ya cerradas.
enum OficioAtico {
  tresFichas(
    titulo: 'Tres fichas',
    objeto: 'La balanza y las tres bandejas',
    descripcion: 'Tarjetas de investigaciones pasadas. ¿Sólido, Probable '
        'o Disputado?',
    habilidades: ['AH.03', 'AH.02', 'AH.07'],
  );
  // Siguientes: documentoRoto (HF.01-05) y cuerdaDelTiempo (CC.01-03).
  // Sólo se listan los oficios ya construidos: el ático no enseña
  // objetos que no hacen nada.

  const OficioAtico({
    required this.titulo,
    required this.objeto,
    required this.descripcion,
    required this.habilidades,
  });

  final String titulo;

  /// El objeto del ático que lo representa (la interfaz es objeto,
  /// doc 11 §1.1.9).
  final String objeto;
  final String descripcion;
  final List<String> habilidades;
}

/// Brechas cerradas por la Cronista, en el orden del catálogo.
List<Brecha> brechasCerradas(Set<String> flagsActivos) => [
      for (final brecha in CatalogoBrechas.todas)
        if (flagsActivos.contains(brecha.flagDeCompletado)) brecha,
    ];

/// El ático aparece en cuanto hay una Brecha cerrada.
bool aticoAbierto(Set<String> flagsActivos) =>
    brechasCerradas(flagsActivos).isNotEmpty;
