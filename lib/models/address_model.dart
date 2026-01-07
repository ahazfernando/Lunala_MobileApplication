/// Address Model
/// Represents a saved delivery address
class SavedAddress {
  final String? id;
  final String name; // Home, Office, Other, etc.
  final String fullAddress;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final String? icon; // 🏠, 🏢, 📍, etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SavedAddress({
    this.id,
    required this.name,
    required this.fullAddress,
    this.landmark,
    this.latitude,
    this.longitude,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Address from Firestore document
  factory SavedAddress.fromFirestore(Map<String, dynamic> data, String id) {
    return SavedAddress(
      id: id,
      name: data['name'] ?? '',
      fullAddress: data['fullAddress'] ?? '',
      landmark: data['landmark'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      icon: data['icon'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  /// Convert Address to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'fullAddress': fullAddress,
      if (landmark != null) 'landmark': landmark,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (icon != null) 'icon': icon,
    };
  }

  /// Create a copy with updated fields
  SavedAddress copyWith({
    String? id,
    String? name,
    String? fullAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

