/// Interpretación de lo que lee el escáner de códigos de barras para
/// convertirlo en el crotal de un animal.
///
/// Identificación oficial en España: dos letras de país + 12 dígitos
/// (`ES012345678901`), igual para bovino (DIB) y ovino/caprino (REIA). En el
/// código de barras del DIB viene el crotal completo o solo los 12 dígitos;
/// un lector RFID da el código numérico ISO, con el país como 724 (España)
/// delante de los 12 dígitos.
///
/// PROVISIONAL: el contenido exacto del código de barras del DIB se ha
/// deducido de la documentación, no de un DIB real de Zunbeltz. Si en campo
/// el escáner devuelve otra cosa, ajustar aquí y en los tests.
library;

/// Resultado de interpretar un código leído.
class LecturaCrotal {
  const LecturaCrotal({required this.identificacion, required this.reconocido});

  /// Lo que se propone guardar como identificación del animal.
  final String identificacion;

  /// `true` si el código tiene la forma de un crotal oficial. Si no, se
  /// ofrece igualmente lo leído (limpio) para que la persona lo confirme.
  final bool reconocido;
}

/// Códigos numéricos ISO 3166-1 de país que puede traer una lectura RFID,
/// con su prefijo de dos letras.
const _paisesIsoNumericos = {
  '724': 'ES',
  '250': 'FR',
  '620': 'PT',
  '020': 'AD',
};

final _crotalOficial = RegExp(r'^([A-Z]{2})(\d{12})$');
final _soloDigitos = RegExp(r'^\d+$');

/// Convierte lo leído en un crotal. Quita espacios, guiones y puntos,
/// pasa a mayúsculas y reconoce estas formas:
/// - `ES012345678901` (crotal completo);
/// - `012345678901` (solo los 12 dígitos → se antepone `ES`);
/// - `724012345678901` (RFID: país numérico + 12 dígitos → `ES…`).
///
/// Cualquier otra cosa se devuelve limpia y sin reconocer. Vacío si no hay
/// nada aprovechable.
LecturaCrotal interpretarCodigoCrotal(String codigo) {
  final limpio = codigo.toUpperCase().replaceAll(RegExp(r'[\s\-\. _/]'), '');
  if (limpio.isEmpty) {
    return const LecturaCrotal(identificacion: '', reconocido: false);
  }
  final oficial = _crotalOficial.firstMatch(limpio);
  if (oficial != null) {
    return LecturaCrotal(identificacion: limpio, reconocido: true);
  }
  if (_soloDigitos.hasMatch(limpio)) {
    if (limpio.length == 12) {
      return LecturaCrotal(identificacion: 'ES$limpio', reconocido: true);
    }
    if (limpio.length == 15) {
      final pais = _paisesIsoNumericos[limpio.substring(0, 3)];
      if (pais != null) {
        return LecturaCrotal(
            identificacion: '$pais${limpio.substring(3)}', reconocido: true);
      }
    }
  }
  return LecturaCrotal(identificacion: limpio, reconocido: false);
}
