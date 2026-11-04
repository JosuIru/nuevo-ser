/// Calendario fenológico por cultivo y mes. Pares (cultivoId, mes 1-12)
/// → lista de tareas/eventos típicos en Iberia. Datos genéricos
/// derivados de info_cultivos; **no** son recomendación específica de
/// finca, son orientativos. La pantalla "Hoy" los usa para sugerir
/// "qué toca esta semana" según los cultivos que el usuario tiene
/// registrados.
///
/// La granularidad es mensual a propósito — hacerlo semanal exigiría
/// modelar fechas variables por zona climática, y eso entra en
/// F3/F4 con servicio meteo (Open-Meteo + AEMET) que ajuste por
/// localización real.
const Map<String, Map<int, List<String>>> calendarioFenologico = {
  // ─── Truficultura ──────────────────────────────────────
  'tuber-melanosporum': {
    1: ['Cosecha activa', 'Vigilar humedad del quemado'],
    2: ['Cosecha activa hasta mediados de mes', 'Recolectar momias y restos del suelo'],
    3: ['Riego de mantenimiento si seco', 'Análisis de suelo (pH, caliza)'],
    4: ['Inicio brotación hospederos', 'Acolchado de paja si hay erosión'],
    5: ['Riego clave: abril-junio determina tamaño de trufa'],
    6: ['Riego de apoyo (~25-40 L/árbol/semana en sequía)'],
    7: ['Riego clave: la trufa se forma este mes'],
    8: ['Riego clave', 'Vigilar invasión de Tuber brumale'],
    9: ['Reducir riego progresivamente', 'Preparar perro/cosechador'],
    10: ['Detener riego', 'Inicios de detección olfativa'],
    11: ['Inicio campaña', 'Cosecha con can entrenado'],
    12: ['Cosecha activa', 'Conservación inmediata en frío'],
  },
  'tuber-aestivum': {
    5: ['Inicio campaña', 'Cosecha con can'],
    6: ['Cosecha activa'],
    7: ['Cosecha activa'],
    8: ['Cosecha activa'],
    9: ['Cierre de campaña'],
    10: ['Riego post-campaña'],
    3: ['Riego de mantenimiento'],
    4: ['Brotación hospederos'],
  },

  // ─── Frutales ──────────────────────────────────────────
  'manzano': {
    1: ['Poda en seco (estructura)', 'Tratamientos cúpricos preventivos'],
    2: ['Final de poda', 'Tratamiento yema hinchada (cobre)'],
    3: ['Pre-floración', 'Vigilar pulgones'],
    4: ['Floración (vigilar heladas)', 'Polinización'],
    5: ['Cuajado', 'Caída de junio'],
    6: ['Aclareo manual o químico', 'Control de carpocapsa (1.ª gen)'],
    7: ['Riego intensivo en variedades tardías', 'Carpocapsa (2.ª gen)'],
    8: ['Cosecha de tempranas (Royal Gala)', 'Engorde'],
    9: ['Cosecha de medias (Golden, Reineta)'],
    10: ['Cosecha de tardías (Fuji, Granny)', 'Conservación'],
    11: ['Cosecha de tardías', 'Recoger hojas caídas (moteado)'],
    12: ['Recoger fruta momificada (monilia)', 'Inicio poda'],
  },
  'peral': {
    2: ['Poda en seco', 'Cobre yema hinchada'],
    3: ['Pre-floración', 'Vigilar psila'],
    4: ['Floración', 'Riesgo helada tardía'],
    5: ['Cuajado'],
    6: ['Aclareo'],
    7: ['Cosecha de tempranas (Ercolini)', 'Vigilar fuego bacteriano si lluvia+calor'],
    8: ['Cosecha de medias (Limonera, Williams)'],
    9: ['Cosecha de tardías (Conference, Comice)'],
    10: ['Cosecha de tardías'],
  },
  'cerezo': {
    1: ['Poda invernal'],
    2: ['Cobre yema hinchada'],
    3: ['Floración temprana — riesgo helada'],
    4: ['Cuajado, riesgo Drosophila desde envero'],
    5: ['Cosecha de tempranas (Burlat)'],
    6: ['Cosecha (Picota, Van, Lapins)'],
    7: ['Cosecha de tardías (Sweetheart, Skeena)', 'Poda en verde post-cosecha'],
    8: ['Vigilar Drosophila suzukii'],
  },
  'melocotonero': {
    1: ['Poda', 'Cobre yema hinchada (abolladura)'],
    2: ['Floración temprana — heladas'],
    3: ['Cuajado'],
    4: ['Aclareo'],
    5: ['Cosecha de extratempranas'],
    6: ['Cosecha de tempranas'],
    7: ['Cosecha de media estación'],
    8: ['Cosecha de tardías', 'Vigilar mosca mediterránea'],
    9: ['Cosecha de tardías (Catherina, Calanda)'],
    10: ['Cosecha de extratardías'],
  },
  'almendro': {
    1: ['Poda', 'Recogida de momias (avispilla)'],
    2: ['Floración temprana — riesgo helada crítico', 'Cobre'],
    3: ['Cuajado'],
    4: ['Crecimiento de fruto'],
    5: ['Vigilar mancha ocre si primavera lluviosa'],
    6: ['Riego clave para llenado'],
    7: ['Llenado de grano'],
    8: ['Cosecha (vibrador)'],
    9: ['Cosecha de tardías', 'Pelado y secado'],
  },
  'pistacho': {
    1: ['Poda de formación'],
    2: ['Pre-brotación'],
    3: ['Brotación'],
    4: ['Floración (anemófila — viento polinizador)'],
    5: ['Cuajado'],
    6: ['Crecimiento'],
    7: ['Llenado de grano'],
    8: ['Riego clave'],
    9: ['Cosecha (vibrador)', 'Secado a 6-8 % de humedad'],
    10: ['Cosecha de tardías', 'Pelado y secado'],
    11: ['Conservación'],
  },
  'nogal': {
    1: ['Poda invernal'],
    4: ['Brotación tardía — riesgo de helada'],
    5: ['Floración'],
    6: ['Cuajado'],
    9: ['Cosecha (vibrador)'],
    10: ['Cosecha', 'Secado'],
  },
  'avellano': {
    1: ['Floración invernal — anemófila'],
    2: ['Polinización por viento'],
    8: ['Cosecha (vibrador o suelo)'],
    9: ['Cosecha', 'Secado a 8-10 % de humedad'],
  },
  'olivo': {
    1: ['Cosecha activa (verdial, hojiblanca)', 'Almazara'],
    2: ['Final cosecha', 'Poda — primer mes recomendado'],
    3: ['Poda', 'Cobre post-poda contra tuberculosis'],
    4: ['Brotación'],
    5: ['Floración (mediados de mayo)', 'Vigilar prays antófago'],
    6: ['Cuajado'],
    7: ['Riego de apoyo', 'Vigilar mosca del olivo (trampeo)'],
    8: ['Endurecimiento de hueso', 'Mosca activa'],
    9: ['Envero — máxima vigilancia mosca', 'Trampas de mosqueros'],
    10: ['Cosecha de tempranas (verde)', 'Inicio campaña aceite verdial'],
    11: ['Cosecha media (picual, hojiblanca)'],
    12: ['Cosecha plena', 'Almazara en 24 h tras la recogida'],
  },
  'vid': {
    1: ['Poda en seco'],
    2: ['Final poda'],
    3: ['Brotación', 'Tratamiento mildiu/oídio preventivo'],
    4: ['Crecimiento — riesgo helada tardía'],
    5: ['Floración', 'Confusión sexual lobesia'],
    6: ['Envero inicial', 'Tratamientos clave si humedad'],
    7: ['Envero', 'Vigilar oídio'],
    8: ['Maduración'],
    9: ['Vendimia de tempranas (blancas, tintas precoces)'],
    10: ['Vendimia plena (Tempranillo, Garnacha, Cabernet)'],
    11: ['Vendimias tardías', 'Inicio descanso vegetativo'],
  },

  // ─── Forestal ─────────────────────────────────────────
  'encina': {
    5: ['Floración'],
    10: ['Bellota — inicio caída'],
    11: ['Montanera (cerdo ibérico)'],
    12: ['Montanera'],
    1: ['Final montanera'],
    2: ['Poda de formación si toca (cada 6-10 años)'],
  },
  'alcornoque': {
    6: ['Inicio temporada descorche (jun-ago)'],
    7: ['Descorche'],
    8: ['Descorche — final'],
  },
};

/// Devuelve las tareas previstas para un cultivo en el mes indicado
/// (1-12). Lista vacía si no hay datos para ese par. Tolerante a
/// cultivos sin entrada en el calendario — devuelve lista vacía.
List<String> tareasParaCultivoEnMes(String cultivoId, int mes) {
  final mapaCultivo = calendarioFenologico[cultivoId];
  if (mapaCultivo == null) return const [];
  return mapaCultivo[mes] ?? const [];
}
