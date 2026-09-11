class ApiEndpoints {
  ApiEndpoints._();

  static const String weatherBase = 'https://api.open-meteo.com/v1/forecast';
  static const String airQualityBase =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const String marineBase = 'https://marine-api.open-meteo.com/v1/marine';
  static const String geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String nominatimReverse =
      'https://nominatim.openstreetmap.org/reverse';
}
