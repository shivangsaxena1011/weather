class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;
  final String? state;
  final String tag; // 'home', 'college', 'work', 'custom'
  final String? customName;
  final bool isFavorite;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.country = '',
    this.state,
    this.tag = 'custom',
    this.customName,
    this.isFavorite = false,
  });

  String get displayName => customName?.isNotEmpty == true ? customName! : cityName;

  factory LocationModel.defaultLocation() {
    return const LocationModel(
      latitude: 19.0760,
      longitude: 72.8777,
      cityName: 'Mumbai',
      country: 'India',
      state: 'Maharashtra',
      tag: 'home',
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    String? country,
    String? state,
    String? tag,
    String? customName,
    bool? isFavorite,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      state: state ?? this.state,
      tag: tag ?? this.tag,
      customName: customName ?? this.customName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
        'country': country,
        'state': state,
        'tag': tag,
        'customName': customName,
        'isFavorite': isFavorite,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        cityName: json['cityName'] as String? ?? 'Unknown',
        country: json['country'] as String? ?? '',
        state: json['state'] as String?,
        tag: json['tag'] as String? ?? 'custom',
        customName: json['customName'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  @override
  String toString() => '$displayName, $country ($latitude, $longitude)';
}
