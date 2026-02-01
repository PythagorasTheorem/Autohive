import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db.dart';

class BookingFormProvider extends ChangeNotifier {
  final Database _db = AppDb.instance.db;

  int? vehicleId;
  String? carType; // optional filter (Sedan/SUV/…)
  String fullName = '';
  String email = '';
  String phone = '';
  DateTime? startDate;
  DateTime? endDate;

  static const int dailyRate = 1000;

  List<Map<String, dynamic>> vehicles = []; // [{id,label,type}]
  bool loading = false;

  Future<void> loadVehicles() async {
    final rows = await _db.rawQuery("""
      SELECT id, brand || ' ' || model AS label, type
      FROM vehicles
      WHERE status <> 'maintenance'
        AND (? IS NULL OR type = ?)
      ORDER BY brand, model
    """, [carType, carType]);

    vehicles = rows;

    // if current selection not in filtered list, clear it
    final ids = vehicles.map<int>((m) => m['id'] as int).toSet();
    if (vehicleId != null && !ids.contains(vehicleId)) vehicleId = null;

    notifyListeners();
  }


  void setVehicle(int? id) { vehicleId = id; notifyListeners(); }
  void setCarType(String? t) {
    carType = t;
    vehicleId = null;     // clear previous selection
    loadVehicles();       // reload with filter
  }
  void setName(String v) { fullName = v; notifyListeners(); }
  void setEmail(String v) { email = v; notifyListeners(); }
  void setPhone(String v) { phone = v; notifyListeners(); }
  void setStart(DateTime d) { startDate = d; if (endDate!=null && endDate!.isBefore(d)) endDate=null; notifyListeners(); }
  void setEnd(DateTime d) { endDate = d; notifyListeners(); }

  int get days {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  int get price => days * dailyRate;

  bool get valid =>
      vehicleId != null &&
      startDate != null &&
      endDate != null &&
      !endDate!.isBefore(startDate!) &&
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty;

  Future<bool> hasOverlap() async {
    final s = _iso(startDate!);
    final e = _iso(endDate!);
    final rows = await _db.rawQuery(
      """
      SELECT 1 FROM bookings
      WHERE vehicle_id = ?
        AND status IN ('confirmed','completed')
        AND NOT (return_date < ? OR pickup_date > ?)
      LIMIT 1
      """,
      [vehicleId, s, e],
    );
    return rows.isNotEmpty;
  }

  Future<void> submit() async {
    if (!valid) return;
    loading = true; notifyListeners();

    await _db.transaction((txn) async {
      await txn.insert('bookings', {
        'vehicle_id': vehicleId,
        'user_name': fullName.trim(),
        'pickup_date': _iso(startDate!),
        'return_date': _iso(endDate!),
        'price': price,
        'status': 'confirmed',
        'created_at': _iso(DateTime.now()),
      });

      // 🔒 Business rule: ALWAYS mark vehicle as in_use after booking
      await txn.update('vehicles', {'status': 'in_use'},
          where: 'id = ?', whereArgs: [vehicleId]);
    });

    loading = false; notifyListeners();
  }

  void reset() {
    vehicleId = null;
    carType = null;
    fullName = '';
    email = '';
    phone = '';
    startDate = null;
    endDate = null;
    notifyListeners();
  }

  String _iso(DateTime d) => d.toIso8601String().substring(0,10); // YYYY-MM-DD
}
