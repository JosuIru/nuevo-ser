# nuevo_ser_avisos

Avisos de la suite Larrea: notificaciones locales **programadas** (recordatorios
con hora: fases de una hornada, refresco de la masa madre…). Fuera de
`nuevo_ser_core` para que los juegos Kids no carguen con
`flutter_local_notifications`. Patrón de Larrea Zunbeltz
(`apps/solera-zunbeltz/lib/servicios/servicio_notificaciones.dart`), que conserva
su copia.

## API

```dart
final avisos = ServicioAvisosLocales(ConfiguracionAvisos(
  idCanal: 'obrador_avisos',               // estable: cambiarlo crea otro canal
  nombreCanal: SoleraL10n.t('avisos.canal_nombre'),
  // iconoAndroid: '@mipmap/ic_launcher', zonaHoraria: 'Europe/Madrid',
  // alarmasExactas: false,
));
await avisos.inicializar();
final hayPermiso = await avisos.pedirPermiso();   // Android 13+: POST_NOTIFICATIONS
await avisos.programar(clave: 'plan.7.amasado', cuando: hora, titulo: 'Amasar', cuerpo: '…');
await avisos.cancelar('plan.7.amasado');
await avisos.cancelarGrupo('plan.7.');            // todas las de un plan
final pendientes = await avisos.pendientes();     // con su clave
```

- Cada aviso se identifica con una **clave de texto**; el id del sistema sale de
  ella (`idDeClave`, FNV-1a de 31 bits, estable) y la clave viaja como
  `payload`, así `cancelarGrupo` funciona sin guardar nada aparte.
- `programar` en el pasado devuelve `false`. Volver a programar una clave la
  sustituye.
- **Nada lanza**: sin permiso, sin plugin (tests, escritorio, web) o con fallo
  del sistema, devuelve `false` / lista vacía. La app tiene que enseñar los
  avisos en pantalla igualmente: la notificación es un extra.
- Tests: `ServicioAvisosEnMemoria(reloj: …, permisoConcedido: …)` cumple la
  misma interfaz `ServicioAvisos`.
- Alarmas **inexactas** por defecto (Android puede retrasarlas unos minutos; no
  piden permiso aparte). `alarmasExactas: true` solo si de verdad hace falta: hay
  que declarar `SCHEDULE_EXACT_ALARM` y la persona tiene que concederlo en
  Ajustes; si no lo concede, se usan inexactas.
- Textos comunes en `content/solera/traducciones/avisos.csv` (claves `avisos.*`).

## Integrarlo en una app

1. `pubspec.yaml`:
   ```yaml
   nuevo_ser_avisos:
     path: ../../packages/nuevo_ser_avisos
   ```
2. `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
   <!-- Solo con alarmasExactas: true -->
   <!-- <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" /> -->
   ```
   y dentro de `<application>`:
   ```xml
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
       <intent-filter>
           <action android:name="android.intent.action.BOOT_COMPLETED"/>
           <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
           <action android:name="android.intent.action.QUICKBOOT_POWERON" />
           <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
       </intent-filter>
   </receiver>
   ```
3. `android/app/build.gradle.kts` (desugaring, lo exige el plugin):
   ```kotlin
   compileOptions {
       isCoreLibraryDesugaringEnabled = true
       // …
   }
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
   }
   ```
4. Opcional: un icono de silueta en `res/drawable` (Android pinta solo la
   transparencia del icono pequeño; el del lanzador sale como un cuadrado).

Referencia: Larrea Obrador (`apps/solera-obrador`), 2026-11-10.
