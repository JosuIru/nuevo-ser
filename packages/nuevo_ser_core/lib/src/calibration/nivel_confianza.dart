/// Tres niveles de confianza con que un juego puede pedirle a la
/// persona usuaria que ancle una afirmación. Genérico — no presupone
/// historia ni matemáticas, lo usan tanto Las Versiones (AH.03 sobre
/// el oficio del cronista) como cualquier juego futuro que necesite
/// declaración explícita de incertidumbre.
///
/// El cálculo Brier (`EvaluadorCalibracion`) compara el nivel
/// declarado con el nivel canónicamente correcto del catálogo.
enum NivelConfianza {
  solido,
  probable,
  disputado,
}

/// Valor de cada nivel en la escala de P4 (doc 02 de Las Versiones
/// §4.1): Disputado 0, Probable 0.5, Sólido 1. Es lo que se pasa como
/// `confianzaDeclarada` / `fiabilidadReal` al motor de maestría.
extension ValorFiabilidad on NivelConfianza {
  double get valorFiabilidad {
    switch (this) {
      case NivelConfianza.solido:
        return 1.0;
      case NivelConfianza.probable:
        return 0.5;
      case NivelConfianza.disputado:
        return 0.0;
    }
  }
}
