/// Standardized exceptions hierarchy for Mausam Weather Platform.
sealed class WeatherAppException implements Exception {
  final String message;
  final String? technicalDetails;
  final bool canRetry;

  const WeatherAppException({
    required this.message,
    this.technicalDetails,
    this.canRetry = true,
  });

  @override
  String toString() => message;
}

class NetworkError extends WeatherAppException {
  const NetworkError({
    super.message = 'Unable to connect to the internet. Please check your connection.',
    super.technicalDetails,
    super.canRetry = true,
  });
}

class LocationError extends WeatherAppException {
  const LocationError({
    super.message = 'Location access is required to show accurate local weather.',
    super.technicalDetails,
    super.canRetry = true,
  });
}

class WeatherAPIError extends WeatherAppException {
  final int? statusCode;

  const WeatherAPIError({
    super.message = 'Weather service is currently experiencing issues. Showing cached data.',
    this.statusCode,
    super.technicalDetails,
    super.canRetry = true,
  });
}

class AQIError extends WeatherAppException {
  const AQIError({
    super.message = 'Air quality data is currently unavailable for this region.',
    super.technicalDetails,
    super.canRetry = true,
  });
}

class AIServiceError extends WeatherAppException {
  const AIServiceError({
    super.message = 'AI Assistant is temporarily unavailable. Using expert rules.',
    super.technicalDetails,
    super.canRetry = true,
  });
}

class CacheError extends WeatherAppException {
  const CacheError({
    super.message = 'Unable to access local cached weather data.',
    super.technicalDetails,
    super.canRetry = false,
  });
}

class InvalidLocationError extends WeatherAppException {
  const InvalidLocationError({
    super.message = 'Invalid coordinates or location not found.',
    super.technicalDetails,
    super.canRetry = false,
  });
}

class RateLimitError extends WeatherAppException {
  const RateLimitError({
    super.message = 'API request limit reached. Please wait a few moments before retrying.',
    super.technicalDetails,
    super.canRetry = true,
  });
}
