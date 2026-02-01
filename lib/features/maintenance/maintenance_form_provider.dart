import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db.dart';

class MaintenanceFormProvider extends ChangeNotifier {
  final Database _db = AppDb.instance.db;

  int? vehicleId;
  String issue = '';
  String? photoPath;

  bool loading = false;
  List<Map<String, dynamic>> vehicles = []; // [{id, label}]

  Future<void> loadVehicles() async {
    final rows = await _db.rawQuery(
      "SELECT id, brand || ' ' || model AS label "
      "FROM vehicles WHERE status <> 'maintenance' "
      "ORDER BY brand, model"
    );

    vehicles = rows;

    // ✅ Fix: if previously selected vehicle no longer exists, clear selection
    final ids = vehicles.map<int>((m) => m['id'] as int).toSet();
    if (vehicleId != null && !ids.contains(vehicleId)) {
      vehicleId = null;
    }

    notifyListeners();
  }

  void setVehicle(int? id) {
    vehicleId = id;
    notifyListeners();
  }

  void setIssue(String v) {
    issue = v;
    notifyListeners();
  }

  void reset() {
    vehicleId = null;
    issue = '';
    photoPath = null;
    notifyListeners();
  }


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    photoPath = file.path; // store absolute path
    notifyListeners();
  }

  bool get valid => (vehicleId != null) && issue.trim().isNotEmpty;

  Future<void> submit() async {
    if (!valid) return;
    loading = true; notifyListeners();

    await _db.transaction((txn) async {
      await txn.insert('maintenance_requests', {
        'vehicle_id': vehicleId,
        'issue': issue.trim(),
        'photo_path': photoPath,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String().substring(0,10),
      });
      await txn.update('vehicles', {'status': 'maintenance'},
        where: 'id = ?', whereArgs: [vehicleId]);
    });

    loading = false; notifyListeners();
  }
}
