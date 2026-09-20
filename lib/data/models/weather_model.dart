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

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temperature_2m': temperature,
        'apparent_temperature': feelsLike,
        'precipitation_probability': precipitationProbability,
        'precipitation': precipitation,
        'wind_speed_10m': windSpeed,
        'wind_direction_10m': windDirection,
        'weather_code': weatherCode,
        'relative_humidity_2m': humidity,
        'visibility': visibility,
        'uv_index': uvIndex,
      };
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

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'temperature_2m_min': tempMin,
        'temperature_2m_max': tempMax,
        'precipitation_sum': precipitationSum,
        'precipitation_probability_max': precipitationProbabilityMax,
        'wind_speed_10m_max': windSpeedMax,
        'weather_code': weatherCode,
        'sunrise': sunrise.toIso8601String(),
        'sunset': sunset.toIso8601String(),
        'uv_index_max': uvIndexMax,
        'et0_fao_evapotranspiration': et0FaoEvapotranspiration,
        'soil_moisture_0_to_10cm': soilMoisture,
      };
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
  final int utcOffsetSeconds;
  final String timezoneName;

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
    this.utcOffsetSeconds = 0,
    this.timezoneName = 'UTC',
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

  factory WeatherModel.fromJson(Map<String, dynamic> json, {String? cityName}) {
    final current = (json['current'] as Map<String, dynamic>?) ?? {};
    final hourlyRaw = json['hourly'] as Map<String, dynamic>? ?? {};
    final dailyRaw = json['daily'] as Map<String, dynamic>? ?? {};

    final times = (hourlyRaw['time'] as List<dynamic>? ?? []).cast<String>();
    final hourly = List.generate(times.length, (i) {
      final t = (hourlyRaw['temperature_2m']?[i] as num? ?? 20).toDouble().clamp(-90.0, 60.0);
      final fl = (hourlyRaw['apparent_temperature']?[i] as num? ?? t).toDouble().clamp(-90.0, 65.0);
      final pProb = (hourlyRaw['precipitation_probability']?[i] as num? ?? 0).toDouble().clamp(0.0, 100.0);
      final pMm = math.max(0.0, (hourlyRaw['precipitation']?[i] as num? ?? 0).toDouble());
      final ws = (hourlyRaw['wind_speed_10m']?[i] as num? ?? 0).toDouble().clamp(0.0, 350.0);
      final wd = (hourlyRaw['wind_direction_10m']?[i] as num? ?? 0).toDouble().clamp(0.0, 360.0);
      final code = (hourlyRaw['weather_code']?[i] as num? ?? 0).toInt().clamp(0, 99);
      final hum = (hourlyRaw['relative_humidity_2m']?[i] as num? ?? 50).toDouble().clamp(0.0, 100.0);
      final vis = math.max(0.0, (hourlyRaw['visibility']?[i] as num? ?? 10000).toDouble());
      final uv = (hourlyRaw['uv_index']?[i] as num? ?? 0).toDouble().clamp(0.0, 25.0);

      return HourlyWeather(
        time: DateTime.tryParse(times[i]) ?? DateTime.now(),
        temperature: t,
        feelsLike: fl,
        precipitationProbability: pProb,
        precipitation: pMm,
        windSpeed: ws,
        windDirection: wd,
        weatherCode: code,
        humidity: hum,
        visibility: vis,
        uvIndex: uv,
      );
    });

    final dailyDates =
        (dailyRaw['time'] as List<dynamic>? ?? []).cast<String>();
    final daily = List.generate(dailyDates.length, (i) {
      final tMin = (dailyRaw['temperature_2m_min']?[i] as num? ?? 10).toDouble().clamp(-90.0, 60.0);
      final tMax = (dailyRaw['temperature_2m_max']?[i] as num? ?? 25).toDouble().clamp(-90.0, 60.0);
      final pSum = math.max(0.0, (dailyRaw['precipitation_sum']?[i] as num? ?? 0).toDouble());
      final pMaxProb = (dailyRaw['precipitation_probability_max']?[i] as num? ?? 0).toDouble().clamp(0.0, 100.0);
      final wsMax = (dailyRaw['wind_speed_10m_max']?[i] as num? ?? 0).toDouble().clamp(0.0, 350.0);
      final code = (dailyRaw['weather_code']?[i] as num? ?? 0).toInt().clamp(0, 99);
      final sRiseStr = dailyRaw['sunrise']?[i] as String? ?? '${dailyDates[i]}T06:00';
      final sSetStr = dailyRaw['sunset']?[i] as String? ?? '${dailyDates[i]}T18:00';
      final uvMax = (dailyRaw['uv_index_max']?[i] as num? ?? 0).toDouble().clamp(0.0, 25.0);
      final et0 = math.max(0.0, (dailyRaw['et0_fao_evapotranspiration']?[i] as num? ?? 0).toDouble());
      final hourlySoil = (hourlyRaw['soil_moisture_0_to_10cm'] as List<dynamic>?);
      double soilVal = 35.0;
      if (hourlySoil != null && i * 24 < hourlySoil.length && hourlySoil[i * 24] != null) {
        final raw = (hourlySoil[i * 24] as num).toDouble();
        soilVal = raw <= 1.0 ? raw * 100 : raw;
      } else if (dailyRaw['soil_moisture_0_to_10cm']?[i] != null) {
        soilVal = (dailyRaw['soil_moisture_0_to_10cm']?[i] as num).toDouble();
      }
      final soil = soilVal.clamp(0.0, 100.0);

      final dateParsed = DateTime.tryParse(dailyDates[i]) ?? DateTime.now();
      return DailyWeather(
        date: dateParsed,
        tempMin: tMin,
        tempMax: tMax,
        precipitationSum: pSum,
        precipitationProbabilityMax: pMaxProb,
        windSpeedMax: wsMax,
        weatherCode: code,
        sunrise: DateTime.tryParse(sRiseStr) ?? DateTime(dateParsed.year, dateParsed.month, dateParsed.day, 6),
        sunset: DateTime.tryParse(sSetStr) ?? DateTime(dateParsed.year, dateParsed.month, dateParsed.day, 18),
        uvIndexMax: uvMax,
        et0FaoEvapotranspiration: et0,
        soilMoisture: soil,
      );
    });

    final lat = (json['latitude'] as num? ?? 0).toDouble().clamp(-90.0, 90.0);
    final lon = (json['longitude'] as num? ?? 0).toDouble().clamp(-180.0, 180.0);
    final curTemp = (current['temperature_2m'] as num? ?? 20).toDouble().clamp(-90.0, 60.0);
    final curFeels = (current['apparent_temperature'] as num? ?? curTemp).toDouble().clamp(-90.0, 65.0);
    final curHum = (current['relative_humidity_2m'] as num? ?? 50).toDouble().clamp(0.0, 100.0);
    final curWind = (current['wind_speed_10m'] as num? ?? 0).toDouble().clamp(0.0, 350.0);
    final curWindDir = (current['wind_direction_10m'] as num? ?? 0).toDouble().clamp(0.0, 360.0);
    final curCode = (current['weather_code'] as num? ?? 0).toInt().clamp(0, 99);
    final curPrecip = math.max(0.0, (current['precipitation'] as num? ?? 0).toDouble());
    final curPrecipProb = (current['precipitation_probability'] as num? ?? 0).toDouble().clamp(0.0, 100.0);
    final curVis = math.max(0.0, (current['visibility'] as num? ?? 10000).toDouble());
    final curUv = (current['uv_index'] as num? ?? 0).toDouble().clamp(0.0, 25.0);
    final curDew = (current['dew_point_2m'] as num? ?? 12).toDouble().clamp(-90.0, 50.0);
    final offset = (json['utc_offset_seconds'] as num? ?? 0).toInt();
    final tz = json['timezone'] as String? ?? 'UTC';

    return WeatherModel(
      cityName: cityName ?? (json['cityName'] as String? ?? (json['timezone'] as String? ?? 'Unknown')),
      latitude: lat,
      longitude: lon,
      currentTemp: curTemp,
      feelsLike: curFeels,
      humidity: curHum,
      windSpeed: curWind,
      windDirection: curWindDir,
      weatherCode: curCode,
      precipitation: curPrecip,
      precipitationProbability: curPrecipProb,
      visibility: curVis,
      uvIndex: curUv,
      dewPoint: curDew,
      hourly: hourly,
      daily: daily,
      utcOffsetSeconds: offset,
      timezoneName: tz,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'cityName': cityName,
        'latitude': latitude,
        'longitude': longitude,
        'currentTemp': currentTemp,
        'feelsLike': feelsLike,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDirection': windDirection,
        'weatherCode': weatherCode,
        'precipitation': precipitation,
        'precipitationProbability': precipitationProbability,
        'visibility': visibility,
        'uvIndex': uvIndex,
        'dewPoint': dewPoint,
        'hourly': hourly.map((h) => h.toJson()).toList(),
        'daily': daily.map((d) => d.toJson()).toList(),
        'utcOffsetSeconds': utcOffsetSeconds,
        'timezoneName': timezoneName,
      };

  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num? ?? 0).toDouble().clamp(-90.0, 90.0),
      longitude: (json['longitude'] as num? ?? 0).toDouble().clamp(-180.0, 180.0),
      currentTemp: (json['currentTemp'] as num? ?? 20).toDouble().clamp(-90.0, 60.0),
      feelsLike: (json['feelsLike'] as num? ?? 20).toDouble().clamp(-90.0, 65.0),
      humidity: (json['humidity'] as num? ?? 50).toDouble().clamp(0.0, 100.0),
      windSpeed: (json['windSpeed'] as num? ?? 0).toDouble().clamp(0.0, 350.0),
      windDirection: (json['windDirection'] as num? ?? 0).toDouble().clamp(0.0, 360.0),
      weatherCode: (json['weatherCode'] as num? ?? 0).toInt().clamp(0, 99),
      precipitation: math.max(0.0, (json['precipitation'] as num? ?? 0).toDouble()),
      precipitationProbability:
          (json['precipitationProbability'] as num? ?? 0).toDouble().clamp(0.0, 100.0),
      visibility: math.max(0.0, (json['visibility'] as num? ?? 10000).toDouble()),
      uvIndex: (json['uvIndex'] as num? ?? 0).toDouble().clamp(0.0, 25.0),
      dewPoint: (json['dewPoint'] as num? ?? 12).toDouble().clamp(-90.0, 50.0),
      hourly: ((json['hourly'] as List<dynamic>?) ?? [])
          .map((h) => HourlyWeather.fromJson(h as Map<String, dynamic>))
          .toList(),
      daily: ((json['daily'] as List<dynamic>?) ?? [])
          .map((d) => DailyWeather.fromJson(d as Map<String, dynamic>))
          .toList(),
      utcOffsetSeconds: (json['utcOffsetSeconds'] as num? ?? 0).toInt(),
      timezoneName: json['timezoneName'] as String? ?? 'UTC',
    );
  }
}
