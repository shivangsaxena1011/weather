import 'dart:math' as math;

/// Air quality data model containing AQI, pollen counts, and UV information.
class AirQualityModel {
  final int aqi;
  final double pm25;
  final double pm10;
  final double no2;
  final double o3;
  final double grassPollen;
  final double treePollen;
  final double weedPollen;
  final double uvIndex;

  const AirQualityModel({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.grassPollen,
    required this.treePollen,
    required this.weedPollen,
    required this.uvIndex,
  });

  /// Returns a mock/demo air quality model for UI development.
  factory AirQualityModel.mock() {
    return const AirQualityModel(
      aqi: 72,
      pm25: 18.4,
      pm10: 35.2,
      no2: 22.1,
      o3: 48.3,
      grassPollen: 35.0,
      treePollen: 12.0,
      weedPollen: 55.0,
      uvIndex: 6.5,
    );
  }

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? json;
    return AirQualityModel(
      aqi: (current['european_aqi'] as num? ?? 0).toInt().clamp(0, 500),
      pm25: math.max(0.0, (current['pm2_5'] as num? ?? 0).toDouble()),
      pm10: math.max(0.0, (current['pm10'] as num? ?? 0).toDouble()),
      no2: math.max(0.0, (current['nitrogen_dioxide'] as num? ?? 0).toDouble()),
      o3: math.max(0.0, (current['ozone'] as num? ?? 0).toDouble()),
      grassPollen: math.max(0.0, (current['grass_pollen'] as num? ?? 0).toDouble()),
      treePollen: math.max(0.0, (current['tree_pollen'] as num? ?? current['birch_pollen'] as num? ?? 0).toDouble()),
      weedPollen: math.max(0.0, (current['weed_pollen'] as num? ?? current['ragweed_pollen'] as num? ?? 0).toDouble()),
      uvIndex: (current['uv_index'] as num? ?? 0).toDouble().clamp(0.0, 25.0),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'aqi': aqi,
        'pm25': pm25,
        'pm10': pm10,
        'no2': no2,
        'o3': o3,
        'grassPollen': grassPollen,
        'treePollen': treePollen,
        'weedPollen': weedPollen,
        'uvIndex': uvIndex,
      };

  factory AirQualityModel.fromCacheJson(Map<String, dynamic> json) {
    return AirQualityModel(
      aqi: (json['aqi'] as num? ?? 0).toInt().clamp(0, 500),
      pm25: math.max(0.0, (json['pm25'] as num? ?? 0).toDouble()),
      pm10: math.max(0.0, (json['pm10'] as num? ?? 0).toDouble()),
      no2: math.max(0.0, (json['no2'] as num? ?? 0).toDouble()),
      o3: math.max(0.0, (json['o3'] as num? ?? 0).toDouble()),
      grassPollen: math.max(0.0, (json['grassPollen'] as num? ?? 0).toDouble()),
      treePollen: math.max(0.0, (json['treePollen'] as num? ?? 0).toDouble()),
      weedPollen: math.max(0.0, (json['weedPollen'] as num? ?? 0).toDouble()),
      uvIndex: (json['uvIndex'] as num? ?? 0).toDouble().clamp(0.0, 25.0),
    );
  }
}
