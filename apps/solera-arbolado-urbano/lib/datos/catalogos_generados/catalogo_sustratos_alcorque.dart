// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/arbolado-urbano/sustratos_alcorque.csv
// Generado: 2026-11-07
// Filas: 7 (0 revisadas, 7 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-arbolado-urbano && dart run tool/compilar_catalogos.dart

enum PermeabilidadAlcorque { alta, media, baja, nula }

enum FacilidadRiego { directa, indirecta, dificil }

class SustratoAlcorque {
  final String id;
  final String nombreCanonico;
  final PermeabilidadAlcorque permeabilidad;
  final FacilidadRiego facilidadRiego;
  final String notas;

  const SustratoAlcorque({
    required this.id,
    required this.nombreCanonico,
    required this.permeabilidad,
    required this.facilidadRiego,
    this.notas = '',
  });
}

const List<SustratoAlcorque> catalogoSustratosAlcorque = [
  SustratoAlcorque(
    id: 'mineral',
    nombreCanonico: 'Alcorque mineral',
    permeabilidad: PermeabilidadAlcorque.alta,
    facilidadRiego: FacilidadRiego.directa,
    notas: 'Tradicional — tierra+grava sin sellar. La opción más permeable y la mejor para el árbol pero requiere mantenimiento (malas hierbas|hojarasca)',
  ),
  SustratoAlcorque(
    id: 'organico',
    nombreCanonico: 'Alcorque con cubierta orgánica (acolchado)',
    permeabilidad: PermeabilidadAlcorque.alta,
    facilidadRiego: FacilidadRiego.directa,
    notas: 'Acolchado de corteza|paja u otro material orgánico — protege la humedad y reduce malas hierbas. Recomendado en alineaciones modernas',
  ),
  SustratoAlcorque(
    id: 'sellado_asfalto',
    nombreCanonico: 'Alcorque sellado con asfalto',
    permeabilidad: PermeabilidadAlcorque.nula,
    facilidadRiego: FacilidadRiego.dificil,
    notas: 'Antigua práctica frecuente en cascos urbanos viejos — el árbol sufre. Sustituible progresivamente por otras opciones al renovar pavimento',
  ),
  SustratoAlcorque(
    id: 'pavimento_poroso',
    nombreCanonico: 'Pavimento poroso',
    permeabilidad: PermeabilidadAlcorque.media,
    facilidadRiego: FacilidadRiego.indirecta,
    notas: 'Pavimento drenante (resina + áridos|hormigón poroso) que permite el riego. Estética urbana cuidada con buen comportamiento para el árbol',
  ),
  SustratoAlcorque(
    id: 'rejilla_metalica',
    nombreCanonico: 'Rejilla metálica',
    permeabilidad: PermeabilidadAlcorque.alta,
    facilidadRiego: FacilidadRiego.directa,
    notas: 'Rejilla circular o cuadrada sobre el alcorque — protege contra pisado y deja pasar agua. Frecuente en plazas pavimentadas',
  ),
  SustratoAlcorque(
    id: 'ajardinado_continuo',
    nombreCanonico: 'Ajardinado continuo',
    permeabilidad: PermeabilidadAlcorque.alta,
    facilidadRiego: FacilidadRiego.directa,
    notas: 'El árbol se planta en parterre verde continuo (sin alcorque definido). Solo en parques o medianas anchas',
  ),
  SustratoAlcorque(
    id: 'sin_alcorque',
    nombreCanonico: 'Sin alcorque definido',
    permeabilidad: PermeabilidadAlcorque.baja,
    facilidadRiego: FacilidadRiego.dificil,
    notas: 'Árbol plantado sin alcorque diferenciado o con alcorque desaparecido — habitual en árboles muy viejos donde el pavimento ha crecido',
  ),
];

SustratoAlcorque? sustratoAlcorquePorId(String id) {
  for (final s in catalogoSustratosAlcorque) {
    if (s.id == id) return s;
  }
  return null;
}

List<SustratoAlcorque> buscarSustratosAlcorque(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoSustratosAlcorque.where((s) {
    return _normalizar(s.id).contains(consultaNormalizada) ||
        _normalizar(s.nombreCanonico).contains(consultaNormalizada);
  }).toList();
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}

