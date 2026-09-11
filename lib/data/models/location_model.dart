class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;
  final String? state;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.country = '',
    this.state,
  });

  factory LocationModel.defaultLocation() {
    return const LocationModel(
      latitude: 19.0760,
      longitude: 72.8777,
      cityName: 'Mumbai',
      country: 'India',
      state: 'Maharashtra',
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
        'country': country,
        'state': state,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        cityName: json['cityName'] as String? ?? 'Unknown',
        country: json['country'] as String? ?? '',
        state: json['state'] as String?,
      );

  @override
  String toString() => '$cityName, $country ($latitude, $longitude)';
}
