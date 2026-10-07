import 'calculo_transformacion.dart';

/// Tipos de contacto de la agenda del espacio.
const List<String> tiposContacto = [
  'matadero',
  'veterinaria',
  'experto',
  'comprador',
  'proveedor',
  'administracion',
  'otro',
];

/// Un contacto de la agenda compartida (matadero, veterinaria, persona
/// experta…). Cualquiera lo añade; lo edita quien lo añadió y coordinación.
class Contacto {
  Contacto({
    this.id,
    this.autorUid = '',
    this.nombre = '',
    this.tipo = 'otro',
    this.telefono = '',
    this.correo = '',
    this.localidad = '',
    this.notas = '',
  });

  final int? id;
  final String autorUid;
  final String nombre;
  final String tipo;
  final String telefono;
  final String correo;
  final String localidad;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'autor_uid': autorUid,
        'nombre': nombre,
        'tipo': tipo,
        'telefono': telefono,
        'correo': correo,
        'localidad': localidad,
        'notas': notas,
      };

  factory Contacto.fromMap(Map<String, Object?> mapa) => Contacto(
        id: mapa['id'] as int?,
        autorUid: (mapa['autor_uid'] as String?) ?? '',
        nombre: (mapa['nombre'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? 'otro',
        telefono: (mapa['telefono'] as String?) ?? '',
        correo: (mapa['correo'] as String?) ?? '',
        localidad: (mapa['localidad'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Rendimiento de referencia para la calculadora (p. ej. «Cordero lechal —
/// despiece: 50 % a canal, 85 % vendible»). Solo lo pone coordinación, en el
/// WordPress o en la app; llega a todo el espacio.
class RendimientoReferencia {
  RendimientoReferencia({
    this.id,
    this.nombre = '',
    this.rendimientoCanal = 0,
    this.rendimientoProducto = 100,
    this.fuente = '',
  });

  final int? id;
  final String nombre;
  final double rendimientoCanal;
  final double rendimientoProducto;

  /// De dónde sale el dato (matadero, asesoría, datos propios…).
  final String fuente;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'rendimiento_canal': rendimientoCanal,
        'rendimiento_producto': rendimientoProducto,
        'fuente': fuente,
      };

  factory RendimientoReferencia.fromMap(Map<String, Object?> mapa) =>
      RendimientoReferencia(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        rendimientoCanal: (mapa['rendimiento_canal'] as num?)?.toDouble() ?? 0,
        rendimientoProducto:
            (mapa['rendimiento_producto'] as num?)?.toDouble() ?? 100,
        fuente: (mapa['fuente'] as String?) ?? '',
      );
}

/// Un escenario guardado de la calculadora, dentro de un proyecto («venta en
/// canal», «despiece y venta directa»…) para comparar caminos.
class EscenarioTransformacion {
  EscenarioTransformacion({
    this.id,
    required this.proyectoId,
    this.nombre = '',
    this.pesoVivoKg = 0,
    this.animales = 1,
    this.rendimientoCanal = 0,
    this.rendimientoProducto = 100,
    this.precioKgCentimos = 0,
    this.costeSacrificioCentimos = 0,
    this.costeTransformacionKgCentimos = 0,
    this.otrosCostesCentimos = 0,
    this.notas = '',
    this.fechaMs = 0,
  });

  final int? id;
  final int proyectoId;
  final String nombre;
  final double pesoVivoKg;
  final int animales;
  final double rendimientoCanal;
  final double rendimientoProducto;
  final int precioKgCentimos;
  final int costeSacrificioCentimos;
  final int costeTransformacionKgCentimos;
  final int otrosCostesCentimos;
  final String notas;
  final int fechaMs;

  CalculoTransformacion get calculo => CalculoTransformacion(
        pesoVivoKg: pesoVivoKg,
        animales: animales,
        rendimientoCanalPorcentaje: rendimientoCanal,
        rendimientoProductoPorcentaje: rendimientoProducto,
        precioKgCentimos: precioKgCentimos,
        costeSacrificioCentimos: costeSacrificioCentimos,
        costeTransformacionKgCentimos: costeTransformacionKgCentimos,
        otrosCostesCentimos: otrosCostesCentimos,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'proyecto_id': proyectoId,
        'nombre': nombre,
        'peso_vivo_kg': pesoVivoKg,
        'animales': animales,
        'rendimiento_canal': rendimientoCanal,
        'rendimiento_producto': rendimientoProducto,
        'precio_kg_centimos': precioKgCentimos,
        'coste_sacrificio_centimos': costeSacrificioCentimos,
        'coste_transformacion_kg_centimos': costeTransformacionKgCentimos,
        'otros_costes_centimos': otrosCostesCentimos,
        'notas': notas,
        'fecha_ms': fechaMs,
      };

  factory EscenarioTransformacion.fromMap(Map<String, Object?> mapa) =>
      EscenarioTransformacion(
        id: mapa['id'] as int?,
        proyectoId: (mapa['proyecto_id'] as int?) ?? 0,
        nombre: (mapa['nombre'] as String?) ?? '',
        pesoVivoKg: (mapa['peso_vivo_kg'] as num?)?.toDouble() ?? 0,
        animales: (mapa['animales'] as int?) ?? 1,
        rendimientoCanal: (mapa['rendimiento_canal'] as num?)?.toDouble() ?? 0,
        rendimientoProducto:
            (mapa['rendimiento_producto'] as num?)?.toDouble() ?? 100,
        precioKgCentimos: (mapa['precio_kg_centimos'] as int?) ?? 0,
        costeSacrificioCentimos:
            (mapa['coste_sacrificio_centimos'] as int?) ?? 0,
        costeTransformacionKgCentimos:
            (mapa['coste_transformacion_kg_centimos'] as int?) ?? 0,
        otrosCostesCentimos: (mapa['otros_costes_centimos'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
      );
}
