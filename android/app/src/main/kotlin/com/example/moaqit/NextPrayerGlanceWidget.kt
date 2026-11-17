package com.example.moaqit

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Modern Jetpack Glance Widget Implementation for Mawaqit
 * Supports:
 * 1. Compact Next-Prayer
 * 2. Full Daily Schedule
 * 3. Translucent Glassmorphic appearance
 */
class NextPrayerGlanceWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = HomeWidgetPlugin.getData(context)
        val nextPrayerName = prefs.getString("next_prayer_name", "الفجر") ?: "الفجر"
        val nextPrayerTime = prefs.getString("next_prayer_time", "05:12 AM") ?: "05:12 AM"
        val remainingTime = prefs.getString("remaining_time", "02:15") ?: "02:15"
        val cityName = prefs.getString("city_name", "مكة المكرمة") ?: "مكة المكرمة"
        val hijriDate = prefs.getString("hijri_date", "١٥ رمضان ١٤٤٨ هـ") ?: "١٥ رمضان ١٤٤٨ هـ"

        // Schedule times
        val fajr = prefs.getString("fajr_time", "05:12 AM") ?: "05:12 AM"
        val dhuhr = prefs.getString("dhuhr_time", "12:28 PM") ?: "12:28 PM"
        val asr = prefs.getString("asr_time", "03:48 PM") ?: "03:48 PM"
        val maghrib = prefs.getString("maghrib_time", "06:14 PM") ?: "06:14 PM"
        val isha = prefs.getString("isha_time", "07:44 PM") ?: "07:44 PM"

        provideContent {
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(Color(0xE60D1720))
                    .padding(16.dp)
            ) {
                Column(modifier = GlanceModifier.fillMaxSize()) {
                    // Header: City + Hijri
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        horizontalAlignment = Alignment.End
                    ) {
                        Text(
                            text = cityName,
                            style = TextStyle(
                                color = ColorProvider(Color(0xFFFFD166)),
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Spacer(modifier = GlanceModifier.defaultWeight())
                        Text(
                            text = hijriDate,
                            style = TextStyle(
                                color = ColorProvider(Color(0xFF90A4AE)),
                                fontSize = 12.sp
                            )
                        )
                    }

                    Spacer(modifier = GlanceModifier.height(10.dp))

                    // Next Prayer Hero Row
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "الصلاة القادمة: $nextPrayerName",
                                style = TextStyle(
                                    color = ColorProvider(Color.White),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                            Text(
                                text = "المتبقي: $remainingTime",
                                style = TextStyle(
                                    color = ColorProvider(Color(0xFF10B981)),
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            )
                        }
                        Spacer(modifier = GlanceModifier.defaultWeight())
                        Text(
                            text = nextPrayerTime,
                            style = TextStyle(
                                color = ColorProvider(Color(0xFFE5A93C)),
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }

                    Spacer(modifier = GlanceModifier.height(10.dp))

                    // Daily Schedule Horizontal Strip
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        ScheduleColumn(name = "فجر", time = fajr)
                        ScheduleColumn(name = "ظهر", time = dhuhr)
                        ScheduleColumn(name = "عصر", time = asr)
                        ScheduleColumn(name = "مغرب", time = maghrib)
                        ScheduleColumn(name = "عشاء", time = isha)
                    }
                }
            }
        }
    }

    @androidx.compose.runtime.Composable
    private fun ScheduleColumn(name: String, time: String) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = GlanceModifier.padding(horizontal = 4.dp)
        ) {
            Text(
                text = name,
                style = TextStyle(
                    color = ColorProvider(Color(0xFFB0BEC5)),
                    fontSize = 11.sp
                )
            )
            Text(
                text = time,
                style = TextStyle(
                    color = ColorProvider(Color.White),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Medium
                )
            )
        }
    }
}
