/// Marine weather data model with wave and sea temperature information.
class MarineModel {
  final double waveHeight;
  final double wavePeriod;
  final double waveDirection;
  final double swellWaveHeight;
  final double swellWaveDirection;
  final double seaTemperature;
  final double nextHighTideHeight;
  final DateTime nextHighTideTime;
  final double nextLowTideHeight;
  final DateTime nextLowTideTime;

  const MarineModel({
    required this.waveHeight,
    required this.wavePeriod,
    required this.waveDirection,
    required this.swellWaveHeight,
    required this.swellWaveDirection,
    required this.seaTemperature,
    required this.nextHighTideHeight,
    required this.nextHighTideTime,
    required this.nextLowTideHeight,
    required this.nextLowTideTime,
  });

  /// Returns a mock/demo marine model for UI development.
  factory MarineModel.mock() {
    final now = DateTime.now();
    return MarineModel(
      waveHeight: 1.2,
      wavePeriod: 8.5,
      waveDirection: 270,
      swellWaveHeight: 0.9,
      swellWaveDirection: 255,
      seaTemperature: 26.5,
      nextHighTideHeight: 1.85,
      nextHighTideTime: now.add(const Duration(hours: 3, minutes: 15)),
      nextLowTideHeight: 0.35,
      nextLowTideTime: now.add(const Duration(hours: 9, minutes: 40)),
    );
  }

  factory MarineModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? json;
    final now = DateTime.now();
    return MarineModel(
      waveHeight: (current['wave_height'] as num? ?? 0).toDouble(),
      wavePeriod: (current['wave_period'] as num? ?? 0).toDouble(),
      waveDirection: (current['wave_direction'] as num? ?? 0).toDouble(),
      swellWaveHeight: (current['swell_wave_height'] as num? ?? 0).toDouble(),
      swellWaveDirection:
          (current['swell_wave_direction'] as num? ?? 0).toDouble(),
      seaTemperature: (current['sea_surface_temperature'] as num? ?? 0).toDouble(),
      nextHighTideHeight: (current['next_high_tide_height'] as num? ?? 1.5).toDouble(),
      nextHighTideTime: current['next_high_tide_time'] != null
          ? DateTime.parse(current['next_high_tide_time'] as String)
          : now.add(const Duration(hours: 3)),
      nextLowTideHeight: (current['next_low_tide_height'] as num? ?? 0.3).toDouble(),
      nextLowTideTime: current['next_low_tide_time'] != null
          ? DateTime.parse(current['next_low_tide_time'] as String)
          : now.add(const Duration(hours: 9)),
    );
  }
}
