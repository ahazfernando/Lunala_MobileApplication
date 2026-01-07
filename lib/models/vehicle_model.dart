/// Vehicle Model
/// Represents a vehicle option for delivery/ride booking
class VehicleOption {
  final String id;
  final String name;
  final String icon; // 🚲, 🛵, 🚗, 🚐
  final String description;
  final double basePrice;
  final int estimatedTimeMinutes;
  final String? imageUrl;
  final bool isAvailable;

  VehicleOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.basePrice,
    required this.estimatedTimeMinutes,
    this.imageUrl,
    this.isAvailable = true,
  });

  /// Create VehicleOption from Map
  factory VehicleOption.fromMap(Map<String, dynamic> map) {
    return VehicleOption(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🚗',
      description: map['description'] ?? '',
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      estimatedTimeMinutes: map['estimatedTimeMinutes'] ?? 0,
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  /// Convert VehicleOption to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'basePrice': basePrice,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}

