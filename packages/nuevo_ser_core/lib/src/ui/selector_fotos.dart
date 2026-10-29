import 'dart:io';

import 'package:flutter/material.dart';

import '../foto/gestor_fotos.dart';

/// Selector horizontal de fotos para formularios — botón "+" al final
/// para añadir desde cámara o galería, miniaturas con botón borrar.
///
/// Genérico en la suite Larrea (Viticultura, Apícola, Arbolado Urbano)
/// y candidato a usarlo cualquier otra app del monorepo que necesite
/// adjuntar fotos a entidades.
///
/// Las rutas se gestionan externamente por la pantalla anfitriona —
/// este widget sólo notifica cambios vía `alCambiar(nuevasRutas)`. La
/// pantalla decide cuándo persiste (típicamente al guardar el
/// formulario, codificando con `GestorFotos.codificar(rutas)`).
class SelectorFotos extends StatelessWidget {
  final List<String> rutas;
  final ValueChanged<List<String>> alCambiar;
  final double altura;

  const SelectorFotos({
    super.key,
    required this.rutas,
    required this.alCambiar,
    this.altura = 96,
  });

  Future<void> _alPulsarAnadir(BuildContext context) async {
    final fuente = await showModalBottomSheet<FuenteFoto>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, FuenteFoto.camara),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, FuenteFoto.galeria),
            ),
          ],
        ),
      ),
    );
    if (fuente == null) return;
    final nuevas = await GestorFotos.tomarOSeleccionar(fuente: fuente);
    if (nuevas.isEmpty) return;
    alCambiar([...rutas, ...nuevas]);
  }

  void _alBorrar(int indice) {
    final actualizadas = [...rutas]..removeAt(indice);
    GestorFotos.borrarSiExiste(rutas[indice]);
    alCambiar(actualizadas);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altura,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rutas.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == rutas.length) {
            return InkWell(
              onTap: () => _alPulsarAnadir(context),
              child: Container(
                width: altura,
                height: altura,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 24),
                    SizedBox(height: 4),
                    Text('Foto', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(rutas[i]),
                  width: altura,
                  height: altura,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: altura,
                    height: altura,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: InkWell(
                  onTap: () => _alBorrar(i),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
