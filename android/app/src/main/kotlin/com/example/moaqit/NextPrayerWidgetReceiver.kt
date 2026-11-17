package com.example.moaqit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class NextPrayerWidgetReceiver : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.next_prayer_widget).apply {
                val nextPrayerName = widgetData.getString("next_prayer_name", "الفجر")
                val nextPrayerTime = widgetData.getString("next_prayer_time", "05:12 AM")
                val remainingTime = widgetData.getString("remaining_time", "01:30")
                val cityName = widgetData.getString("city_name", "مكة المكرمة")
                val hijriDate = widgetData.getString("hijri_date", "١٥ رمضان")

                setTextViewText(R.id.widget_next_prayer_name, nextPrayerName)
                setTextViewText(R.id.widget_next_prayer_time, nextPrayerTime)
                setTextViewText(R.id.widget_remaining_time, "المتبقي: $remainingTime")
                setTextViewText(R.id.widget_city, cityName)
                setTextViewText(R.id.widget_hijri, hijriDate)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
