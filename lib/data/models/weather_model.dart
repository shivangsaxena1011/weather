// ignore_for_file: invalid_annotation_target
import 'dart:math' as math;

/// Represents hourly weather data for a single hour.
class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final double precipitationProbability;
  final double precipitation;
  final double windSpeed;
  final double windDirection;
  final int weatherCode;
  final double humidity;
  final double visibility;
  final double uvIndex;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.precipitationProbability,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    required this.humidity,
    required this.visibility,
    required this.uvIndex,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      feelsLike: (json['apparent_temperature'] as num).toDouble(),
      precipitationProbability:
          (json['precipitation_probability'] as num? ?? 0).toDouble(),
      precipitation: (json['precipitation'] as num? ?? 0).toDouble(),
      windSpeed: (json['wind_speed_10m'] as num? ?? 0).toDouble(),
      windDirection: (json['wind_direction_10m'] as num? ?? 0).toDouble(),
      weatherCode: (json['weather_code'] as num? ?? 0).toInt(),
      humidity: (json['relative_humidity_2m'] as num? ?? 0).toDouble(),
      visibility: (json['visibility'] as num? ?? 10000).toDouble(),
      uvIndex: (json['uv_index'] as num? ?? 0).toDouble(),
    );
  }
}

/// Represents daily weather data for a single day.
class DailyWeather {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double precipitationSum;
  final double precipitationProbabilityMax;
  final double windSpeedMax;
  final int weatherCode;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final double et0FaoEvapotranspiration;
  final double soilMoisture;

  const DailyWeather({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.windSpeedMax,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.et0FaoEvapotranspiration,
    required this.soilMoisture,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.parse(json['date'] as String),
      tempMin: (json['temperature_2m_min'] as num).toDouble(),
      tempMax: (json['temperature_2m_max'] as num).toDouble(),
      precipitationSum: (json['precipitation_sum'] as num? ?? 0).toDouble(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as num? ?? 0).toDouble(),
      windSpeedMax: (json['wind_speed_10m_max'] as num? ?? 0).toDouble(),
      weatherCode: (json['weather_code'] as num? ?? 0).toInt(),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
      uvIndexMax: (json['uv_index_max'] as num? ?? 0).toDouble(),
      et0FaoEvapotranspiration:
          (json['et0_fao_evapotranspiration'] as num? ?? 0).toDouble(),
      soilMoisture: (json['soil_moisture_0_to_10cm'] as num? ?? 30).toDouble(),
    );
  }
}

/// Top-level weather model with current conditions + hourly + daily.
class WeatherModel {
  final String cityName;
  final double latitude;
  final double longitude;
  final double currentTemp;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final int weatherCode;
  final double precipitation;
  final double precipitationProbability;
  final double visibility;
  final double uvIndex;
  final double dewPoint;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const WeatherModel({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.currentTemp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    required this.precipitation,
    required this.precipitationProbability,
    required this.visibility,
    required this.uvIndex,
    required this.dewPoint,
    required this.hourly,
    required this.daily,
  });

  /// Returns a mock/demo weather model for UI development.
  factory WeatherModel.mock() {
    final now = DateTime.now();
    final hourly = List.generate(48, (i) {
      final t = now.add(Duration(hours: i));
      return HourlyWeather(
        time: t,
        temperature: 22.0 + math.sin(i * 0.3) * 6,
        feelsLike: 21.0 + math.sin(i * 0.3) * 5,
        precipitationProbability: (i % 8 == 0) ? 75 : 15,
        precipitation: (i % 8 == 0) ? 2.5 : 0,
        windSpeed: 12.0 + math.cos(i * 0.2) * 4,
        windDirection: (i * 15.0) % 360,
        weatherCode: (i % 12 == 0) ? 95 : 1,
        humidity: 60 + math.sin(i * 0.4) * 15,
        visibility: 10000 - (i % 6 == 0 ? 5000 : 0),
        uvIndex: math.max(0, math.sin(i * math.pi / 12) * 8),
      );
    });

    final daily = List.generate(14, (i) {
      final d = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final sunrise = DateTime(d.year, d.month, d.day, 6, 10);
      final sunset = DateTime(d.year, d.month, d.day, 18, 45);
      return DailyWeather(
        date: d,
        tempMin: 16.0 + i * 0.2,
        tempMax: 28.0 + i * 0.1,
        precipitationSum: (i % 3 == 0) ? 8.0 : 0.5,
        precipitationProbabilityMax: (i % 3 == 0) ? 80 : 20,
        windSpeedMax: 20.0 + i * 0.5,
        weatherCode: (i % 3 == 0) ? 61 : 2,
        sunrise: sunrise,
        sunset: sunset,
        uvIndexMax: 7.0,
        et0FaoEvapotranspiration: 4.5 + i * 0.3,
        soilMoisture: 35.0 + i * 2,
      );
    });

    return WeatherModel(
      cityName: 'Mumbai',
      latitude: 19.0760,
      longitude: 72.8777,
      currentTemp: 26.4,
      feelsLike: 28.1,
      humidity: 72,
      windSpeed: 18.5,
      windDirection: 225,
      weatherCode: 2,
      precipitation: 0.0,
      precipitationProbability: 25,
      visibility: 9500,
      uvIndex: 6.5,
      dewPoint: 18.2,
      hourly: hourly,
      daily: daily,
    );
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyRaw = json['hourly'] as Map<String, dynamic>? ?? {};
    final dailyRaw = json['daily'] as Map<String, dynamic>? ?? {};

    final times = (hourlyRaw['time'] as List<dynamic>? ?? []).cast<String>();
    final hourly = List.generate(times.length, (i) {
      return HourlyWeather.fromJson({
        'time': times[i],
        'temperature_2m': hourlyRaw['temperature_2m']?[i] ?? 0,
        'apparent_temperature': hourlyRaw['apparent_temperature']?[i] ?? 0,
        'precipitation_probability':
            hourlyRaw['precipitation_probability']?[i] ?? 0,
        'precipitation': hourlyRaw['precipitation']?[i] ?? 0,
        'wind_speed_10m': hourlyRaw['wind_speed_10m']?[i] ?? 0,
        'wind_direction_10m': hourlyRaw['wind_direction_10m']?[i] ?? 0,
        'weather_code': hourlyRaw['weather_code']?[i] ?? 0,
        'relative_humidity_2m': hourlyRaw['relative_humidity_2m']?[i] ?? 0,
        'visibility': hourlyRaw['visibility']?[i] ?? 10000,
        'uv_index': hourlyRaw['uv_index']?[i] ?? 0,
      });
    });

    final dailyDates =
        (dailyRaw['time'] as List<dynamic>? ?? []).cast<String>();
    final daily = List.generate(dailyDates.length, (i) {
      return DailyWeather.fromJson({
        'date': dailyDates[i],
        'temperature_2m_min': dailyRaw['temperature_2m_min']?[i] ?? 0,
        'temperature_2m_max': dailyRaw['temperature_2m_max']?[i] ?? 0,
        'precipitation_sum': dailyRaw['precipitation_sum']?[i] ?? 0,
        'precipitation_probability_max':
            dailyRaw['precipitation_probability_max']?[i] ?? 0,
        'wind_speed_10m_max': dailyRaw['wind_speed_10m_max']?[i] ?? 0,
        'weather_code': dailyRaw['weather_code']?[i] ?? 0,
        'sunrise': dailyRaw['sunrise']?[i] ?? '${dailyDates[i]}T06:00',
        'sunset': dailyRaw['sunset']?[i] ?? '${dailyDates[i]}T18:00',
        'uv_index_max': dailyRaw['uv_index_max']?[i] ?? 0,
        'et0_fao_evapotranspiration':
            dailyRaw['et0_fao_evapotranspiration']?[i] ?? 0,
        'soil_moisture_0_to_10cm':
            dailyRaw['soil_moisture_0_to_10cm']?[i] ?? 30,
      });
    });

    return WeatherModel(
      cityName: json['timezone'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      currentTemp: (current['temperature_2m'] as num? ?? 0).toDouble(),
      feelsLike: (current['apparent_temperature'] as num? ?? 0).toDouble(),
      humidity: (current['relative_humidity_2m'] as num? ?? 0).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num? ?? 0).toDouble(),
      windDirection: (current['wind_direction_10m'] as num? ?? 0).toDouble(),
      weatherCode: (current['weather_code'] as num? ?? 0).toInt(),
      precipitation: (current['precipitation'] as num? ?? 0).toDouble(),
      precipitationProbability:
          (current['precipitation_probability'] as num? ?? 0).toDouble(),
      visibility: (current['visibility'] as num? ?? 10000).toDouble(),
      uvIndex: (current['uv_index'] as num? ?? 0).toDouble(),
      dewPoint: (current['dew_point_2m'] as num? ?? 0).toDouble(),
      hourly: hourly,
      daily: daily,
    );
  }
}
