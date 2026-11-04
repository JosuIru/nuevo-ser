/// GENERADO — no editar a mano.
/// Sale de content/solera/traducciones.csv con
/// `dart run tool/compilar_traducciones_solera.dart` (desde packages/nuevo_ser_core).

import 'package:flutter/material.dart';

class SoleraL10n {
  SoleraL10n._();

  static String _idioma = 'es';
  static final ValueNotifier<int> notificador = ValueNotifier<int>(0);

  static String get idioma => _idioma;
  static set idioma(String c) {
    _idioma = c;
    notificador.value++;
  }

  /// Claves con texto en castellano (para tests).
  static const clavesDisponibles = <String>{
    '10%_(alimento)',
    '21%_(general)',
    '4%_(tipo_reducido)',
    'acerca_de',
    'ajustes',
    'anadir_proveedor',
    'antibioticos_positivos',
    'anular_factura',
    'aun_no_hay_lotes',
    'backup',
    'baja',
    'borrar',
    'borrar_proveedor',
    'borrar_receta',
    'cancelar',
    'compartir',
    'comprobar_actualizaciones',
    'configuracion_fiscal',
    'copia_de_seguridad',
    'crear_primer_lote',
    'crear_primera_receta',
    'crear_y_compartir_backup',
    'denominaciones_de_origen',
    'editar',
    'email_de_respaldo',
    'emision_pdf_y_envio',
    'emitir_factura',
    'emitir_primera_factura',
    'en_curacion',
    'error',
    'estado_de_cavas',
    'facturas',
    'fresca',
    'guardar',
    'guardar_partida',
    'identificacion_con_ia',
    'importe_no_valido',
    'importe_obligatorio',
    'inventario_de_cava',
    'libro_de_trazabilidad_appcc',
    'libro_economico',
    'lista',
    'lotes_de_produccion',
    'mapa',
    'mayor_que_cero',
    'no_hay_recetas',
    'no_puede_ser_negativo',
    'nombre_del_cliente_requerido',
    'nueva_factura',
    'nueva_partida_de_leche',
    'numero_entero_no_valido',
    'numero_no_valido',
    'partida_registrada',
    'pendientes_hoy',
    'perfiles_do',
    'proveedor',
    'proveedores',
    'proveedores_de_leche',
    'provisional___validar_con_asesor_fiscal',
    'queseria',
    'rebano_propio',
    'recetas',
    'registrar_partida_de_leche',
    'registros_appcc',
    'restaurar_desde_zip',
    'seccion_aplicacion',
    'seccion_datos',
    'seccion_explotacion',
    'seccion_integraciones',
    'seccion_preferencias',
    'selecciona_un_proveedor',
    'simulacion_de_trazabilidad',
    'sin_configurar',
    'sin_proveedores',
    'temperatura_registrada',
    'todos',
    'ver_pdf',
  };

  /// Claves que tienen texto propio en [idioma] (para tests).
  static Set<String> clavesTraducidas(String idioma) => switch (idioma) {
        'eu' => const {
          '10%_(alimento)',
          '21%_(general)',
          '4%_(tipo_reducido)',
          'acerca_de',
          'ajustes',
          'anadir_proveedor',
          'antibioticos_positivos',
          'anular_factura',
          'aun_no_hay_lotes',
          'backup',
          'baja',
          'borrar',
          'borrar_proveedor',
          'borrar_receta',
          'cancelar',
          'compartir',
          'comprobar_actualizaciones',
          'configuracion_fiscal',
          'copia_de_seguridad',
          'crear_primer_lote',
          'crear_primera_receta',
          'crear_y_compartir_backup',
          'denominaciones_de_origen',
          'editar',
          'email_de_respaldo',
          'emision_pdf_y_envio',
          'emitir_factura',
          'emitir_primera_factura',
          'en_curacion',
          'error',
          'estado_de_cavas',
          'facturas',
          'fresca',
          'guardar',
          'guardar_partida',
          'identificacion_con_ia',
          'importe_no_valido',
          'importe_obligatorio',
          'inventario_de_cava',
          'libro_de_trazabilidad_appcc',
          'libro_economico',
          'lista',
          'lotes_de_produccion',
          'mapa',
          'mayor_que_cero',
          'no_hay_recetas',
          'no_puede_ser_negativo',
          'nombre_del_cliente_requerido',
          'nueva_factura',
          'nueva_partida_de_leche',
          'numero_entero_no_valido',
          'numero_no_valido',
          'partida_registrada',
          'pendientes_hoy',
          'perfiles_do',
          'proveedor',
          'proveedores',
          'proveedores_de_leche',
          'provisional___validar_con_asesor_fiscal',
          'queseria',
          'rebano_propio',
          'recetas',
          'registrar_partida_de_leche',
          'registros_appcc',
          'restaurar_desde_zip',
          'seccion_aplicacion',
          'seccion_datos',
          'seccion_explotacion',
          'seccion_integraciones',
          'seccion_preferencias',
          'selecciona_un_proveedor',
          'simulacion_de_trazabilidad',
          'sin_configurar',
          'sin_proveedores',
          'temperatura_registrada',
          'todos',
          'ver_pdf',
        },
        'ca' => const {
          '10%_(alimento)',
          '21%_(general)',
          '4%_(tipo_reducido)',
          'acerca_de',
          'ajustes',
          'anadir_proveedor',
          'antibioticos_positivos',
          'anular_factura',
          'aun_no_hay_lotes',
          'backup',
          'baja',
          'borrar',
          'borrar_proveedor',
          'borrar_receta',
          'cancelar',
          'compartir',
          'comprobar_actualizaciones',
          'configuracion_fiscal',
          'copia_de_seguridad',
          'crear_primer_lote',
          'crear_primera_receta',
          'crear_y_compartir_backup',
          'denominaciones_de_origen',
          'editar',
          'email_de_respaldo',
          'emision_pdf_y_envio',
          'emitir_factura',
          'emitir_primera_factura',
          'en_curacion',
          'error',
          'estado_de_cavas',
          'facturas',
          'fresca',
          'guardar',
          'guardar_partida',
          'identificacion_con_ia',
          'importe_no_valido',
          'importe_obligatorio',
          'inventario_de_cava',
          'libro_de_trazabilidad_appcc',
          'libro_economico',
          'lista',
          'lotes_de_produccion',
          'mapa',
          'mayor_que_cero',
          'no_hay_recetas',
          'no_puede_ser_negativo',
          'nombre_del_cliente_requerido',
          'nueva_factura',
          'nueva_partida_de_leche',
          'numero_entero_no_valido',
          'numero_no_valido',
          'partida_registrada',
          'pendientes_hoy',
          'perfiles_do',
          'proveedor',
          'proveedores',
          'proveedores_de_leche',
          'provisional___validar_con_asesor_fiscal',
          'queseria',
          'rebano_propio',
          'recetas',
          'registrar_partida_de_leche',
          'registros_appcc',
          'restaurar_desde_zip',
          'seccion_aplicacion',
          'seccion_datos',
          'seccion_explotacion',
          'seccion_integraciones',
          'seccion_preferencias',
          'selecciona_un_proveedor',
          'simulacion_de_trazabilidad',
          'sin_configurar',
          'sin_proveedores',
          'temperatura_registrada',
          'todos',
          'ver_pdf',
        },
        'gl' => const {
          '10%_(alimento)',
          '21%_(general)',
          '4%_(tipo_reducido)',
          'acerca_de',
          'ajustes',
          'anadir_proveedor',
          'antibioticos_positivos',
          'anular_factura',
          'aun_no_hay_lotes',
          'backup',
          'baja',
          'borrar',
          'borrar_proveedor',
          'borrar_receta',
          'cancelar',
          'compartir',
          'comprobar_actualizaciones',
          'configuracion_fiscal',
          'copia_de_seguridad',
          'crear_primer_lote',
          'crear_primera_receta',
          'crear_y_compartir_backup',
          'denominaciones_de_origen',
          'editar',
          'email_de_respaldo',
          'emision_pdf_y_envio',
          'emitir_factura',
          'emitir_primera_factura',
          'en_curacion',
          'error',
          'estado_de_cavas',
          'facturas',
          'fresca',
          'guardar',
          'guardar_partida',
          'identificacion_con_ia',
          'importe_no_valido',
          'importe_obligatorio',
          'inventario_de_cava',
          'libro_de_trazabilidad_appcc',
          'libro_economico',
          'lista',
          'lotes_de_produccion',
          'mapa',
          'mayor_que_cero',
          'no_hay_recetas',
          'no_puede_ser_negativo',
          'nombre_del_cliente_requerido',
          'nueva_factura',
          'nueva_partida_de_leche',
          'numero_entero_no_valido',
          'numero_no_valido',
          'partida_registrada',
          'pendientes_hoy',
          'perfiles_do',
          'proveedor',
          'proveedores',
          'proveedores_de_leche',
          'provisional___validar_con_asesor_fiscal',
          'queseria',
          'rebano_propio',
          'recetas',
          'registrar_partida_de_leche',
          'registros_appcc',
          'restaurar_desde_zip',
          'seccion_aplicacion',
          'seccion_datos',
          'seccion_explotacion',
          'seccion_integraciones',
          'seccion_preferencias',
          'selecciona_un_proveedor',
          'simulacion_de_trazabilidad',
          'sin_configurar',
          'sin_proveedores',
          'temperatura_registrada',
          'todos',
          'ver_pdf',
        },
        _ => clavesDisponibles,
      };

  static String t(String clave, {String? idioma}) {
    switch (idioma ?? _idioma) {
      case 'eu': return _tEu(clave);
      case 'ca': return _tCa(clave);
      case 'gl': return _tGl(clave);
      default: return _tEs(clave);
    }
  }

  static String _tEs(String c) {
    switch (c) {
      case '10%_(alimento)': return '10% (alimentos)';
      case '21%_(general)': return '21% (general)';
      case '4%_(tipo_reducido)': return '4% (superreducido)';
      case 'acerca_de': return 'Acerca de';
      case 'ajustes': return 'Ajustes';
      case 'anadir_proveedor': return 'Añadir proveedor';
      case 'antibioticos_positivos': return 'Antibióticos positivos';
      case 'anular_factura': return 'Anular factura';
      case 'aun_no_hay_lotes': return 'Aún no hay lotes';
      case 'backup': return 'Copia de seguridad';
      case 'baja': return 'Baja';
      case 'borrar': return 'Borrar';
      case 'borrar_proveedor': return 'Borrar proveedor';
      case 'borrar_receta': return 'Borrar receta';
      case 'cancelar': return 'Cancelar';
      case 'compartir': return 'Compartir';
      case 'comprobar_actualizaciones': return 'Comprobar actualizaciones';
      case 'configuracion_fiscal': return 'Configuración fiscal';
      case 'copia_de_seguridad': return 'Copia de seguridad';
      case 'crear_primer_lote': return 'Crear primer lote';
      case 'crear_primera_receta': return 'Crear primera receta';
      case 'crear_y_compartir_backup': return 'Crear y compartir copia';
      case 'denominaciones_de_origen': return 'Denominaciones de origen';
      case 'editar': return 'Editar';
      case 'email_de_respaldo': return 'Correo para la copia';
      case 'emision_pdf_y_envio': return 'Emisión, PDF y envío';
      case 'emitir_factura': return 'Emitir factura';
      case 'emitir_primera_factura': return 'Emitir primera factura';
      case 'en_curacion': return 'En curación';
      case 'error': return 'Error';
      case 'estado_de_cavas': return 'Estado de cavas';
      case 'facturas': return 'Facturas';
      case 'fresca': return 'Fresca';
      case 'guardar': return 'Guardar';
      case 'guardar_partida': return 'Guardar partida';
      case 'identificacion_con_ia': return 'Identificación con IA';
      case 'importe_no_valido': return 'Importe no válido (p. ej. 1.200,50)';
      case 'importe_obligatorio': return 'Importe obligatorio';
      case 'inventario_de_cava': return 'Inventario de cava';
      case 'libro_de_trazabilidad_appcc': return 'Libro de trazabilidad APPCC';
      case 'libro_economico': return 'Libro económico';
      case 'lista': return 'Lista';
      case 'lotes_de_produccion': return 'Lotes de producción';
      case 'mapa': return 'Mapa';
      case 'mayor_que_cero': return 'Tiene que ser mayor que cero';
      case 'no_hay_recetas': return 'No hay recetas';
      case 'no_puede_ser_negativo': return 'No puede ser negativo';
      case 'nombre_del_cliente_requerido': return 'Falta el nombre del cliente';
      case 'nueva_factura': return 'Nueva factura';
      case 'nueva_partida_de_leche': return 'Nueva partida de leche';
      case 'numero_entero_no_valido': return 'Escribe un número entero (p. ej. 12)';
      case 'numero_no_valido': return 'Número no válido (p. ej. 12,5)';
      case 'partida_registrada': return 'Partida registrada';
      case 'pendientes_hoy': return 'Pendientes hoy';
      case 'perfiles_do': return 'Perfiles DO';
      case 'proveedor': return 'Proveedor';
      case 'proveedores': return 'Proveedores';
      case 'proveedores_de_leche': return 'Proveedores de leche';
      case 'provisional___validar_con_asesor_fiscal': return 'Provisional: valídalo con tu asesor fiscal';
      case 'queseria': return 'Quesería';
      case 'rebano_propio': return 'Rebaño propio';
      case 'recetas': return 'Recetas';
      case 'registrar_partida_de_leche': return 'Registrar partida de leche';
      case 'registros_appcc': return 'Registros APPCC';
      case 'restaurar_desde_zip': return 'Restaurar desde ZIP';
      case 'seccion_aplicacion': return 'Aplicación';
      case 'seccion_datos': return 'Datos';
      case 'seccion_explotacion': return 'Explotación';
      case 'seccion_integraciones': return 'Inteligencia artificial';
      case 'seccion_preferencias': return 'Preferencias';
      case 'selecciona_un_proveedor': return 'Selecciona un proveedor';
      case 'simulacion_de_trazabilidad': return 'Simulación de trazabilidad';
      case 'sin_configurar': return 'Sin configurar';
      case 'sin_proveedores': return 'Todavía no hay proveedores';
      case 'temperatura_registrada': return 'Temperatura registrada';
      case 'todos': return 'Todos';
      case 'ver_pdf': return 'Ver PDF';
      default: return c;
    }
  }

  static String _tEu(String c) {
    switch (c) {
      case '10%_(alimento)': return '% 10 (elikagaiak)';
      case '21%_(general)': return '% 21 (orokorra)';
      case '4%_(tipo_reducido)': return '% 4 (supermurriztua)';
      case 'acerca_de': return 'Honi buruz';
      case 'ajustes': return 'Ezarpenak';
      case 'anadir_proveedor': return 'Hornitzailea gehitu';
      case 'antibioticos_positivos': return 'Antibiotiko positiboak';
      case 'anular_factura': return 'Faktura deuseztatu';
      case 'aun_no_hay_lotes': return 'Oraindik ez dago loterik';
      case 'backup': return 'Segurtasun-kopia';
      case 'baja': return 'Baja emanda';
      case 'borrar': return 'Ezabatu';
      case 'borrar_proveedor': return 'Hornitzailea ezabatu';
      case 'borrar_receta': return 'Errezeta ezabatu';
      case 'cancelar': return 'Utzi';
      case 'compartir': return 'Partekatu';
      case 'comprobar_actualizaciones': return 'Eguneraketak egiaztatu';
      case 'configuracion_fiscal': return 'Konfigurazio fiskala';
      case 'copia_de_seguridad': return 'Segurtasun-kopia';
      case 'crear_primer_lote': return 'Lehen lotea sortu';
      case 'crear_primera_receta': return 'Lehen errezeta sortu';
      case 'crear_y_compartir_backup': return 'Segurtasun-kopia sortu eta partekatu';
      case 'denominaciones_de_origen': return 'Jatorri-deiturak';
      case 'editar': return 'Editatu';
      case 'email_de_respaldo': return 'Kopiarako helbide elektronikoa';
      case 'emision_pdf_y_envio': return 'Jaulkipena, PDFa eta bidalketa';
      case 'emitir_factura': return 'Faktura jaulki';
      case 'emitir_primera_factura': return 'Lehen faktura jaulki';
      case 'en_curacion': return 'Ontzen';
      case 'error': return 'Errorea';
      case 'estado_de_cavas': return 'Upeltegi-egoera';
      case 'facturas': return 'Fakturak';
      case 'fresca': return 'Freskoa';
      case 'guardar': return 'Gorde';
      case 'guardar_partida': return 'Partida gorde';
      case 'identificacion_con_ia': return 'AA bidezko identifikazioa';
      case 'importe_no_valido': return 'Zenbateko okerra (adib. 1.200,50)';
      case 'importe_obligatorio': return 'Zenbatekoa derrigorrezkoa da';
      case 'inventario_de_cava': return 'Upeltegiaren inbentarioa';
      case 'libro_de_trazabilidad_appcc': return 'APPCC trazabilitate-liburua';
      case 'libro_economico': return 'Liburu ekonomikoa';
      case 'lista': return 'Prest';
      case 'lotes_de_produccion': return 'Ekoizpen-loteak';
      case 'mapa': return 'Mapa';
      case 'mayor_que_cero': return 'Zero baino handiagoa izan behar du';
      case 'no_hay_recetas': return 'Ez dago errezetarik';
      case 'no_puede_ser_negativo': return 'Ezin da negatiboa izan';
      case 'nombre_del_cliente_requerido': return 'Bezeroaren izena falta da';
      case 'nueva_factura': return 'Faktura berria';
      case 'nueva_partida_de_leche': return 'Esne-partida berria';
      case 'numero_entero_no_valido': return 'Idatzi zenbaki oso bat (adib. 12)';
      case 'numero_no_valido': return 'Zenbaki okerra (adib. 12,5)';
      case 'partida_registrada': return 'Partida erregistratua';
      case 'pendientes_hoy': return 'Gaurko zereginak';
      case 'perfiles_do': return 'JD profilak';
      case 'proveedor': return 'Hornitzailea';
      case 'proveedores': return 'Hornitzaileak';
      case 'proveedores_de_leche': return 'Esne-hornitzaileak';
      case 'provisional___validar_con_asesor_fiscal': return 'Behin-behinekoa: egiaztatu zure aholkulari fiskalarekin';
      case 'queseria': return 'Gaztategia';
      case 'rebano_propio': return 'Artalde propioa';
      case 'recetas': return 'Errezetak';
      case 'registrar_partida_de_leche': return 'Esne-partida erregistratu';
      case 'registros_appcc': return 'APPCC erregistroak';
      case 'restaurar_desde_zip': return 'ZIP fitxategitik leheneratu';
      case 'seccion_aplicacion': return 'Aplikazioa';
      case 'seccion_datos': return 'Datuak';
      case 'seccion_explotacion': return 'Ustiapena';
      case 'seccion_integraciones': return 'Adimen artifiziala';
      case 'seccion_preferencias': return 'Hobespenak';
      case 'selecciona_un_proveedor': return 'Hautatu hornitzaile bat';
      case 'simulacion_de_trazabilidad': return 'Trazabilitate-simulazioa';
      case 'sin_configurar': return 'Konfiguratu gabe';
      case 'sin_proveedores': return 'Oraindik ez dago hornitzailerik';
      case 'temperatura_registrada': return 'Tenperatura erregistratua';
      case 'todos': return 'Denak';
      case 'ver_pdf': return 'PDF ikusi';
      default: return _tEs(c);
    }
  }

  static String _tCa(String c) {
    switch (c) {
      case '10%_(alimento)': return '10% (aliments)';
      case '21%_(general)': return '21% (general)';
      case '4%_(tipo_reducido)': return '4% (superreduït)';
      case 'acerca_de': return 'Quant a';
      case 'ajustes': return 'Configuració';
      case 'anadir_proveedor': return 'Afegir proveïdor';
      case 'antibioticos_positivos': return 'Antibiòtics positius';
      case 'anular_factura': return 'Anul·lar factura';
      case 'aun_no_hay_lotes': return 'Encara no hi ha lots';
      case 'backup': return 'Còpia de seguretat';
      case 'baja': return 'Baixa';
      case 'borrar': return 'Esborrar';
      case 'borrar_proveedor': return 'Esborrar proveïdor';
      case 'borrar_receta': return 'Esborrar recepta';
      case 'cancelar': return 'Cancel·lar';
      case 'compartir': return 'Compartir';
      case 'comprobar_actualizaciones': return 'Comprovar actualitzacions';
      case 'configuracion_fiscal': return 'Configuració fiscal';
      case 'copia_de_seguridad': return 'Còpia de seguretat';
      case 'crear_primer_lote': return 'Crear primer lot';
      case 'crear_primera_receta': return 'Crear primera recepta';
      case 'crear_y_compartir_backup': return 'Crear i compartir còpia de seguretat';
      case 'denominaciones_de_origen': return 'Denominacions d\'origen';
      case 'editar': return 'Editar';
      case 'email_de_respaldo': return 'Correu per a la còpia';
      case 'emision_pdf_y_envio': return 'Emissió, PDF i enviament';
      case 'emitir_factura': return 'Emetre factura';
      case 'emitir_primera_factura': return 'Emetre primera factura';
      case 'en_curacion': return 'En curació';
      case 'error': return 'Error';
      case 'estado_de_cavas': return 'Estat de les caves';
      case 'facturas': return 'Factures';
      case 'fresca': return 'Fresca';
      case 'guardar': return 'Desar';
      case 'guardar_partida': return 'Desar partida';
      case 'identificacion_con_ia': return 'Identificació amb IA';
      case 'importe_no_valido': return 'Import no vàlid (p. ex. 1.200,50)';
      case 'importe_obligatorio': return 'Import obligatori';
      case 'inventario_de_cava': return 'Inventari de la cava';
      case 'libro_de_trazabilidad_appcc': return 'Llibre de traçabilitat APPCC';
      case 'libro_economico': return 'Llibre econòmic';
      case 'lista': return 'Llest';
      case 'lotes_de_produccion': return 'Lots de producció';
      case 'mapa': return 'Mapa';
      case 'mayor_que_cero': return 'Ha de ser més gran que zero';
      case 'no_hay_recetas': return 'No hi ha receptes';
      case 'no_puede_ser_negativo': return 'No pot ser negatiu';
      case 'nombre_del_cliente_requerido': return 'Falta el nom del client';
      case 'nueva_factura': return 'Factura nova';
      case 'nueva_partida_de_leche': return 'Partida de llet nova';
      case 'numero_entero_no_valido': return 'Escriu un nombre enter (p. ex. 12)';
      case 'numero_no_valido': return 'Número no vàlid (p. ex. 12,5)';
      case 'partida_registrada': return 'Partida registrada';
      case 'pendientes_hoy': return 'Pendents d\'avui';
      case 'perfiles_do': return 'Perfils DO';
      case 'proveedor': return 'Proveïdor';
      case 'proveedores': return 'Proveïdors';
      case 'proveedores_de_leche': return 'Proveïdors de llet';
      case 'provisional___validar_con_asesor_fiscal': return 'Provisional: valida-ho amb el teu assessor fiscal';
      case 'queseria': return 'Formatgeria';
      case 'rebano_propio': return 'Ramat propi';
      case 'recetas': return 'Receptes';
      case 'registrar_partida_de_leche': return 'Registrar partida de llet';
      case 'registros_appcc': return 'Registres APPCC';
      case 'restaurar_desde_zip': return 'Restaurar des de ZIP';
      case 'seccion_aplicacion': return 'Aplicació';
      case 'seccion_datos': return 'Dades';
      case 'seccion_explotacion': return 'Explotació';
      case 'seccion_integraciones': return 'Intel·ligència artificial';
      case 'seccion_preferencias': return 'Preferències';
      case 'selecciona_un_proveedor': return 'Selecciona un proveïdor';
      case 'simulacion_de_trazabilidad': return 'Simulació de traçabilitat';
      case 'sin_configurar': return 'Sense configurar';
      case 'sin_proveedores': return 'Encara no hi ha proveïdors';
      case 'temperatura_registrada': return 'Temperatura registrada';
      case 'todos': return 'Tots';
      case 'ver_pdf': return 'Veure PDF';
      default: return _tEs(c);
    }
  }

  static String _tGl(String c) {
    switch (c) {
      case '10%_(alimento)': return '10% (alimentos)';
      case '21%_(general)': return '21% (xeral)';
      case '4%_(tipo_reducido)': return '4% (superreducido)';
      case 'acerca_de': return 'Acerca de';
      case 'ajustes': return 'Axustes';
      case 'anadir_proveedor': return 'Engadir provedor';
      case 'antibioticos_positivos': return 'Antibióticos positivos';
      case 'anular_factura': return 'Anular factura';
      case 'aun_no_hay_lotes': return 'Aínda non hai lotes';
      case 'backup': return 'Copia de seguridade';
      case 'baja': return 'Baixa';
      case 'borrar': return 'Borrar';
      case 'borrar_proveedor': return 'Borrar provedor';
      case 'borrar_receta': return 'Borrar receita';
      case 'cancelar': return 'Cancelar';
      case 'compartir': return 'Compartir';
      case 'comprobar_actualizaciones': return 'Comprobar actualizacións';
      case 'configuracion_fiscal': return 'Configuración fiscal';
      case 'copia_de_seguridad': return 'Copia de seguridade';
      case 'crear_primer_lote': return 'Crear primeiro lote';
      case 'crear_primera_receta': return 'Crear primeira receita';
      case 'crear_y_compartir_backup': return 'Crear e compartir copia de seguridade';
      case 'denominaciones_de_origen': return 'Denominacións de orixe';
      case 'editar': return 'Editar';
      case 'email_de_respaldo': return 'Correo para a copia';
      case 'emision_pdf_y_envio': return 'Emisión, PDF e envío';
      case 'emitir_factura': return 'Emitir factura';
      case 'emitir_primera_factura': return 'Emitir primeira factura';
      case 'en_curacion': return 'En curación';
      case 'error': return 'Erro';
      case 'estado_de_cavas': return 'Estado das cavas';
      case 'facturas': return 'Facturas';
      case 'fresca': return 'Fresca';
      case 'guardar': return 'Gardar';
      case 'guardar_partida': return 'Gardar partida';
      case 'identificacion_con_ia': return 'Identificación con IA';
      case 'importe_no_valido': return 'Importe non válido (p. ex. 1.200,50)';
      case 'importe_obligatorio': return 'Importe obrigatorio';
      case 'inventario_de_cava': return 'Inventario da cava';
      case 'libro_de_trazabilidad_appcc': return 'Libro de rastrexabilidade APPCC';
      case 'libro_economico': return 'Libro económico';
      case 'lista': return 'Lista';
      case 'lotes_de_produccion': return 'Lotes de produción';
      case 'mapa': return 'Mapa';
      case 'mayor_que_cero': return 'Ten que ser maior que cero';
      case 'no_hay_recetas': return 'Non hai receitas';
      case 'no_puede_ser_negativo': return 'Non pode ser negativo';
      case 'nombre_del_cliente_requerido': return 'Falta o nome do cliente';
      case 'nueva_factura': return 'Factura nova';
      case 'nueva_partida_de_leche': return 'Partida de leite nova';
      case 'numero_entero_no_valido': return 'Escribe un número enteiro (p. ex. 12)';
      case 'numero_no_valido': return 'Número non válido (p. ex. 12,5)';
      case 'partida_registrada': return 'Partida rexistrada';
      case 'pendientes_hoy': return 'Pendentes de hoxe';
      case 'perfiles_do': return 'Perfís DO';
      case 'proveedor': return 'Provedor';
      case 'proveedores': return 'Provedores';
      case 'proveedores_de_leche': return 'Provedores de leite';
      case 'provisional___validar_con_asesor_fiscal': return 'Provisional: valídao co teu asesor fiscal';
      case 'queseria': return 'Queixaría';
      case 'rebano_propio': return 'Raño propio';
      case 'recetas': return 'Receitas';
      case 'registrar_partida_de_leche': return 'Rexistrar partida de leite';
      case 'registros_appcc': return 'Rexistros APPCC';
      case 'restaurar_desde_zip': return 'Restaurar desde ZIP';
      case 'seccion_aplicacion': return 'Aplicación';
      case 'seccion_datos': return 'Datos';
      case 'seccion_explotacion': return 'Explotación';
      case 'seccion_integraciones': return 'Intelixencia artificial';
      case 'seccion_preferencias': return 'Preferencias';
      case 'selecciona_un_proveedor': return 'Selecciona un provedor';
      case 'simulacion_de_trazabilidad': return 'Simulación de rastrexabilidade';
      case 'sin_configurar': return 'Sen configurar';
      case 'sin_proveedores': return 'Aínda non hai provedores';
      case 'temperatura_registrada': return 'Temperatura rexistrada';
      case 'todos': return 'Todos';
      case 'ver_pdf': return 'Ver PDF';
      default: return _tEs(c);
    }
  }

}
