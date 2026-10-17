package com.coleccionnuevoser.solera_zunbeltz

import android.app.ActivityOptions
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget «Hoy en Zunbeltz» de la pantalla de inicio. Solo pinta: los textos,
 * ya traducidos, los compone la app (lib/servicios/widget_hoy.dart) y los deja
 * en las preferencias del widget con las claves `zw_*`. Cada botón abre la
 * app con un enlace `zunbeltz://…` que atiende lib/pantallas/acciones_widget_hoy.dart.
 */
class WidgetHoyZunbeltz : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (idWidget in appWidgetIds) {
            pintar(context, appWidgetManager, idWidget, widgetData)
        }
    }

    /** Al cambiar de tamaño: con poco alto se quitan filas, no se cortan. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        pintar(
            context,
            appWidgetManager,
            appWidgetId,
            context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE),
        )
    }

    private fun pintar(
        context: Context,
        appWidgetManager: AppWidgetManager,
        idWidget: Int,
        datos: SharedPreferences,
    ) {
        val vistas = RemoteViews(context.packageName, R.layout.widget_hoy)
        val hayDatos = datos.contains("zw_tareas")
        fun texto(clave: String, porDefecto: String = "") =
            datos.getString(clave, null) ?: porDefecto

        vistas.setTextViewText(
            R.id.titulo, texto("zw_titulo", context.getString(R.string.widget_hoy_nombre)))
        vistas.setTextViewText(R.id.actualizado, texto("zw_actualizado"))

        val alarmas = texto("zw_alarmas")
        vistas.setTextViewText(R.id.texto_alarmas, alarmas)

        vistas.setTextViewText(
            R.id.texto_tareas, texto("zw_tareas", context.getString(R.string.widget_hoy_abre_app)))
        val senal = context.getColor(R.color.zunbeltz_senal)
        val monte = context.getColor(R.color.zunbeltz_monte)
        vistas.setInt(
            R.id.icono_tareas, "setColorFilter",
            if (datos.getBoolean("zw_tareas_urgentes", false)) senal else monte)

        vistas.setTextViewText(R.id.texto_supresion, texto("zw_supresion"))
        vistas.setInt(
            R.id.icono_supresion, "setColorFilter",
            if (datos.getBoolean("zw_supresion_activa", false)) senal else monte)
        vistas.setTextViewText(R.id.texto_tiempo, texto("zw_tiempo"))

        // Con poco alto no se cortan filas: se enseñan por orden de
        // importancia (alarma, tareas, supresión, tiempo) mientras quepan.
        val (ancho, alto) = tamanoEnDp(context, appWidgetManager, idWidget)
        val hayBotones = datos.getBoolean("zw_puede_avisos", true) ||
            datos.getBoolean("zw_puede_ganado", true)
        var sitio = if (alto <= 0) Int.MAX_VALUE
            else alto - 24 - 30 - (if (hayBotones) 44 else 0)
        fun cabe(texto: String, extra: Int = 0): Boolean {
            if (texto.isEmpty()) return false
            val alturaFila = 6 + extra + 18 * lineas(texto, ancho)
            if (alturaFila > sitio) return false
            sitio -= alturaFila
            return true
        }
        // La alarma sale siempre, quepa o no.
        val verAlarmas = alarmas.isNotEmpty()
        if (verAlarmas && !cabe(alarmas, extra = 8)) sitio = 0
        cabe(texto("zw_tareas", "-"))
        val verSupresion = hayDatos && cabe(texto("zw_supresion"))
        val verTiempo = hayDatos && cabe(texto("zw_tiempo"))
        vistas.setViewVisibility(R.id.fila_alarmas, if (verAlarmas) View.VISIBLE else View.GONE)
        vistas.setViewVisibility(R.id.fila_supresion, if (verSupresion) View.VISIBLE else View.GONE)
        vistas.setViewVisibility(R.id.fila_tiempo, if (verTiempo) View.VISIBLE else View.GONE)

        vistas.setTextViewText(
            R.id.boton_aviso, texto("zw_boton_aviso", context.getString(R.string.widget_boton_aviso)))
        vistas.setTextViewText(
            R.id.boton_mover, texto("zw_boton_mover", context.getString(R.string.widget_boton_mover)))
        vistas.setTextViewText(
            R.id.boton_cura, texto("zw_boton_cura", context.getString(R.string.widget_boton_cura)))
        val puedeAvisos = datos.getBoolean("zw_puede_avisos", true)
        val puedeGanado = datos.getBoolean("zw_puede_ganado", true)
        vistas.setViewVisibility(R.id.boton_aviso, if (puedeAvisos) View.VISIBLE else View.GONE)
        vistas.setViewVisibility(R.id.boton_mover, if (puedeGanado) View.VISIBLE else View.GONE)
        vistas.setViewVisibility(R.id.boton_cura, if (puedeGanado) View.VISIBLE else View.GONE)
        vistas.setViewVisibility(
            R.id.fila_botones, if (puedeAvisos || puedeGanado) View.VISIBLE else View.GONE)

        fun abrir(enlace: String) = intencionAbrir(context, enlace)
        vistas.setOnClickPendingIntent(R.id.raiz, abrir("hoy"))
        vistas.setOnClickPendingIntent(R.id.fila_supresion, abrir("ganado"))
        vistas.setOnClickPendingIntent(R.id.boton_aviso, abrir("nuevo-aviso"))
        vistas.setOnClickPendingIntent(R.id.boton_mover, abrir("mover-lote"))
        vistas.setOnClickPendingIntent(R.id.boton_cura, abrir("apuntar-cura"))

        appWidgetManager.updateAppWidget(idWidget, vistas)
    }

    /** Ancho y alto en dp: en vertical, el ancho mínimo y el alto máximo. */
    private fun tamanoEnDp(
        context: Context,
        appWidgetManager: AppWidgetManager,
        idWidget: Int,
    ): Pair<Int, Int> {
        val opciones = appWidgetManager.getAppWidgetOptions(idWidget)
        val vertical = context.resources.configuration.orientation ==
            Configuration.ORIENTATION_PORTRAIT
        return if (vertical) {
            opciones.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) to
                opciones.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
        } else {
            opciones.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, 0) to
                opciones.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        }
    }

    /** Líneas que ocupa un texto de 13 sp en una fila (como mucho 2). */
    private fun lineas(texto: String, anchoDp: Int): Int {
        if (anchoDp <= 0) return 1
        val anchoTexto = (anchoDp - 24 - 26).coerceAtLeast(60)
        val caracteresPorLinea = (anchoTexto / 6.8).toInt().coerceAtLeast(1)
        return ((texto.length + caracteresPorLinea - 1) / caracteresPorLinea).coerceIn(1, 2)
    }

    /**
     * Como `HomeWidgetLaunchIntent.getActivity`, pero con un código de
     * petición por enlace: con el mismo código, Android acaba dando a todos
     * los botones el último enlace que se pintó.
     */
    private fun intencionAbrir(context: Context, enlace: String): PendingIntent {
        val intencion = Intent(context, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            data = Uri.parse("zunbeltz://$enlace")
        }
        val banderas = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val codigo = ENLACES.indexOf(enlace) + 1
        if (Build.VERSION.SDK_INT < 34) {
            return PendingIntent.getActivity(context, codigo, intencion, banderas)
        }
        val opciones = ActivityOptions.makeBasic()
        if (Build.VERSION.SDK_INT >= 35) {
            opciones.setPendingIntentCreatorBackgroundActivityStartMode(
                ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED)
        } else {
            @Suppress("DEPRECATION")
            opciones.pendingIntentBackgroundActivityStartMode =
                ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
        }
        return PendingIntent.getActivity(context, codigo, intencion, banderas, opciones.toBundle())
    }

    private companion object {
        val ENLACES = listOf("hoy", "ganado", "nuevo-aviso", "mover-lote", "apuntar-cura")
    }
}
