class Vehicle {
  final int id;
  final String brand;
  final String model;
  final String plate;
  final int? year;
  final String status;           // available | in_use | maintenance
  final String? imagePath;       // can be null for now
  final double? lat;
  final double? lng;
  final String? nextServiceDate; // ISO: YYYY-MM-DD (nullable)
  final String? colour;
  final String? fuelType;
  final int? mileageKm;
  final int? seats;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    this.year,
    required this.status,
    this.imagePath,
    this.lat,
    this.lng,
    this.nextServiceDate,
    this.colour,
    this.fuelType,
    this.mileageKm,
    this.seats,
  });

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
        id: m['id'] as int,
        brand: m['brand'] as String,
        model: m['model'] as String,
        plate: m['plate'] as String,
        year: m['year'] as int?,
        status: m['status'] as String,
        imagePath: m['image_path'] as String?,
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
        nextServiceDate: m['next_service_date'] as String?,
        colour: m['colour'] as String?,
        fuelType: m['fuel_type'] as String?,
        mileageKm: m['mileage_km'] as int?,
        seats: m['seats'] as int?,
      );
}

// small helper
extension TitleCase on String {
  String toTitleCase() =>
      split(' ')
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
}
