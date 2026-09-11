# Mausam 🌤️ — Personalized Weather App

A Flutter-based mobile weather application that adapts its homepage based on the user's lifestyle persona.

## Features

- **8 Lifestyle Personas**: Health, Fitness, Beach, Traveler, Family, Agriculture, Commuter, Event Planner
- **100% Free APIs**: Powered by Open-Meteo (no API key required for weather, AQI, marine, soil data)
- **Personalized Widgets**: Each persona sees curated weather data most relevant to their life
- **Dark Mode**: Full light/dark theme support
- **Offline Cache**: Last fetched data shown when offline

## Personas & Their Widgets

| Persona | Key Data |
|---------|----------|
| 🌿 Health-Conscious | AQI, Pollen Count, UV Index, Humidity |
| 🏃 Outdoor Fitness | Sunrise/Sunset, Best Run Hours, Wind, Heat Alerts |
| 🏄 Beachgoer/Surfer | Wave Height, Tide Times, Sea Temp, Beach Safety |
| ✈️ Traveler | Saved Cities, Flight Alerts, Packing Suggestions |
| 👨‍👩‍👧 Parent/Family | School Commute, Rain at 3pm, Severe Warnings |
| 🌱 Agriculture | Soil Moisture, Frost Alerts, Rainfall Chart |
| 🚗 Commuter | Visibility, Fog Alerts, Traffic + Weather Combo |
| 🎉 Event Planner | 14-Day Forecast, Comfort Index, Best Event Days |

## APIs Used (All Free)

| API | Data | Key Required |
|-----|------|-------------|
| [Open-Meteo](https://open-meteo.com) | Weather, UV, Soil, Sunrise | ❌ None |
| [Open-Meteo Air Quality](https://open-meteo.com/en/docs/air-quality-api) | AQI, Pollen, PM2.5 | ❌ None |
| [Open-Meteo Marine](https://open-meteo.com/en/docs/marine-weather-api) | Waves, Sea Temp, Swell | ❌ None |
| [Open-Meteo Geocoding](https://open-meteo.com/en/docs/geocoding-api) | City Search | ❌ None |
| [Nominatim / OSM](https://nominatim.org) | Reverse Geocoding | ❌ None |
| [TomTom Traffic](https://developer.tomtom.com) | Traffic Flow (commuter) | ✅ Free key |

## Getting Started

### Prerequisites
- Flutter 3.47+ (`flutter --version`)
- Dart 3.13+
- Android Studio / VS Code

### Setup

1. **Clone / open** the project:
   ```bash
   cd mausam
   ```

2. **Add your TomTom key** in `.env`:
   ```
   TOMTOM_API_KEY=your_free_key_here
   ```
   Get a free key at https://developer.tomtom.com

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Add Poppins fonts** (download from Google Fonts):
   - Place `Poppins-Regular.ttf`, `Poppins-Medium.ttf`, `Poppins-SemiBold.ttf`, `Poppins-Bold.ttf`
   - Into `assets/fonts/`

5. **Run**:
   ```bash
   flutter run
   ```

### Build APK
```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart               # Entry point
├── app.dart                # MaterialApp + GoRouter
├── core/
│   ├── constants/          # Personas, AQI levels, API endpoints
│   ├── theme/              # Light/dark themes, persona colors
│   └── utils/              # Weather helpers, packing logic, AQI formatter
├── data/
│   ├── models/             # WeatherModel, AirQualityModel, MarineModel
│   ├── repositories/       # Data access layer
│   └── services/           # Open-Meteo API calls, storage
├── providers/              # Riverpod state (weather, location, persona)
├── screens/                # Onboarding, Home, Forecast, Settings
└── widgets/
    ├── common/             # Reusable cards, banners, shimmer
    ├── home/               # Header, hero, quick stats
    └── personas/           # 8 persona-specific widget sets
```

## Attribution

Weather data provided by [Open-Meteo](https://open-meteo.com) — free, open-source, no tracking.
Reverse geocoding by [Nominatim / OpenStreetMap](https://nominatim.org).
