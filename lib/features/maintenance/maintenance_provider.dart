import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db.dart';
import 'maintenance_item.dart';

class MaintenanceProvider extends ChangeNotifier {
  final Database _db = AppDb.instance.db;

  String _tab = 'pending'; // 'pending' | 'completed'
  String _query = '';
  List<MaintenanceItem> _all = [];
  int _pendingCount = 0;
  int _completedCount = 0;

  String get tab => _tab;
  String get query => _query;
  int get pendingCount => _pendingCount;
  int get completedCount => _completedCount;

  List<MaintenanceItem> get visible {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((e) =>
      e.brand.toLowerCase().contains(q) ||
      e.model.toLowerCase().contains(q) ||
      e.issue.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> load() async {
    await _loadCounts();

    final rows = await _db.rawQuery("""
      SELECT mr.id, mr.vehicle_id, mr.issue, mr.status, mr.created_at, mr.completed_at,
             v.brand, v.model, v.image_path, v.plate
      FROM maintenance_requests mr
      JOIN vehicles v ON v.id = mr.vehicle_id
      WHERE mr.status = ?
      ORDER BY mr.created_at DESC
    """, [_tab]);

    _all = rows.map((r) => MaintenanceItem.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> _loadCounts() async {
    final pc = await _db.rawQuery(
      "SELECT SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) AS p, "
      "SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS c "
      "FROM maintenance_requests");
    if (pc.isNotEmpty) {
      _pendingCount = (pc.first['p'] as int?) ?? 0;
      _completedCount = (pc.first['c'] as int?) ?? 0;
    } else {
      _pendingCount = _completedCount = 0;
    }
  }

  void setTab(String t) {
    if (_tab == t) return;
    _tab = t;
    _query = '';
    load();
  }

  void setSearch(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// Mark a request as completed and (simple rule) set the vehicle back to 'available'.
  Future<void> markCompleted({required int requestId, required int vehicleId}) async {
    await _db.transaction((txn) async {
      await txn.update(
        'maintenance_requests',
        {'status': 'completed', 'completed_at': DateTime.now().toIso8601String().substring(0,10)},
        where: 'id = ?',
        whereArgs: [requestId],
      );
      await txn.update(
        'vehicles',
        {'status': 'available'},
        where: 'id = ?',
        whereArgs: [vehicleId],
      );
    });
    await load(); // reload list + counts
  }
}
