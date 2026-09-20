import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/data/models/air_quality_model.dart';
import 'package:mausam/data/models/marine_model.dart';
import 'package:mausam/data/models/location_model.dart';
import 'package:mausam/providers/weather_provider.dart';
import 'package:mausam/screens/forecast/forecast_screen.dart';

void main() {
  group('ForecastScreen Widget Tests', () {
    testWidgets('Renders loading spinner when weather data is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherDataProvider.overrideWith((ref) => Future.any([])),
          ],
          child: const MaterialApp(
            home: ForecastScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders error recovery view when weatherDataProvider fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherDataProvider.overrideWith(
              (ref) => Future.error(Exception('Connection failure')),
            ),
          ],
          child: const MaterialApp(
            home: ForecastScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Forecast'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('Renders forecast content and daily cards on successful load', (tester) async {
      final mockWeather = WeatherModel.mock();
      final mockAQI = AirQualityModel.mock();
      final mockMarine = MarineModel.mock();
      const mockLocation = LocationModel(
        cityName: 'Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        country: 'India',
      );
      final mockBundle = MausamDataBundle(
        weather: mockWeather,
        airQuality: mockAQI,
        marine: mockMarine,
        location: mockLocation,
        cachedAt: DateTime.now(),
        isOffline: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherDataProvider.overrideWith((ref) async => mockBundle),
          ],
          child: const MaterialApp(
            home: ForecastScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Detailed Forecast'), findsOneWidget);
      expect(find.text('HOURLY TEMPERATURE TIMELINE (24h)'), findsOneWidget);
      expect(find.text('7-DAY OUTLOOK'), findsOneWidget);
    });
  });
}
