import 'package:sqflite/sqflite.dart';
import '../../core/db.dart';
import 'vehicle.dart';

class VehiclesRepository {
  Database get _db => AppDb.instance.db;

  Future<List<Vehicle>> getAll() async {
    final rows = await _db.rawQuery(
      "SELECT * FROM vehicles ORDER BY brand ASC, model ASC",
    );
    return rows.map((e) => Vehicle.fromMap(e)).toList();
  }

  Future<List<Vehicle>> getByStatus(String status) async {
    final rows = await _db.rawQuery(
      "SELECT * FROM vehicles WHERE status = ? ORDER BY brand, model",
      [status],
    );
    return rows.map((e) => Vehicle.fromMap(e)).toList();
  }

  Future<List<Vehicle>> search(String q, {String? status}) async {
    final like = '%$q%';
    final List<Map<String, Object?>> rows;
    if (status == null || status == 'all') {
      rows = await _db.rawQuery(
        "SELECT * FROM vehicles "
        "WHERE brand LIKE ? OR model LIKE ? OR plate LIKE ? "
        "ORDER BY brand, model",
        [like, like, like],
      );
    } else {
      rows = await _db.rawQuery(
        "SELECT * FROM vehicles "
        "WHERE status = ? AND (brand LIKE ? OR model LIKE ? OR plate LIKE ?) "
        "ORDER BY brand, model",
        [status, like, like, like],
      );
    }
    return rows.map((e) => Vehicle.fromMap(e)).toList();
  }

  Future<Vehicle?> getById(int id) async {
    final rows = await _db.rawQuery("SELECT * FROM vehicles WHERE id = ?", [
      id,
    ]);
    if (rows.isEmpty) return null;
    return Vehicle.fromMap(rows.first);
  }

  Future<int> insert(Vehicle vehicle) async {
    return await _db.insert('vehicles', {
      'brand': vehicle.brand,
      'model': vehicle.model,
      'plate': vehicle.plate,
      'year': vehicle.year,
      'status': vehicle.status,
      'image_path': vehicle.imagePath,
      'lat': vehicle.lat,
      'lng': vehicle.lng,
      'next_service_date': vehicle.nextServiceDate,
      'colour': vehicle.colour,
      'fuel_type': vehicle.fuelType,
      'mileage_km': vehicle.mileageKm,
      'seats': vehicle.seats,
    });
  }

  Future<void> delete(int id) async {
    await _db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Vehicle vehicle) async {
    await _db.update(
      'vehicles',
      {
        'brand': vehicle.brand,
        'model': vehicle.model,
        'plate': vehicle.plate,
        'year': vehicle.year,
        'status': vehicle.status,
        'image_path': vehicle.imagePath,
        'lat': vehicle.lat,
        'lng': vehicle.lng,
        'next_service_date': vehicle.nextServiceDate,
        'colour': vehicle.colour,
        'fuel_type': vehicle.fuelType,
        'mileage_km': vehicle.mileageKm,
        'seats': vehicle.seats,
      },
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }
}
