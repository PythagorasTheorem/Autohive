import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db.dart';
import '../vehicles/vehicle.dart';
import '../vehicles/vehicles_repository.dart';
import 'booking.dart';
import 'service_item.dart';

class VehicleDetailProvider extends ChangeNotifier {
  final VehiclesRepository _vehiclesRepo;
  VehicleDetailProvider(this._vehiclesRepo);

  final Database _db = AppDb.instance.db;

  Vehicle? vehicle;
  Booking? activeBooking;
  List<ServiceItem> history = [];
  bool loading = false;

  Future<void> load(int vehicleId) async {
    loading = true; notifyListeners();

    vehicle = await _vehiclesRepo.getById(vehicleId);

    // Active booking overlapping today
    final ab = await _db.rawQuery(
      "SELECT * FROM bookings "
      "WHERE vehicle_id=? AND status='confirmed' "
      "AND date('now') BETWEEN pickup_date AND return_date "
      "LIMIT 1", [vehicleId]);
    activeBooking = ab.isEmpty ? null : Booking.fromMap(ab.first);

    // Service history newest first
    final hs = await _db.rawQuery(
      "SELECT title, date FROM service_history WHERE vehicle_id=? ORDER BY date DESC",
      [vehicleId]);
    history = hs.map((e) => ServiceItem.fromMap(e)).toList();

    loading = false; notifyListeners();
  }
}
