import 'dart:io';

import 'package:pendientes/pendientes.dart';

/// Una vertical Larrea: la app, su carpeta de `content/` y la persona experta
/// que firma sus catálogos.
class Vertical {
  const Vertical(this.aplicacion, this.carpetaContenido, this.expertoCatalogos,
      this.nombreVisible);

  final String aplicacion;
  final String carpetaContenido;
  final Responsable expertoCatalogos;
  final String nombreVisible;
}

const List<Vertical> verticales = [
  Vertical('agro', 'agro', Responsable.asesorAgronomo, 'Larrea'),
  Vertical('solera-aceitera', 'aceitera', Responsable.asesorAgronomo,
      'Larrea Aceitera'),
  Vertical(
      'solera-apicola', 'apicola', Responsable.apicultor, 'Larrea Apícola'),
  Vertical('solera-arbolado-urbano', 'arbolado-urbano', Responsable.arborista,
      'Larrea Arbolado Urbano'),
  Vertical('solera-quesera', 'quesera', Responsable.quesero, 'Larrea Quesera'),
  Vertical('solera-viticultura', 'viticultura', Responsable.asesorAgronomo,
      'Larrea Viticultura'),
  Vertical('solera-zunbeltz', 'zunbeltz', Responsable.veterinario,
      'Solera Zunbeltz'),
];

/// Persona experta que firma los catálogos de una vertical que no está en
/// [verticales], por palabras de su nombre. Sin pista: asesor agrónomo.
const Map<String, Responsable> _expertoPorPalabra = {
  'ganad': Responsable.veterinario,
  'apic': Responsable.apicultor,
  'queser': Responsable.quesero,
  'obrador': Responsable.tecnicoSeguridadAlimentaria,
  'arbolado': Responsable.arborista,
};

Responsable _expertoDeducido(String carpeta) {
  for (final entrada in _expertoPorPalabra.entries) {
    if (carpeta.contains(entrada.key)) return entrada.value;
  }
  return Responsable.asesorAgronomo;
}

String _nombreVisibleDeducido(String carpeta) =>
    'Larrea ${carpeta.split('-').map(
          (palabra) => palabra.isEmpty
              ? palabra
              : '${palabra[0].toUpperCase()}${palabra.substring(1)}',
        ).join(' ')}';

/// Las de [verticales] más cualquier `apps/solera-*` de [raiz] que no esté
/// dada de alta, para que una vertical nueva funcione sin tocar este archivo.
List<Vertical> descubrirVerticales(String raiz) {
  final resultado = [...verticales];
  final conocidas = verticales.map((vertical) => vertical.aplicacion).toSet();
  final carpetaApps = Directory('$raiz/apps');
  if (!carpetaApps.existsSync()) return resultado;
  final nuevas = carpetaApps
      .listSync()
      .whereType<Directory>()
      .map((carpeta) => carpeta.path.split(Platform.pathSeparator).last)
      .where((nombre) =>
          nombre.startsWith('solera-') && !conocidas.contains(nombre))
      .toList()
    ..sort();
  for (final aplicacion in nuevas) {
    final carpeta = aplicacion.substring('solera-'.length);
    resultado.add(Vertical(aplicacion, carpeta, _expertoDeducido(carpeta),
        _nombreVisibleDeducido(carpeta)));
  }
  return resultado;
}

/// Acepta `aceitera` o `solera-aceitera`. Con [raiz], también las verticales
/// descubiertas en `apps/solera-*`.
Vertical verticalPorNombre(String nombre, {String? raiz}) {
  final candidatas = raiz == null ? verticales : descubrirVerticales(raiz);
  for (final vertical in candidatas) {
    if (vertical.aplicacion == nombre || vertical.carpetaContenido == nombre) {
      return vertical;
    }
  }
  throw ArgumentError.value(nombre, 'vertical',
      'no existe; usa una de: ${candidatas.map((v) => v.carpetaContenido).join(', ')}');
}

class SeccionComprobacion {
  SeccionComprobacion(this.responsable);

  final Responsable responsable;
  final List<Bloqueo> bloqueos = [];
  final List<SelloProvisional> sellos = [];
  final List<EstadoCatalogo> catalogos = [];

  bool get vacia => bloqueos.isEmpty && sellos.isEmpty && catalogos.isEmpty;
}

class ListaComprobacion {
  ListaComprobacion(this.vertical, this.generadaEn, this.secciones);

  final Vertical vertical;
  final DateTime generadaEn;
  final List<SeccionComprobacion> secciones;
}

/// Agrupa por responsable lo pendiente de [vertical]: bloqueos abiertos,
/// sellos PROVISIONAL y catálogos sin firma (estos, a su experto).
ListaComprobacion construirListaComprobacion(
    Inventario inventario, Vertical vertical,
    {Responsable? soloResponsable}) {
  final secciones = <Responsable, SeccionComprobacion>{};
  SeccionComprobacion seccionDe(Responsable responsable) => secciones
      .putIfAbsent(responsable, () => SeccionComprobacion(responsable));

  for (final bloqueo in inventario.bloqueosAbiertos
      .where((bloqueo) => bloqueo.aplicacion == vertical.aplicacion)) {
    for (final responsable in bloqueo.responsables) {
      seccionDe(responsable).bloqueos.add(bloqueo);
    }
  }
  for (final sello in inventario.sellos
      .where((sello) => sello.aplicacion == vertical.aplicacion)) {
    for (final responsable in sello.responsables) {
      seccionDe(responsable).sellos.add(sello);
    }
  }
  for (final catalogo in inventario.catalogos.where((catalogo) =>
      catalogo.vertical == vertical.carpetaContenido &&
      catalogo.tieneColumnaRevision)) {
    seccionDe(vertical.expertoCatalogos).catalogos.add(catalogo);
  }

  final ordenadas = secciones.values
      .where((seccion) =>
          !seccion.vacia &&
          (soloResponsable == null || seccion.responsable == soloResponsable))
      .toList()
    ..sort((a, b) => a.responsable.index.compareTo(b.responsable.index));
  return ListaComprobacion(vertical, inventario.generadoEn, ordenadas);
}

/// Lo que falta para poder retirar los sellos PROVISIONAL de [vertical].
/// Lista vacía = todo firmado y sin bloqueos abiertos. Retirar el literal
/// del código sigue siendo un cambio manual (lo protege
/// `sello_provisional_test.dart`).
List<String> comprobarRetiradaDeSellos(
    Inventario inventario, Vertical vertical) {
  final faltas = <String>[];
  for (final catalogo in inventario.catalogos.where((catalogo) =>
      catalogo.vertical == vertical.carpetaContenido &&
      catalogo.pendienteDePersona)) {
    faltas.add('Catálogo ${catalogo.nombreArchivo}: '
        '${catalogo.filas - catalogo.revisadasPorPersona} de ${catalogo.filas} '
        'filas sin firma de ${vertical.expertoCatalogos.nombreVisible}');
  }
  for (final bloqueo in inventario.bloqueosAbiertos
      .where((bloqueo) => bloqueo.aplicacion == vertical.aplicacion)) {
    final responsables =
        bloqueo.responsables.map((r) => r.nombreVisible).join(', ');
    faltas.add('Bloqueo «${bloqueo.titulo}» '
        '(BLOQUEOS-PENDIENTES.md:${bloqueo.linea}) → $responsables');
  }
  return faltas;
}
