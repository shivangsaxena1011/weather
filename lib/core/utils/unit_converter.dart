enum TemperatureUnit { celsius, fahrenheit }
enum WindSpeedUnit { kmh, mph, ms }
enum PressureUnit { hpa, inhg }

class UnitSettings {
  final TemperatureUnit tempUnit;
  final WindSpeedUnit windUnit;
  final PressureUnit pressureUnit;

  const UnitSettings({
    this.tempUnit = TemperatureUnit.celsius,
    this.windUnit = WindSpeedUnit.kmh,
    this.pressureUnit = PressureUnit.hpa,
  });

  UnitSettings copyWith({
    TemperatureUnit? tempUnit,
    WindSpeedUnit? windUnit,
    PressureUnit? pressureUnit,
  }) {
    return UnitSettings(
      tempUnit: tempUnit ?? this.tempUnit,
      windUnit: windUnit ?? this.windUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
    );
  }

  Map<String, dynamic> toJson() => {
        'tempUnit': tempUnit.name,
        'windUnit': windUnit.name,
        'pressureUnit': pressureUnit.name,
      };

  factory UnitSettings.fromJson(Map<String, dynamic> json) {
    return UnitSettings(
      tempUnit: TemperatureUnit.values.firstWhere(
        (e) => e.name == json['tempUnit'],
        orElse: () => TemperatureUnit.celsius,
      ),
      windUnit: WindSpeedUnit.values.firstWhere(
        (e) => e.name == json['windUnit'],
        orElse: () => WindSpeedUnit.kmh,
      ),
      pressureUnit: PressureUnit.values.firstWhere(
        (e) => e.name == json['pressureUnit'],
        orElse: () => PressureUnit.hpa,
      ),
    );
  }
}

class UnitConverter {
  UnitConverter._();

  /// Converts Celsius to the selected unit.
  static double convertTemp(double celsius, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  /// Formats temperature with symbol (e.g. "24°C" or "75°F").
  static String formatTemp(double celsius, TemperatureUnit unit, {bool showUnit = true}) {
    final val = convertTemp(celsius, unit).round();
    final unitStr = unit == TemperatureUnit.fahrenheit ? '°F' : '°C';
    return showUnit ? '$val$unitStr' : '$val°';
  }

  /// Converts wind speed from km/h to selected unit.
  static double convertWind(double kmh, WindSpeedUnit unit) {
    switch (unit) {
      case WindSpeedUnit.kmh:
        return kmh;
      case WindSpeedUnit.mph:
        return kmh * 0.621371;
      case WindSpeedUnit.ms:
        return kmh / 3.6;
    }
  }

  /// Formats wind speed with unit string (e.g. "18 km/h" or "11 mph").
  static String formatWind(double kmh, WindSpeedUnit unit) {
    final val = convertWind(kmh, unit).toStringAsFixed(1);
    switch (unit) {
      case WindSpeedUnit.kmh:
        return '$val km/h';
      case WindSpeedUnit.mph:
        return '$val mph';
      case WindSpeedUnit.ms:
        return '$val m/s';
    }
  }

  /// Converts atmospheric pressure in hPa to selected unit.
  static double convertPressure(double hpa, PressureUnit unit) {
    if (unit == PressureUnit.inhg) {
      return hpa * 0.02953;
    }
    return hpa;
  }

  /// Formats pressure with unit string (e.g. "1013 hPa" or "29.92 inHg").
  static String formatPressure(double hpa, PressureUnit unit) {
    if (unit == PressureUnit.inhg) {
      return '${convertPressure(hpa, unit).toStringAsFixed(2)} inHg';
    }
    return '${hpa.round()} hPa';
  }
}
