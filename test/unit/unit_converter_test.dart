import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter Tests', () {
    test('Celsius to Fahrenheit conversion', () {
      expect(UnitConverter.convertTemp(0, TemperatureUnit.fahrenheit), closeTo(32.0, 0.01));
      expect(UnitConverter.convertTemp(100, TemperatureUnit.fahrenheit), closeTo(212.0, 0.01));
      expect(UnitConverter.convertTemp(25, TemperatureUnit.fahrenheit), closeTo(77.0, 0.01));
      expect(UnitConverter.convertTemp(-40, TemperatureUnit.fahrenheit), closeTo(-40.0, 0.01));
      expect(UnitConverter.convertTemp(25, TemperatureUnit.celsius), closeTo(25.0, 0.01));
    });

    test('Wind speed conversions', () {
      expect(UnitConverter.convertWind(100, WindSpeedUnit.mph), closeTo(62.1, 0.1));
      expect(UnitConverter.convertWind(36, WindSpeedUnit.ms), closeTo(10.0, 0.1));
      expect(UnitConverter.convertWind(50, WindSpeedUnit.kmh), closeTo(50.0, 0.1));
    });

    test('Pressure conversions', () {
      expect(UnitConverter.convertPressure(1013.25, PressureUnit.inhg), closeTo(29.92, 0.02));
      expect(UnitConverter.convertPressure(1013.25, PressureUnit.hpa), closeTo(1013.25, 0.01));
    });

    test('Formatters with units', () {
      expect(UnitConverter.formatTemp(25.4, TemperatureUnit.celsius), '25°C');
      expect(UnitConverter.formatTemp(25.0, TemperatureUnit.fahrenheit), '77°F');
      expect(UnitConverter.formatWind(15.0, WindSpeedUnit.kmh), '15.0 km/h');
      expect(UnitConverter.formatWind(100.0, WindSpeedUnit.mph), '62.1 mph');
      expect(UnitConverter.formatPressure(1013.0, PressureUnit.hpa), '1013 hPa');
      expect(UnitConverter.formatPressure(1013.25, PressureUnit.inhg), '29.92 inHg');
    });

    test('UnitSettings JSON serialization', () {
      const original = UnitSettings(
        tempUnit: TemperatureUnit.fahrenheit,
        windUnit: WindSpeedUnit.ms,
        pressureUnit: PressureUnit.inhg,
      );

      final json = original.toJson();
      final restored = UnitSettings.fromJson(json);

      expect(restored.tempUnit, TemperatureUnit.fahrenheit);
      expect(restored.windUnit, WindSpeedUnit.ms);
      expect(restored.pressureUnit, PressureUnit.inhg);
    });
  });
}
