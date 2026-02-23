package com.bardino.zodi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class DailyHoroscopeWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )

            val zodiacSymbol = prefs.getString("flutter.widget_zodiac_symbol", "\u2B50") ?: "\u2B50"
            val zodiacName = prefs.getString("flutter.widget_zodiac_name", "Bur\u00E7 Se\u00E7") ?: "Bur\u00E7 Se\u00E7"
            val motto = prefs.getString("flutter.widget_motto", "G\u00FCnl\u00FCk yorumun i\u00E7in uygulamay\u0131 a\u00E7!") ?: "G\u00FCnl\u00FCk yorumun i\u00E7in uygulamay\u0131 a\u00E7!"
            val moodEmoji = prefs.getString("flutter.widget_mood_emoji", "\u2728") ?: "\u2728"

            val views = RemoteViews(context.packageName, R.layout.daily_horoscope_widget)
            views.setTextViewText(R.id.widget_zodiac_symbol, zodiacSymbol)
            views.setTextViewText(R.id.widget_zodiac_name, zodiacName)
            views.setTextViewText(R.id.widget_motto, motto)
            views.setTextViewText(R.id.widget_mood, moodEmoji)

            // Open app on click
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context, 0, intent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
