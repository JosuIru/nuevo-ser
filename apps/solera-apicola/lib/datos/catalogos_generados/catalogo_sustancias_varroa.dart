// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/apicola/sustancias_varroa.csv
// Generado: 2026-11-07
// Filas: 8 (0 revisadas, 8 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-apicola && dart run tool/compilar_catalogos.dart

/// Familia química de la sustancia activa.
enum FamiliaSustanciaVarroa { organica, sintetica, naturalAceiteEsencial }

/// Vehículo de aplicación principal. Cada uno requiere material distinto.
enum VehiculoSustanciaVarroa { sublimacion, goteo, sandwich, tiraPolimero, nebulizacion }

/// Eficacia orientativa contra varroa en condiciones ideales.
/// ⚠ La eficacia real depende de temperatura, humedad y carga de cría.
enum EficaciaSustanciaVarroa { baja, media, alta, muyAlta }

/// Ventana óptima de aplicación durante el ciclo apícola.
enum VentanaAplicacionVarroa { invernada, primavera, otono, sinPostura, conPostura }

class SustanciaVarroa {
  final String id;
  final String nombreCanonico;
  final FamiliaSustanciaVarroa familia;
  final VehiculoSustanciaVarroa vehiculoPrincipal;
  final EficaciaSustanciaVarroa eficaciaOrientativa;
  /// Plazo de seguridad orientativo en días. ⚠ Verificar etiqueta del producto.
  final int plazoSeguridadDias;
  final bool autorizadaEcologico;
  final VentanaAplicacionVarroa ventanaAplicacion;
  final String notas;

  const SustanciaVarroa({
    required this.id,
    required this.nombreCanonico,
    required this.familia,
    required this.vehiculoPrincipal,
    required this.eficaciaOrientativa,
    required this.plazoSeguridadDias,
    required this.autorizadaEcologico,
    required this.ventanaAplicacion,
    this.notas = '',
  });
}

const List<SustanciaVarroa> catalogoSustanciasVarroa = [
  SustanciaVarroa(
    id: 'acido_oxalico',
    nombreCanonico: 'Ácido oxálico (vaporización)',
    familia: FamiliaSustanciaVarroa.organica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.sublimacion,
    eficaciaOrientativa: EficaciaSustanciaVarroa.muyAlta,
    plazoSeguridadDias: 0,
    autorizadaEcologico: true,
    ventanaAplicacion: VentanaAplicacionVarroa.sinPostura,
    notas: 'Solo con medicamento autorizado para vaporización/sublimación (no ácido oxálico genérico). Colonias sin cría (invernada o enjambres sin cría) y sin alzas. Ficha: no recomendada en verano. EPI respiratorio. Tiempo de espera en miel: 0 d.',
  ),
  SustanciaVarroa(
    id: 'acido_oxalico_goteo',
    nombreCanonico: 'Ácido oxálico (goteo)',
    familia: FamiliaSustanciaVarroa.organica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.goteo,
    eficaciaOrientativa: EficaciaSustanciaVarroa.alta,
    plazoSeguridadDias: 0,
    autorizadaEcologico: true,
    ventanaAplicacion: VentanaAplicacionVarroa.sinPostura,
    notas: 'Goteo en jarabe según la ficha del medicamento autorizado. Colonias sin cría y sin alzas; no usar durante la producción de miel. Tiempo de espera en miel: 0 d.',
  ),
  SustanciaVarroa(
    id: 'acido_formico',
    nombreCanonico: 'Ácido fórmico',
    familia: FamiliaSustanciaVarroa.organica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.tiraPolimero,
    eficaciaOrientativa: EficaciaSustanciaVarroa.alta,
    plazoSeguridadDias: 0,
    autorizadaEcologico: true,
    ventanaAplicacion: VentanaAplicacionVarroa.conPostura,
    notas: 'Autorizado en tiras de gel que liberan por evaporación (el compilador no tiene ese vehículo: se usa tira_polimero) y en dispersión por goteo en mezcla con oxálico. Nebulización NO autorizada. Penetra en la cría operculada. Temperatura diurna 10–29,5 °C; retirar alzas con miel. Con calor: riesgo de pérdida de reina y cría.',
  ),
  SustanciaVarroa(
    id: 'timol',
    nombreCanonico: 'Timol',
    familia: FamiliaSustanciaVarroa.naturalAceiteEsencial,
    vehiculoPrincipal: VehiculoSustanciaVarroa.tiraPolimero,
    eficaciaOrientativa: EficaciaSustanciaVarroa.media,
    plazoSeguridadDias: 0,
    autorizadaEcologico: true,
    ventanaAplicacion: VentanaAplicacionVarroa.otono,
    notas: 'Aceite esencial del tomillo. Autorizado en gel o en tira de esponja impregnada (se usa tira_polimero por ser el vehículo más cercano). Eficacia variable con la temperatura (15–30 °C). No usar durante la mielada; tratar tras retirar alzas. Tiempo de espera en miel: 0 d.',
  ),
  SustanciaVarroa(
    id: 'amitraz',
    nombreCanonico: 'Amitraz',
    familia: FamiliaSustanciaVarroa.sintetica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.tiraPolimero,
    eficaciaOrientativa: EficaciaSustanciaVarroa.muyAlta,
    plazoSeguridadDias: 7,
    autorizadaEcologico: false,
    ventanaAplicacion: VentanaAplicacionVarroa.otono,
    notas: 'Acaricida sintético. Tiempo de espera en miel 0–7 d según medicamento (la fila usa el máximo). No usar durante el flujo de miel; no extraer miel de la cámara de cría. Riesgo de residuos en cera. Resistencias documentadas en Europa.',
  ),
  SustanciaVarroa(
    id: 'flumetrina',
    nombreCanonico: 'Flumetrina',
    familia: FamiliaSustanciaVarroa.sintetica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.tiraPolimero,
    eficaciaOrientativa: EficaciaSustanciaVarroa.alta,
    plazoSeguridadDias: 0,
    autorizadaEcologico: false,
    ventanaAplicacion: VentanaAplicacionVarroa.otono,
    notas: 'Piretroide sintético. Tiempo de espera en miel: 0 d; no tratar durante la mielada; otros productos de la colmena no consumibles hasta la primavera siguiente (según ficha). Resistencias documentadas — alternar con familias distintas.',
  ),
  SustanciaVarroa(
    id: 'fluvalinato',
    nombreCanonico: 'Tau-fluvalinato',
    familia: FamiliaSustanciaVarroa.sintetica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.tiraPolimero,
    eficaciaOrientativa: EficaciaSustanciaVarroa.alta,
    plazoSeguridadDias: 0,
    autorizadaEcologico: false,
    ventanaAplicacion: VentanaAplicacionVarroa.otono,
    notas: 'Piretroide sintético. Tiempo de espera en miel: 0 d. Ficha: mejor en primavera antes de las mieladas o en otoño tras la cosecha con poca cría (la columna solo admite una ventana). No reciclar la cera tratada. Resistencias documentadas — usar con prudencia.',
  ),
  SustanciaVarroa(
    id: 'mezcla_oxalico_glicerol',
    nombreCanonico: 'Ácido oxálico en tira (excipiente glicerol)',
    familia: FamiliaSustanciaVarroa.organica,
    vehiculoPrincipal: VehiculoSustanciaVarroa.tiraPolimero,
    eficaciaOrientativa: EficaciaSustanciaVarroa.alta,
    plazoSeguridadDias: 0,
    autorizadaEcologico: true,
    ventanaAplicacion: VentanaAplicacionVarroa.otono,
    notas: 'Solo el medicamento autorizado (tira de polipropileno); las tiras caseras de cartón impregnado NO están autorizadas. 6 semanas de tratamiento; sin alzas; no cosechar miel durante el tratamiento. Otoño con las abejas activas antes de la piña invernal; más eficaz con poca o ninguna cría.',
  ),
];

SustanciaVarroa? sustanciaVarroaPorId(String id) {
  for (final s in catalogoSustanciasVarroa) {
    if (s.id == id) return s;
  }
  return null;
}

/// Filtra sustancias por ventana de aplicación. Útil cuando el apicultor
/// abre el formulario en pleno otoño y quiere ver qué sustancias proceden.
List<SustanciaVarroa> sustanciasParaVentana(VentanaAplicacionVarroa ventana) {
  return catalogoSustanciasVarroa
      .where((s) => s.ventanaAplicacion == ventana)
      .toList();
}

/// Sólo sustancias autorizadas en producción ecológica.
List<SustanciaVarroa> sustanciasEcologico() {
  return catalogoSustanciasVarroa.where((s) => s.autorizadaEcologico).toList();
}

List<SustanciaVarroa> buscarSustanciasVarroa(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoSustanciasVarroa.where((s) {
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

