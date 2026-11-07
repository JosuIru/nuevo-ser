# Encargo común para el agente de una vertical Larrea

Instrucciones que comparten todos los agentes que construyen una vertical del plan
(`docs/plan-verticales-larrea.md`). El encargo concreto de cada uno es su ficha:
`docs/plan-verticales/<id>.md`.

## Marco
- Trabajas en un **worktree git aislado**: commits en tu rama, **nunca en `main`, sin push y sin releases**.
- Castellano y nombres descriptivos en castellano (variables, clases, archivos).
- `export PATH="$HOME/flutter/bin:$PATH"`. Prueba con `flutter analyze` y `flutter test` en `apps/solera-<id>`.

## Lee primero
1. El plan: la §4 (los 11 bloques estándar), la §5 (convivencia) y la §6 (contrato de autonomía).
2. Tu ficha.
3. **Referencias ya terminadas**: `apps/solera-obrador/` (estructura completa: `datos/base_datos.dart` sobre `BaseDatosSolera`, `dominio/` con lógica pura y tests, `servicios/generador_*_pdf.dart` con tablas puras y una constante literal `PROVISIONAL`, `compartir_documento`, `hoja_formulario`, `cambios_datos`, `utiles/textos_*`, tests de pantalla con `EntornoBaseDatosTemporal` y `tester.runAsync`, IA con `ClienteClaude.pedirJson` y clave BYO, ayuda en la app) y `apps/solera-frutal/` (cultivo: parcelas con GPS y mapa, cuaderno de explotación cotejado con el modelo andaluz v8, catálogos de fitosanitarios contrastados con el registro, IA de plagas, avisos de helada, REAGP). Para transformación y lotes: `apps/solera-aceitera/`.

## Bloque 1
Si tu app aún no existe: `scripts/nueva_vertical.sh` con los argumentos de la ficha (crea la app, su CSV de traducciones y el prefijo en el test de i18n del core). Tiene que acabar con analyze limpio y 3 tests verdes.

## Reglas de datos
- **Traducciones**: claves con tu prefijo, solo en `content/solera/traducciones/<id>.csv` (`clave,es,eu,ca,gl`; eu/ca/gl son borrador y las escribes tú). Para regenerar: `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`, y después `flutter test test/i18n` en el core (recorre todas las apps `solera-*`). Las claves comunes `guardar`, `cancelar`, `borrar`, `editar` y `ajustes` ya existen.
- **Catálogos** en `content/<id>/`, con `revisado_por`:
  - `revision-ia: <fuente y fecha>`: la fila la has contrastado tú contra un registro oficial.
  - `fuente_publica: <cita>`: sale de un documento público leído, sin contrastar.
  - vacío: sin fuente.
  - **Nunca `asesor:` ni `persona:`**, que son la firma humana: fingirla falsea la revisión. El indicador `catalogosCompletamenteRevisados` se queda en `false`.
- **Fitosanitarios, medicamentos veterinarios y plazos de seguridad o de espera**: contrasta cada fila con el Registro de Productos Fitosanitarios del MAPA y la EU Pesticides Database (o con CIMA Vet de la AEMPS para veterinaria). En la suite han aparecido sustancias retiradas (mancozeb, dimetomorfo, miclobutanil) y plazos de 0 días donde el registro da 28. Lo que no puedas contrastar va fuera del catálogo y apuntado en BLOQUEOS. **Nunca marcas comerciales.**
- **Normativa**: verifica en la web lo que uses en un PDF y cita el enlace. Lo que no verifiques va marcado «por verificar».

## Errores ya cometidos (no los repitas)
- `setState(() => _futuro = cargar())` devuelve el Future y Flutter lo rechaza. Usa cuerpo con llaves.
- Pasa `dart format` antes de editar por texto exacto, y comprueba que cada ancla aparece exactamente una vez.
- `DropdownButtonFormField` usa `initialValue`.
- Los tests con fechas necesitan `setUpAll(initializeDateFormatting)`.
- En los tests de pantalla, los botones fuera de la vista necesitan `scrollUntilVisible` con un `scrollable:` explícito.
- Importa el core con `show`, para evitar choques de nombres.
- **Hojas inferiores**: no liberes los `TextEditingController` justo al volver del `await showModalBottomSheet`, porque la animación de cierre aún los usa. Pásalos a la hoja para que los libere al desaparecer (`controladores:` en `hoja_formulario.dart` de Obrador o Sagardoa).
- **Android release**: `<uses-permission android:name="android.permission.INTERNET" />` en `android/app/src/main/AndroidManifest.xml` y `android:label="<Nombre visible>"`. La plantilla ya lo hace desde el commit 7736eb0; compruébalo.

## Cómo trabajar
- Un commit por bloque, o varios si pasan de 10 archivos. Prefijo `solera-<id>:`, más commits `core: textos de <Nombre> …` para tu CSV y el generado `solera_l10n.dart`. Termina cada mensaje de commit con:
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_01Pch7eaNE4mPB2k9Un3AjTf`
- **Al cerrar cada bloque**: analyze sin errores ni avisos nuevos, tests en verde, y `apps/solera-<id>/CLAUDE.md` al día (estado, siguiente acción, decisiones sin consultar con su porqué). Lo humano va a `BLOQUEOS-PENDIENTES.md`.
- **Fuera de tu app solo** puedes tocar `content/<id>/`, tu CSV de traducciones, el generado `packages/nuevo_ser_core/lib/src/i18n/solera_l10n.dart` y la línea del prefijo en el test de i18n del core (de esto se encarga el script). Nada más del core ni de otras apps. Si necesitas algo del core, hazlo dentro de tu app en `lib/provisional_core/` y apúntalo. **`apps/solera-zunbeltz/` y `wp-plugin/solera-zunbeltz-sync/` no se tocan**: solo se leen y se copian. Nada de builds ni de pub get ahí.
- **Si te atascas** (3 intentos razonables), apúntalo como bloqueo técnico, deja el código compilando y sigue. **No pares a preguntar.**
- **Bloque 8**: logo placeholder con ImageMagick (`convert`) e iconos con `flutter_launcher_icons`. Mira el resultado antes de commitear.
- **Bloque 11 (APK)**: comprueba que `df --output=avail -BG /home` da más de 8 GB. Después `flock /tmp/larrea-build-apk.lock flutter build apk --release`, copia la APK a `~/larrea-apks/solera-<id>-release.apk` y haz `flutter clean`.

## Al terminar, responde con
Bloques cerrados, número de tests, decisiones sin consultar, bloqueos humanos y técnicos, nombre de tu rama y `git log --oneline main..HEAD`. Sin maquillar: si algo quedó a medias, dilo.
