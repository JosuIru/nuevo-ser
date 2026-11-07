import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/catalogos.dart';
import '../modelos/partida_planta.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

// Campos de especie, plaga y sustancia conectados con los catálogos de
// content/vivero/. Lo que no está en el catálogo se guarda como texto libre.

/// Especie elegida: id (del catálogo o texto libre) y nombre botánico.
class EspecieElegida {
  const EspecieElegida(this.especieId, this.nombreBotanico);
  final String especieId;
  final String nombreBotanico;
}

class ControladoresEspecie {
  ControladoresEspecie._(this.especie, this.botanico);

  factory ControladoresEspecie.desde(
          {required String especieId, required String nombreBotanico}) =>
      ControladoresEspecie._(
          TextEditingController(text: nombreEspecie(especieId)),
          TextEditingController(text: nombreBotanico));

  final TextEditingController especie;
  final TextEditingController botanico;

  /// El nombre botánico escrito manda; si está vacío, el del catálogo.
  EspecieElegida leer() {
    final especieId = idDesdeTexto(especie.text, opcionesEspecies());
    final botanicoEscrito = botanico.text.trim();
    return EspecieElegida(
        especieId,
        botanicoEscrito.isNotEmpty
            ? botanicoEscrito
            : especiePorId(especieId)?.nombreBotanico ?? '');
  }

  void liberar() => liberarControladores([especie, botanico]);
}

List<Widget> camposEspecie(
        ControladoresEspecie controladores, StateSetter refrescar) =>
    [
      CampoCatalogo(
        controlador: controladores.especie,
        opciones: opcionesEspecies(),
        etiqueta: SoleraL10n.t('vive.especie'),
        alElegir: (opcion) => refrescar(() {
          controladores.botanico.text =
              especiePorId(opcion.id)?.nombreBotanico ?? '';
        }),
      ),
      campoTexto(controladores.botanico, SoleraL10n.t('vive.nombre_botanico'),
          ayuda: SoleraL10n.t('vive.nombre_botanico_ayuda')),
    ];

String nombreEspecieVisible(String especieId) => nombreEspecie(especieId);

PartidaPlanta? _partida(List<PartidaPlanta> partidas, int? partidaId) =>
    partidas.where((partida) => partida.id == partidaId).firstOrNull;

Widget campoProblema(TextEditingController controlador,
        List<PartidaPlanta> partidas, int? partidaId) =>
    CampoCatalogo(
      controlador: controlador,
      opciones: opcionesPlagas(_partida(partidas, partidaId)?.especieId),
      etiqueta: SoleraL10n.t('vive.problema_fitosanitario'),
    );

Widget campoPlagaRegulada(TextEditingController controlador,
    List<PartidaPlanta> partidas, int? partidaId) {
  final partida = _partida(partidas, partidaId);
  return CampoCatalogo(
    controlador: controlador,
    opciones: opcionesPlagasReguladas(
        especieId: partida?.especieId,
        nombreBotanico: partida?.nombreBotanico ?? ''),
    etiqueta: SoleraL10n.t('vive.plaga_regulada'),
    ayuda: SoleraL10n.t('vive.plaga_regulada_ayuda'),
  );
}

/// Sustancia activa con las del grupo de cultivo de la partida primero.
/// Debajo, el plazo del registro y si el uso no está en el catálogo.
Widget campoSustancia(
    TextEditingController controlador,
    TextEditingController problema,
    List<PartidaPlanta> partidas,
    int? partidaId,
    StateSetter refrescar) {
  final partida = _partida(partidas, partidaId);
  final plagaId = idPlagaDesdeTexto(problema.text);
  final sustanciaId = idSustanciaDesdeTexto(controlador.text);
  final autorizado = partida == null
      ? null
      : usoAutorizado(
          especieId: partida.especieId,
          sustanciaId: sustanciaId,
          plagaId: plagaId);
  return CampoCatalogo(
    controlador: controlador,
    opciones: opcionesSustancias(partida?.especieId, plagaId: plagaId),
    etiqueta: SoleraL10n.t('vive.sustancia_activa'),
    ayuda: autorizado == false
        ? SoleraL10n.t('vive.uso_no_en_catalogo')
        : SoleraL10n.t('vive.sustancia_ayuda'),
    alElegir: (_) => refrescar(() {}),
  );
}

/// «Registro: hasta 14 días (7–14)…» si la sustancia está en el catálogo.
/// Es un aviso: el campo no se rellena, manda la etiqueta.
String? avisoPlazoSustancia(String textoSustancia) {
  final sustancia = sustanciaPorId(idSustanciaDesdeTexto(textoSustancia));
  if (sustancia == null) return null;
  return SoleraL10n.tf('vive.plazo_registro', {
    'rango': sustancia.plazoSeguridadRegistro,
  });
}

String idPlagaDesdeTexto(String texto) => idDesdeTexto(texto, [
      ...opcionesPlagas(null),
      ...opcionesPlagasReguladas(),
    ]);

String idSustanciaDesdeTexto(String texto) =>
    idDesdeTexto(texto, opcionesSustancias(null));

String nombrePlagaVisible(String plagaId) => nombrePlaga(plagaId);

String nombreSustanciaVisible(String sustanciaId) =>
    nombreSustancia(sustanciaId);
