import WidgetKit
import SwiftUI

struct PrayerEntry: TimelineEntry {
    let date: Date
    let nextPrayerName: String
    let nextPrayerTime: String
    let remainingTime: String
    let cityName: String
    let hijriDate: String
    let fajrTime: String
    let sunriseTime: String
    let dhuhrTime: String
    let asrTime: String
    let maghribTime: String
    let ishaTime: String
    let activePrayer: String
}

struct Provider: TimelineProvider {
    let appGroupId = "group.com.example.moaqit"

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            nextPrayerName: "المغرب",
            nextPrayerTime: "06:14 PM",
            remainingTime: "01:25",
            cityName: "مكة المكرمة",
            hijriDate: "١٥ رمضان ١٤٤٨ هـ",
            fajrTime: "05:12 AM",
            sunriseTime: "06:30 AM",
            dhuhrTime: "12:28 PM",
            asrTime: "03:48 PM",
            maghribTime: "06:14 PM",
            ishaTime: "07:44 PM",
            activePrayer: "maghrib"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let entry = getEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getEntry() -> PrayerEntry {
        let prefs = UserDefaults(suiteName: appGroupId)
        return PrayerEntry(
            date: Date(),
            nextPrayerName: prefs?.string(forKey: "next_prayer_name") ?? "الفجر",
            nextPrayerTime: prefs?.string(forKey: "next_prayer_time") ?? "05:12 AM",
            remainingTime: prefs?.string(forKey: "remaining_time") ?? "02:15",
            cityName: prefs?.string(forKey: "city_name") ?? "مكة المكرمة",
            hijriDate: prefs?.string(forKey: "hijri_date") ?? "١٥ رمضان",
            fajrTime: prefs?.string(forKey: "fajr_time") ?? "05:12 AM",
            sunriseTime: prefs?.string(forKey: "sunrise_time") ?? "06:30 AM",
            dhuhrTime: prefs?.string(forKey: "dhuhr_time") ?? "12:28 PM",
            asrTime: prefs?.string(forKey: "asr_time") ?? "03:48 PM",
            maghribTime: prefs?.string(forKey: "maghrib_time") ?? "06:14 PM",
            ishaTime: prefs?.string(forKey: "isha_time") ?? "07:44 PM",
            activePrayer: prefs?.string(forKey: "active_prayer") ?? "fajr"
        )
    }
}

// 1. Compact Next-Prayer Widget View
struct CompactPrayerWidgetView: View {
    var entry: PrayerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.cityName)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.4))
                Spacer()
                Text(entry.hijriDate)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(entry.nextPrayerName)
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(.white)

            Text(entry.nextPrayerTime)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.9, green: 0.66, blue: 0.24))

            HStack {
                Text("المتبقي: \(entry.remainingTime)")
                    .font(.caption2)
                    .foregroundColor(Color(red: 0.1, green: 0.8, blue: 0.5))
                Spacer()
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.15, blue: 0.22), Color(red: 0.04, green: 0.08, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// 2. Full Daily Schedule Widget View
struct DailyScheduleWidgetView: View {
    var entry: PrayerEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(entry.cityName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.4))
                Spacer()
                Text(entry.hijriDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("الصلاة القادمة: \(entry.nextPrayerName)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("المتبقي: \(entry.remainingTime)")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.1, green: 0.8, blue: 0.5))
                }
                Spacer()
                Text(entry.nextPrayerTime)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(Color(red: 0.9, green: 0.66, blue: 0.24))
            }
            .padding(8)
            .background(Color.white.opacity(0.06))
            .cornerRadius(10)

            HStack(spacing: 6) {
                SchedulePill(title: "الفجر", time: entry.fajrTime, isActive: entry.activePrayer == "fajr")
                SchedulePill(title: "الظهر", time: entry.dhuhrTime, isActive: entry.activePrayer == "dhuhr")
                SchedulePill(title: "العصر", time: entry.asrTime, isActive: entry.activePrayer == "asr")
                SchedulePill(title: "المغرب", time: entry.maghribTime, isActive: entry.activePrayer == "maghrib")
                SchedulePill(title: "العشاء", time: entry.ishaTime, isActive: entry.activePrayer == "isha")
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.14, blue: 0.2), Color(red: 0.03, green: 0.06, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct SchedulePill: View {
    let title: String
    let time: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isActive ? Color(red: 1.0, green: 0.82, blue: 0.4) : .secondary)
            Text(time)
                .font(.system(size: 8))
                .fontWeight(isActive ? .bold : .regular)
                .foregroundColor(isActive ? .white : Color(white: 0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(isActive ? Color(red: 0.9, green: 0.66, blue: 0.24).opacity(0.2) : Color.clear)
        .cornerRadius(6)
    }
}

// 3. Translucent Glassmorphic Widget View
struct GlassmorphicPrayerWidgetView: View {
    var entry: PrayerEntry

    var body: some View {
        ZStack {
            // Glass backdrop blur effect
            Color.clear
                .background(.ultraThinMaterial)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.4))
                    Text(entry.cityName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Text(entry.hijriDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider().background(Color.white.opacity(0.2))

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.nextPrayerName)
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Text("ينتهي الوقت خلال: \(entry.remainingTime)")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.1, green: 0.8, blue: 0.5))
                    }
                    Spacer()
                    Text(entry.nextPrayerTime)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.9, green: 0.66, blue: 0.24))
                }
            }
            .padding(18)
        }
    }
}

@main
struct MawaqitWidgetBundle: WidgetBundle {
    var body: some Widget {
        MawaqitWidget()
    }
}

struct MawaqitWidget: Widget {
    let kind: String = "MawaqitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CompactPrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("Mawaqit مواقيت")
        .description("Accurate Islamic prayer times, countdowns, and Hijri dates.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
