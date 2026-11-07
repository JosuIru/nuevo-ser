import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../modelos/partida_planta.dart';
import 'hoja_formulario.dart';

// Campos de especie, plaga y sustancia. En el bloque 3 son texto libre; el
// bloque 6 los conecta con los catálogos.

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
          TextEditingController(text: nombreEspecieVisible(especieId)),
          TextEditingController(text: nombreBotanico));

  final TextEditingController especie;
  final TextEditingController botanico;

  EspecieElegida leer() =>
      EspecieElegida(especie.text.trim(), botanico.text.trim());

  void liberar() => liberarControladores([especie, botanico]);
}

List<Widget> camposEspecie(
        ControladoresEspecie controladores, StateSetter refrescar) =>
    [
      campoTexto(controladores.especie, SoleraL10n.t('vive.especie')),
      campoTexto(controladores.botanico, SoleraL10n.t('vive.nombre_botanico'),
          ayuda: SoleraL10n.t('vive.nombre_botanico_ayuda')),
    ];

String nombreEspecieVisible(String especieId) => especieId;

Widget campoProblema(TextEditingController controlador,
        List<PartidaPlanta> partidas, int? partidaId) =>
    campoTexto(controlador, SoleraL10n.t('vive.problema_fitosanitario'));

Widget campoPlagaRegulada(TextEditingController controlador,
        List<PartidaPlanta> partidas, int? partidaId) =>
    campoTexto(controlador, SoleraL10n.t('vive.plaga_regulada'));

Widget campoSustancia(TextEditingController controlador,
        List<PartidaPlanta> partidas, int? partidaId, StateSetter refrescar) =>
    campoTexto(controlador, SoleraL10n.t('vive.sustancia_activa'));

String? avisoPlazoSustancia(String textoSustancia) => null;

String idPlagaDesdeTexto(String texto) => texto.trim();

String idSustanciaDesdeTexto(String texto) => texto.trim();

String nombrePlagaVisible(String plagaId) => plagaId;

String nombreSustanciaVisible(String sustanciaId) => sustanciaId;
