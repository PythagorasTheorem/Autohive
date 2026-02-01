class MaintenanceItem {
  final int id;
  final int vehicleId;
  final String brand;
  final String model;
  final String plate;
  final String? imagePath;
  final String issue;
  final String status;          // pending | completed
  final String createdAt;       // ISO
  final String? completedAt;    // ISO

  MaintenanceItem({
    required this.id,
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plate,
    required this.imagePath,
    required this.issue,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory MaintenanceItem.fromMap(Map<String, dynamic> m) => MaintenanceItem(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int,
    brand: m['brand'] as String,
    model: m['model'] as String,
    plate: m['plate'] as String,
    imagePath: m['image_path'] as String?,
    issue: m['issue'] as String,
    status: m['status'] as String,
    createdAt: m['created_at'] as String,
    completedAt: m['completed_at'] as String?,
  );
}
