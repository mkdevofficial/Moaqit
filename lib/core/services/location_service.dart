import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/constants/app_constants.dart';
import 'package:moaqit/core/services/storage_service.dart';

class UserLocation {
  final String cityNameAr;
  final String cityNameEn;
  final String countryNameAr;
  final String countryEn;
  final double latitude;
  final double longitude;
  final bool isGps;

  const UserLocation({
    required this.cityNameAr,
    required this.cityNameEn,
    required this.countryNameAr,
    required this.countryEn,
    required this.latitude,
    required this.longitude,
    required this.isGps,
  });

  String displayName(bool isArabic) => isArabic ? cityNameAr : cityNameEn;
  String displayCountry(bool isArabic) => isArabic ? countryNameAr : countryEn;
}

final currentLocationProvider =
    NotifierProvider<LocationNotifier, UserLocation>(() {
  return LocationNotifier();
});

class LocationNotifier extends Notifier<UserLocation> {
  @override
  UserLocation build() {
    final storage = ref.watch(storageServiceProvider);

    final savedCityAr = storage.getString('loc_city_ar');
    final savedCityEn = storage.getString('loc_city_en');
    final savedCountryAr = storage.getString('loc_country_ar');
    final savedCountryEn = storage.getString('loc_country_en');
    final savedLat = storage.getDouble('loc_lat');
    final savedLng = storage.getDouble('loc_lng');
    final isGps = storage.getBool('loc_is_gps') ?? false;

    if (savedCityAr != null && savedLat != null && savedLng != null) {
      return UserLocation(
        cityNameAr: savedCityAr,
        cityNameEn: savedCityEn ?? savedCityAr,
        countryNameAr: savedCountryAr ?? '',
        countryEn: savedCountryEn ?? '',
        latitude: savedLat,
        longitude: savedLng,
        isGps: isGps,
      );
    }

    // Default to Makkah Al-Mukarramah
    final makkah = AppConstants.cities.first;
    return UserLocation(
      cityNameAr: makkah.nameAr,
      cityNameEn: makkah.nameEn,
      countryNameAr: makkah.countryAr,
      countryEn: makkah.countryEn,
      latitude: makkah.latitude,
      longitude: makkah.longitude,
      isGps: false,
    );
  }

  Future<void> selectCity(CityData city) async {
    state = UserLocation(
      cityNameAr: city.nameAr,
      cityNameEn: city.nameEn,
      countryNameAr: city.countryAr,
      countryEn: city.countryEn,
      latitude: city.latitude,
      longitude: city.longitude,
      isGps: false,
    );

    final storage = ref.read(storageServiceProvider);
    await storage.setString('loc_city_ar', city.nameAr);
    await storage.setString('loc_city_en', city.nameEn);
    await storage.setString('loc_country_ar', city.countryAr);
    await storage.setString('loc_country_en', city.countryEn);
    await storage.setDouble('loc_lat', city.latitude);
    await storage.setDouble('loc_lng', city.longitude);
    await storage.setBool('loc_is_gps', false);
  }

  Future<bool> detectGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String city = 'الموقع الحالي';
      String cityEn = 'Current Location';
      String country = '';
      String countryEn = '';

      try {
        final geocoding = Geocoding();
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'الموقع الحالي';
          cityEn = place.locality ?? place.name ?? 'Current Location';
          country = place.country ?? '';
          countryEn = place.isoCountryCode ?? place.country ?? '';
        }
      } catch (_) {
        // Fallback names
      }

      state = UserLocation(
        cityNameAr: city,
        cityNameEn: cityEn,
        countryNameAr: country,
        countryEn: countryEn,
        latitude: position.latitude,
        longitude: position.longitude,
        isGps: true,
      );

      final storage = ref.read(storageServiceProvider);
      await storage.setString('loc_city_ar', city);
      await storage.setString('loc_city_en', cityEn);
      await storage.setString('loc_country_ar', country);
      await storage.setString('loc_country_en', countryEn);
      await storage.setDouble('loc_lat', position.latitude);
      await storage.setDouble('loc_lng', position.longitude);
      await storage.setBool('loc_is_gps', true);

      return true;
    } catch (_) {
      return false;
    }
  }
}
